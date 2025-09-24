// Copyright lowRISC contributors (OpenTitan project).
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

class axi_mst_driver extends dv_base_driver #(
    .ITEM_T(axi_mst_item),
    .CFG_T (axi_mst_agent_cfg)
);
  `uvm_component_utils(axi_mst_driver)

  // the base class provides the following handles for use:
  // axi_mst_agent_cfg: cfg

  // queue for send txn
  axi_mst_item aw_txn_queue[$];
  axi_mst_item w_txn_queue[$];
  axi_mst_item ar_txn_queue[$];

  // Queue for storing transactions between the request and the response:
  // the request is stored to keep its sequencer values, and extracted when
  // sending back the corresponding response
  axi_mst_item global_txn_queue[string][$];

  `uvm_component_new

  virtual task run_phase(uvm_phase phase);
    // base class forks off reset_signals() and get_and_drive() tasks
    super.run_phase(phase);
  endtask

  // reset signals
  virtual task reset_signals();
    under_reset = (cfg.vif.rst_ni == 1'b0);
    forever begin
      `uvm_info(`gfn, "Reset signals and queues", UVM_LOW)
      drive_AW_channel_signals();
      drive_W_channel_signals();
      drive_AR_channel_signals();
      cfg.vif.b_ready <= 1'b0;
      cfg.vif.r_ready <= 1'b0;
      aw_txn_queue.delete();
      w_txn_queue.delete();
      ar_txn_queue.delete();
      global_txn_queue.delete();
      wait (cfg.vif.rst_ni);
      under_reset = 1'b0;
      `uvm_info(`gfn, "Reset deasserted", UVM_LOW)
      wait (!cfg.vif.rst_ni);
      under_reset = 1'b1;
      `uvm_info(`gfn, "Reset asserted", UVM_LOW)
    end
  endtask

  // drive trans received from sequencer
  virtual task get_and_drive();
    `uvm_info(`gfn, "Get_and_drive stask is starting", UVM_DEBUG)
    // Wait for initial reset to pass.
    wait (cfg.vif.rst_ni === 1'b1);
    @(posedge cfg.vif.clk_i);
    fork
      // get txn from sequencer
      get_txn();
      // drive vif
      drive_AW_channel();
      drive_W_channel();
      receive_B_channel();
      drive_AR_channel();
      receive_R_channel();
      // ready rsp
      B_channel_ready_rsp();
      R_channel_ready_rsp();
    join
  endtask


  // get item from sequencer
  extern virtual task get_txn();
  // driver vif
  extern virtual task drive_AW_channel_signals(axi_mst_item aw_txn = null);
  extern virtual task drive_W_channel_signals(axi_mst_item w_txn = null);
  extern virtual task drive_AR_channel_signals(axi_mst_item ar_txn = null);
  // send & receive txn
  extern virtual task drive_AW_channel();
  extern virtual task drive_W_channel();
  extern virtual task drive_AR_channel();
  extern virtual task receive_B_channel();
  extern virtual task receive_R_channel();
  // ready rsp
  extern virtual task B_channel_ready_rsp();
  extern virtual task R_channel_ready_rsp();

endclass

task axi_mst_driver::get_txn();
  axi_mst_item txn;
  axi_mst_item txn_channel;

  string ids_s;
  // Put the transaction in the corresponding queue
  forever begin
    // Get the next transaction from the sequencer
    seq_item_port.get_next_item(txn);

    if (!$cast(txn_channel, txn.clone())) begin
      `uvm_error(`gfn, "Error during the cast of the transaction");
    end
    // In case of an Atomic Store, only a write response is expected. The other
    // atomic transactions expect a read response as well
    if ((txn_channel.m_atop[5]) && (txn_channel.m_txn_type == AXI_WRITE_REQ)) begin
      ids_s = $sformatf("AXI_READ_REQ_%0h", txn.m_id);
      global_txn_queue[ids_s].push_front(txn);
    end

    ids_s = $sformatf("%0s_%0h", txn.m_txn_type, txn.m_id);
    // Storing the transaction in an associate array of queue to use it
    // when its time to send back the corresponding response to the sequence
    global_txn_queue[ids_s].push_front(txn);

    `uvm_info(`gfn, $sformatf("rcvd item:\n%0s", txn.convert2string()), UVM_HIGH)
    case (txn.m_txn_type)
      AXI_WRITE_REQ: begin
        fork
          aw_txn_queue.push_front(txn_channel);
          w_txn_queue.push_front(txn_channel);
        join_none
      end
      AXI_READ_REQ: begin
        ar_txn_queue.push_front(txn_channel);
      end
      AXI_WRITE_RSP: begin
        `uvm_warning(`gfn, "This driver is on the master side, and can't drive slave controlled channel by sending a AXI_WRITE_RSP")
      end
      AXI_READ_RSP: begin
        `uvm_warning(`gfn, "This driver is on the master side, and can't drive slave controlled channel by sending a AXI_READ_RSP")
      end
    endcase
    seq_item_port.item_done();
  end
endtask

task axi_mst_driver::drive_AW_channel_signals(axi_mst_item aw_txn = null);
  if (aw_txn != null) begin
    cfg.vif.aw_id     <= aw_txn.m_id;
    cfg.vif.aw_addr   <= aw_txn.m_addr;
    cfg.vif.aw_len    <= aw_txn.m_len;
    cfg.vif.aw_size   <= aw_txn.m_size;
    cfg.vif.aw_burst  <= aw_txn.m_burst;
    cfg.vif.aw_lock   <= aw_txn.m_lock;
    cfg.vif.aw_cache  <= aw_txn.m_cache;
    cfg.vif.aw_prot   <= aw_txn.m_prot;
    cfg.vif.aw_qos    <= aw_txn.m_qos;
    cfg.vif.aw_region <= aw_txn.m_region;
    cfg.vif.aw_atop   <= aw_txn.m_atop;
    cfg.vif.aw_user   <= aw_txn.m_user;
  end else begin
    cfg.vif.aw_id     <= 'hx;
    cfg.vif.aw_addr   <= 'hx;
    cfg.vif.aw_len    <= 'hx;
    cfg.vif.aw_size   <= 'hx;
    cfg.vif.aw_burst  <= 'hx;
    cfg.vif.aw_lock   <= 'hx;
    cfg.vif.aw_cache  <= 'hx;
    cfg.vif.aw_prot   <= 'hx;
    cfg.vif.aw_qos    <= 'hx;
    cfg.vif.aw_region <= 'hx;
    cfg.vif.aw_atop   <= 'hx;
    cfg.vif.aw_user   <= 'hx;
  end

  cfg.vif.aw_valid <= 0;
endtask

task axi_mst_driver::drive_W_channel_signals(axi_mst_item w_txn = null);
  if (w_txn != null) begin
    cfg.vif.w_data <= w_txn.m_data[0];
    cfg.vif.w_strb <= w_txn.m_wstrb[0];
    cfg.vif.w_last <= w_txn.m_last[0];
    cfg.vif.w_user <= w_txn.m_w_user;
  end else begin
    cfg.vif.w_data <= 'hx;
    cfg.vif.w_strb <= 'hx;
    cfg.vif.w_last <= 'hx;
    cfg.vif.w_user <= 'hx;
  end

  cfg.vif.w_valid <= 0;
endtask

task axi_mst_driver::drive_AR_channel_signals(axi_mst_item ar_txn = null);
  if (ar_txn != null) begin
    cfg.vif.ar_id     <= ar_txn.m_id;
    cfg.vif.ar_addr   <= ar_txn.m_addr;
    cfg.vif.ar_len    <= ar_txn.m_len;
    cfg.vif.ar_size   <= ar_txn.m_size;
    cfg.vif.ar_burst  <= ar_txn.m_burst;
    cfg.vif.ar_lock   <= ar_txn.m_lock;
    cfg.vif.ar_cache  <= ar_txn.m_cache;
    cfg.vif.ar_prot   <= ar_txn.m_prot;
    cfg.vif.ar_qos    <= ar_txn.m_qos;
    cfg.vif.ar_region <= ar_txn.m_region;
    cfg.vif.ar_user   <= ar_txn.m_user;
  end else begin
    cfg.vif.ar_id     <= 'hx;
    cfg.vif.ar_addr   <= 'hx;
    cfg.vif.ar_len    <= 'hx;
    cfg.vif.ar_size   <= 'hx;
    cfg.vif.ar_burst  <= 'hx;
    cfg.vif.ar_lock   <= 'hx;
    cfg.vif.ar_cache  <= 'hx;
    cfg.vif.ar_prot   <= 'hx;
    cfg.vif.ar_qos    <= 'hx;
    cfg.vif.ar_region <= 'hx;
    cfg.vif.ar_user   <= 'hx;
  end

  cfg.vif.ar_valid <= 0;

endtask

task axi_mst_driver::drive_AW_channel();
  axi_mst_item aw_txn;

  `uvm_info(`gfn, "drive_AW_channel task is starting", UVM_DEBUG)
  forever begin

    // Drive bus signals to idle while waiting for a transaction.
    drive_AW_channel_signals();

    // Waiting and extracting the last request from the queue
    wait (aw_txn_queue.size() != 0);
    aw_txn = aw_txn_queue.pop_back();

    // Applying the delay of the transaction before enabling the valid
    // signal
    if (aw_txn.m_delay_cycle_chan_X != 0) cfg.vif.wait_n_clock_cycle(aw_txn.m_delay_cycle_chan_X);

    // Driving all the signals of the interface with the transaction
    drive_AW_channel_signals(aw_txn);

    `uvm_info(`gfn, "DRIVING VALID", UVM_DEBUG)
    // Handshake process
    cfg.vif.aw_valid <= 1;
    do begin
      @(posedge cfg.vif.clk_i);
      `uvm_info(`gfn, $sformatf("READY ARRIVE, %d", cfg.vif.aw_ready), UVM_DEBUG)
    end while (cfg.vif.aw_ready == 0);

    // End of the transaction
    cfg.vif.aw_valid <= 0;
    `uvm_info(`gfn, "READY ARRIVE", UVM_DEBUG)

  end  // forever
endtask

task axi_mst_driver::drive_W_channel();
  axi_mst_item w_txn;
  axi_mst_item w_flit;
  `uvm_info(`gfn, "drive_W_channel task is starting", UVM_DEBUG)
  forever begin

    // Drive bus signals to idle while waiting for a transaction.
    drive_W_channel_signals();

    // Waiting and extracting the last request from the queue
    wait (w_txn_queue.size() != 0);
    w_txn = w_txn_queue.pop_back();

    // Applying the delay of the transaction before enabling the valid
    // signal
    if (w_txn.m_delay_cycle_chan_W != 0) cfg.vif.wait_n_clock_cycle(w_txn.m_delay_cycle_chan_W);

    for (int i = 0; i < w_txn.m_len + 1; i++) begin
      // Driving all the signals of the interface with the transaction
      w_flit = new();
      w_flit.m_data.push_front(w_txn.m_data[i]);
      w_flit.m_wstrb.push_front(w_txn.m_wstrb[i]);
      w_flit.m_last.push_front(w_txn.m_last[i]);
      w_flit.m_w_user = w_txn.m_w_user;

      drive_W_channel_signals(w_flit);

      // Handshake process
      cfg.vif.w_valid <= 1;
      do begin
        @(posedge cfg.vif.clk_i);
      end while (cfg.vif.w_ready == 0);

      // End of the first flit transaction
      cfg.vif.w_valid <= 0;
      if (w_txn.m_delay_cycle_flits[i] != 0) cfg.vif.wait_n_clock_cycle(w_txn.m_delay_cycle_flits[i]);

    end  // for
    cfg.vif.w_last <= 0;

  end  // forever
endtask

task axi_mst_driver::drive_AR_channel();
  axi_mst_item ar_txn;

  `uvm_info(`gfn, "drive_AR_channel task is starting", UVM_DEBUG)
  forever begin

    // Drive bus signals to idle while waiting for a transaction.
    drive_AR_channel_signals();

    // Waiting and extracting the last request from the queue
    wait (ar_txn_queue.size() != 0);
    ar_txn = ar_txn_queue.pop_back();

    // Applying the delay of the transaction before enabling the valid
    // signal
    if (ar_txn.m_delay_cycle_chan_X != 0) cfg.vif.wait_n_clock_cycle(ar_txn.m_delay_cycle_chan_X);

    // Driving all the signals of the interface with the transaction
    drive_AR_channel_signals(ar_txn);

    // Handshake process
    cfg.vif.ar_valid <= 1;
    do begin
      @(posedge cfg.vif.clk_i);
    end while (cfg.vif.ar_ready == 0);

    // End of the transaction
    cfg.vif.ar_valid <= 0;

  end  // forever
endtask

task axi_mst_driver::receive_B_channel();
  axi_mst_item txn;
  string ids_s;

  `uvm_info(`gfn, "receive_B_channel task is starting", UVM_DEBUG)

  forever begin
    @(posedge cfg.vif.clk_i);

    if (cfg.vif.b_valid && cfg.vif.b_ready) begin

      // Get the IDS_s from the response, to identify the request associated
      // to this transaction in the associative array
      ids_s = $sformatf("%0s_%0h", "AXI_WRITE_REQ", cfg.vif.b_id);

      // Get the original transaction from the associative array/queu
      if (global_txn_queue.exists(ids_s)) begin
        // Extract the transaction from the associative array/queue and
        // override it with the response
        txn = global_txn_queue[ids_s].pop_back();
        if (global_txn_queue[ids_s].size() == 0) global_txn_queue.delete(ids_s);
        `uvm_info(`gfn, $sformatf("%0s", txn.convert2string()), UVM_DEBUG)

        txn.m_txn_type = AXI_WRITE_RSP;
        txn.m_id       = cfg.vif.b_id;
        txn.m_user     = cfg.vif.b_user;
        txn.m_resp[0]  = axi_dv_resp_t'(cfg.vif.b_resp);

        // Sending the response to the sequencer on the posedge
        // @(posedge cfg.vif.clk_i);
        seq_item_port.put_response(txn);

      end else begin
        `uvm_error(`gfn, $sformatf("No corresponding txn found in global_txn_queue: ID=%0s(s)", ids_s))
      end
    end  // if

  end  // forever

endtask

task axi_mst_driver::receive_R_channel();
  axi_mst_item   txn;
  axi_sig_data_t m_data[$];
  axi_sig_resp_t m_resp[$];
  string         ids_s;

  `uvm_info(`gfn, "receive_R_channel task is starting", UVM_DEBUG)

  forever begin
    @(posedge cfg.vif.clk_i);

    if (cfg.vif.r_valid && cfg.vif.r_ready) begin


      // Assign data 
      m_data.push_back(cfg.vif.r_data);
      m_resp.push_back(cfg.vif.r_resp);

      // Wait for the read response to be completed before sending the
      // response to the sequencer        
      if (cfg.vif.r_last) begin

        // Get the IDS_s from the response, to identify the request associated
        // to this transaction in the associative array
        ids_s = $sformatf("%0s_%0h", "AXI_READ_REQ", cfg.vif.r_id);

        // Get the original transaction from the associative array/queu
        if (global_txn_queue.exists(ids_s)) begin

          // Extract the transaction from the associative array/queue and
          // override it with the response
          txn = global_txn_queue[ids_s].pop_back();
          if (global_txn_queue[ids_s].size() == 0) global_txn_queue.delete(ids_s);

          txn.m_txn_type = AXI_READ_RSP;
          txn.m_id       = cfg.vif.r_id;

          for (int i = 0; i < txn.m_len + 1; i++) begin
            txn.set_data_flit(m_data[i], i);
            txn.set_resp_flit(axi_dv_resp_t'(m_resp[i]), i);
          end
          m_data.delete();
          m_resp.delete();

          // Sending the transaction to the sequencer
          seq_item_port.put_response(txn);

        end else begin
          `uvm_error(`gfn, $sformatf("No corresponding txn found in global_txn_queue: ID=%0s(s)", ids_s))
        end  // elsif
      end  // if
    end  // if

  end  // forever
endtask

task axi_mst_driver::B_channel_ready_rsp();
  int unsigned b_ready_delay;

  forever begin
    b_ready_delay = $urandom_range(cfg.b_ready_delay_min, cfg.b_ready_delay_max);

    repeat (b_ready_delay) begin
      @(posedge cfg.vif.clk_i);
    end

    cfg.vif.b_ready <= 1'b1;
    @(posedge cfg.vif.clk_i);
    cfg.vif.b_ready <= 1'b0;
  end
endtask

task axi_mst_driver::R_channel_ready_rsp();
  int unsigned r_ready_delay;

  forever begin
    r_ready_delay = $urandom_range(cfg.r_ready_delay_min, cfg.r_ready_delay_max);

    repeat (r_ready_delay) begin
      @(posedge cfg.vif.clk_i);
    end

    cfg.vif.r_ready <= 1'b1;
    @(posedge cfg.vif.clk_i);
    cfg.vif.r_ready <= 1'b0;
  end
endtask


