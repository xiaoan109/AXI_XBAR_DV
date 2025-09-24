// Copyright lowRISC contributors (OpenTitan project).
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

class axi_slv_driver extends dv_base_driver #(
    .ITEM_T(axi_slv_item),
    .CFG_T (axi_slv_agent_cfg)
);
  `uvm_component_utils(axi_slv_driver)

  // the base class provides the following handles for use:
  // axi_slv_agent_cfg: cfg

  // queue for send txn
  axi_slv_item b_txn_queue[$];
  axi_slv_item r_txn_queue[$];

  // Queue for storing the write request AW/W packets to combine them, and
  // send back a response for reactive slave.
  axi_slv_item write_req_queue[$];
  axi_slv_item write_dat_queue[$];


  // req fifo
  axi_slv_item slv_req_fifo[$];
  // req imp for sqr
  uvm_blocking_get_imp #(axi_slv_item, axi_slv_driver) get_export;

  `uvm_component_new

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    get_export = new("get_export", this);
  endfunction

  virtual task run_phase(uvm_phase phase);
    // base class forks off reset_signals() and get_and_drive() tasks
    super.run_phase(phase);
  endtask

  // reset signals
  virtual task reset_signals();
    under_reset = (cfg.vif.rst_ni == 1'b0);
    forever begin
      `uvm_info(`gfn, "Reset signals and queues", UVM_LOW)
      drive_B_channel_signals();
      drive_R_channel_signals();
      cfg.vif.aw_ready <= 1'b0;
      cfg.vif.w_ready  <= 1'b0;
      cfg.vif.ar_ready <= 1'b0;
      b_txn_queue.delete();
      r_txn_queue.delete();
      slv_req_fifo.delete();
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
      receive_AW_channel();
      receive_W_channel();
      send_back_write_response();
      drive_B_channel();
      receive_AR_channel();
      drive_R_channel();
      // ready rsp
      AW_channel_ready_rsp();
      W_channel_ready_rsp();
      AR_channel_ready_rsp();
    join
  endtask

  virtual task get(output axi_slv_item txn);
    wait (slv_req_fifo.size() != 0);
    txn = slv_req_fifo.pop_front();
    `uvm_info(`gfn, $sformatf("Get req:\n%0s", txn.convert2string()), UVM_HIGH)
  endtask

  // get item from sequencer
  extern virtual task get_txn();
  // driver vif
  extern virtual task drive_B_channel_signals(axi_slv_item b_txn = null);
  extern virtual task drive_R_channel_signals(axi_slv_item r_txn = null);
  // send & receive txn
  extern virtual task receive_AW_channel();
  extern virtual task receive_W_channel();
  extern virtual task send_back_write_response();
  extern virtual task drive_B_channel();
  extern virtual task receive_AR_channel();
  extern virtual task drive_R_channel();
  // ready rsp
  extern virtual task AW_channel_ready_rsp();
  extern virtual task W_channel_ready_rsp();
  extern virtual task AR_channel_ready_rsp();

endclass


task axi_slv_driver::get_txn();
  axi_slv_item txn;
  axi_slv_item txn_channel;

  forever begin
    // Get the next transaction from the sequencer
    seq_item_port.get_next_item(txn);

    if (!$cast(txn_channel, txn.clone())) begin
      `uvm_error(`gfn, "Error during the cast of the transaction");
    end

    `uvm_info(`gfn, $sformatf("rcvd item:\n%0s", txn.convert2string()), UVM_HIGH)
    case (txn.m_txn_type)
      AXI_WRITE_REQ: begin
        `uvm_warning(`gfn, "This driver is on the slave side, and can't drive master controlled channel by sending a AXI_WRITE_REQ")
      end
      AXI_READ_REQ: begin
        `uvm_warning(`gfn, "This driver is on the slave side, and can't drive master controlled channel by sending a AXI_READ_REQ")
      end
      AXI_WRITE_RSP: begin
        b_txn_queue.push_front(txn_channel);
      end
      AXI_READ_RSP: begin
        r_txn_queue.push_front(txn_channel);
      end
    endcase
    seq_item_port.item_done();
  end
endtask

task axi_slv_driver::drive_B_channel_signals(axi_slv_item b_txn = null);
  if (b_txn != null) begin
    cfg.vif.b_id   <= b_txn.m_id;
    cfg.vif.b_resp <= axi_sig_resp_t'(b_txn.m_resp[0]);
    cfg.vif.b_user <= b_txn.m_user;
  end else begin
    cfg.vif.b_id   <= 'hx;
    cfg.vif.b_resp <= 'hx;
    cfg.vif.b_user <= 'hx;
  end
  cfg.vif.b_valid <= 0;
endtask

task axi_slv_driver::drive_R_channel_signals(axi_slv_item r_txn = null);
  if (r_txn != null) begin
    cfg.vif.r_id   <= r_txn.m_id;
    cfg.vif.r_data <= r_txn.m_data[0];
    cfg.vif.r_resp <= axi_sig_resp_t'(r_txn.m_resp[0]);
    cfg.vif.r_last <= r_txn.m_last[0];
    cfg.vif.r_user <= r_txn.m_user;
  end else begin
    cfg.vif.r_id   <= 'hx;
    cfg.vif.r_data <= 'hx;
    cfg.vif.r_resp <= 'hx;
    cfg.vif.r_last <= 'hx;
    cfg.vif.r_user <= 'hx;
  end
  cfg.vif.r_valid <= 0;
endtask

task axi_slv_driver::receive_AW_channel();
  axi_slv_item wreq;
  axi_slv_item rreq;

  `uvm_info(`gfn, "receive_AW_channel task is starting", UVM_DEBUG)

  forever begin
    @(posedge cfg.vif.clk_i);

    if (cfg.vif.aw_valid && cfg.vif.aw_ready) begin

      // The agent is reactive, the id of the transaction is stored and
      // push in a queue, to generate a response when the write request is
      // completed.

      // Storing the id in a transaction
      wreq            = new();
      wreq.m_id       = cfg.vif.aw_id;
      wreq.m_addr     = cfg.vif.aw_addr;
      wreq.m_len      = cfg.vif.aw_len;
      wreq.m_size     = axi_dv_size_t'(cfg.vif.aw_size);
      wreq.m_burst    = axi_dv_burst_t'(cfg.vif.aw_burst);
      wreq.m_lock     = axi_dv_lock_t'(cfg.vif.aw_lock);
      wreq.m_cache    = cfg.vif.aw_cache;
      wreq.m_mem_type = get_mem_type(AXI_WRITE_REQ, cfg.vif.aw_cache);
      wreq.m_prot     = axi_dv_prot_t'(cfg.vif.aw_prot);
      wreq.m_qos      = cfg.vif.aw_qos;
      wreq.m_region   = cfg.vif.aw_region;
      wreq.m_user     = cfg.vif.aw_user;
      wreq.m_atop     = cfg.vif.aw_atop;

      wreq.m_txn_type = AXI_WRITE_REQ;

      // Push the transaction in a write request queue, to combine it
      // later with the packets from the W channel
      write_req_queue.push_back(wreq);

      // Push the read transaction in the read request queue, if the
      // atop field indicates the need of an additional read response
      if (cfg.vif.aw_atop[5]) begin
        rreq = new();
        rreq.m_txn_type = AXI_READ_REQ;
        rreq.m_id = cfg.vif.aw_id;
        rreq.m_addr = cfg.vif.aw_addr;
        rreq.m_len = cfg.vif.aw_len;
        rreq.m_size = axi_dv_size_t'(cfg.vif.aw_size);
        rreq.m_burst = axi_dv_burst_t'(cfg.vif.aw_burst);
        rreq.m_lock = axi_dv_lock_t'(cfg.vif.aw_lock);
        rreq.m_cache = cfg.vif.aw_cache;
        rreq.m_mem_type = get_mem_type(AXI_WRITE_REQ, cfg.vif.aw_cache);
        rreq.m_prot = axi_dv_prot_t'(cfg.vif.aw_prot);
        rreq.m_qos = cfg.vif.aw_qos;
        rreq.m_region = cfg.vif.aw_region;
        rreq.m_user = cfg.vif.aw_user;
        rreq.m_atop = cfg.vif.aw_atop;


        `uvm_error(`gfn, "Error randomizing the request metadata");
        // r_txn_queue.push_back(rreq);
        slv_req_fifo.push_back(rreq);
      end

    end  // if

  end  // forever

endtask

task axi_slv_driver::receive_W_channel();
  axi_slv_item wdat;

  `uvm_info(`gfn, "receive_W_channel task is starting", UVM_DEBUG)

  forever begin
    @(posedge cfg.vif.clk_i);

    if (cfg.vif.w_valid && cfg.vif.w_ready) begin

      // The slave is reactive, wait for the last packet to store
      // the request in the queue to combine it with the write request from
      // the AW channel
      // if (cfg.vif.w_last) begin
      //   `uvm_info(`gfn, "Sending a new wdat packet", UVM_DEBUG)
      //   wdat = new();
      //   write_dat_queue.push_front(wdat);
      // end

      // Send each beat
      wdat = new();

      wdat.m_data.push_back(cfg.vif.w_data);
      wdat.m_wstrb.push_back(cfg.vif.w_strb);
      wdat.m_last.push_back(cfg.vif.w_last);
      wdat.m_w_user   = cfg.vif.w_user;

      wdat.m_txn_type = AXI_WRITE_REQ;
      write_dat_queue.push_back(wdat);

    end  // if
  end  // forever

endtask

task axi_slv_driver::send_back_write_response();
  axi_slv_item  wreq_addr;
  axi_slv_item  wreq_data;
  axi_slv_item  wreq_txn;

  axi_sig_len_t req_len;

  forever begin
    wreq_addr = new();

    // Waiting for a new write address request
    wait (write_req_queue.size() != 0);
    wreq_addr = write_req_queue.pop_front();
    $cast(wreq_txn, wreq_addr.clone());
    req_len = wreq_txn.m_len;

    // For each packet of a burst of a write data request, get the
    // data packet transaction from the queue
    for (int i = 0; i < wreq_addr.m_len + 1; i++) begin
      wreq_data = new();
      // Waiting for a new write data request
      wait (write_dat_queue.size() != 0);
      wreq_data = write_dat_queue.pop_front();

      // Creating a new object to send to the scoreboard,
      // and get requests informations into it by combining
      // write address and write data requests informations
      wreq_txn.append_write_flit(wreq_data.m_data[0], wreq_data.m_wstrb[0], wreq_data.m_last[0]);

      // Fixing the change of len introduced by the append_write_flit
      // function
      wreq_txn.m_len = req_len;

    end  // for

    // store req in fifo
    slv_req_fifo.push_back(wreq_txn);
    `uvm_info(`gfn, $sformatf("Send write req:\n%0s", wreq_txn.convert2string()), UVM_HIGH)

  end  // forever

endtask


task axi_slv_driver::drive_B_channel();
  axi_slv_item b_txn;

  `uvm_info(`gfn, "drive_B_channel task is starting", UVM_DEBUG)
  forever begin

    // Drive bus signals to idle while waiting for a transaction.
    drive_B_channel_signals();

    // Waiting and extracting the last request from the queue
    wait (b_txn_queue.size() != 0);
    b_txn = b_txn_queue.pop_back();

    // Applying the delay of the transaction before enabling the valid
    // signal
    if (b_txn.m_delay_cycle_chan_X != 0) cfg.vif.wait_n_clock_cycle(b_txn.m_delay_cycle_chan_X);

    // Driving all the signals of the interface with the transaction
    drive_B_channel_signals(b_txn);

    // Handshake process
    cfg.vif.b_valid <= 1;
    do begin
      @(posedge cfg.vif.clk_i);
    end while (cfg.vif.b_ready == 0);

    // End of the transaction
    cfg.vif.b_valid <= 0;

  end  // forever

endtask

task axi_slv_driver::receive_AR_channel();
  axi_slv_item rreq;

  forever begin
    @(posedge cfg.vif.clk_i);

    // -----------------------------------------------------------------------
    // Collect request on Read Address channel
    // -----------------------------------------------------------------------
    if (cfg.vif.ar_valid && cfg.vif.ar_ready) begin


      // Creating a new object to send to the scoreboard,
      // and get requests informations into it
      rreq            = new();
      rreq.m_id       = cfg.vif.ar_id;
      rreq.m_addr     = cfg.vif.ar_addr;
      rreq.m_len      = cfg.vif.ar_len;
      rreq.m_size     = axi_dv_size_t'(cfg.vif.ar_size);
      rreq.m_burst    = axi_dv_burst_t'(cfg.vif.ar_burst);
      rreq.m_lock     = axi_dv_lock_t'(cfg.vif.ar_lock);
      rreq.m_cache    = cfg.vif.ar_cache;
      rreq.m_mem_type = get_mem_type(AXI_READ_REQ, cfg.vif.ar_cache);
      rreq.m_prot     = axi_dv_prot_t'(cfg.vif.ar_prot);
      rreq.m_qos      = cfg.vif.ar_qos;
      rreq.m_region   = cfg.vif.ar_region;
      rreq.m_user     = cfg.vif.ar_user;

      rreq.m_txn_type = AXI_READ_REQ;

      // store req in fifo
      slv_req_fifo.push_back(rreq);
      `uvm_info(`gfn, $sformatf("Send read req:\n%0s", rreq.convert2string()), UVM_HIGH)

    end  // if
  end  // forever

endtask

task axi_slv_driver::drive_R_channel();
  axi_slv_item r_txn;
  axi_slv_item r_flit;

  `uvm_info(`gfn, "drive_R_channel task is starting", UVM_DEBUG)
  forever begin

    // Drive bus signals to idle while waiting for a transaction.
    drive_R_channel_signals();

    // Waiting and extracting the last request from the queue
    wait (r_txn_queue.size() != 0);
    r_txn = r_txn_queue.pop_back();

    // Applying the delay of the transaction before enabling the valid
    // signal
    if (r_txn.m_delay_cycle_chan_X != 0) cfg.vif.wait_n_clock_cycle(r_txn.m_delay_cycle_chan_X);

    for (int i = 0; i < r_txn.m_data.size(); i++) begin
      // Driving each flit of the transaction on the interface
      r_flit      = new();
      r_flit.m_id = r_txn.m_id;
      r_flit.m_data.push_front(r_txn.m_data[i]);
      r_flit.m_last.push_front(r_txn.m_last[i]);
      r_flit.m_resp.push_front(r_txn.m_resp[i]);
      r_flit.m_user = r_txn.m_user;

      // Driving the flit signals on the interface
      drive_R_channel_signals(r_flit);

      // Handshake process
      cfg.vif.r_valid <= 1;
      do begin
        @(posedge cfg.vif.clk_i);
      end while (cfg.vif.r_ready == 0);

      // End of the first flit transaction
      cfg.vif.r_valid <= 0;
      if (r_txn.m_delay_cycle_flits[i] != 0) cfg.vif.wait_n_clock_cycle(r_txn.m_delay_cycle_flits[i]);

    end  // for
    cfg.vif.r_last <= 0;

  end  // forever

endtask

task axi_slv_driver::AW_channel_ready_rsp();
  int unsigned aw_ready_delay;

  forever begin
    aw_ready_delay = $urandom_range(cfg.aw_ready_delay_min, cfg.aw_ready_delay_max);

    repeat (aw_ready_delay) begin
      @(posedge cfg.vif.clk_i);
    end

    cfg.vif.aw_ready <= 1'b1;
    @(posedge cfg.vif.clk_i);
    cfg.vif.aw_ready <= 1'b0;
  end
endtask

task axi_slv_driver::W_channel_ready_rsp();
  int unsigned w_ready_delay;

  forever begin
    w_ready_delay = $urandom_range(cfg.w_ready_delay_min, cfg.w_ready_delay_max);

    repeat (w_ready_delay) begin
      @(posedge cfg.vif.clk_i);
    end

    cfg.vif.w_ready <= 1'b1;
    @(posedge cfg.vif.clk_i);
    cfg.vif.w_ready <= 1'b0;
  end
endtask

task axi_slv_driver::AR_channel_ready_rsp();
  int unsigned ar_ready_delay;

  forever begin
    ar_ready_delay = $urandom_range(cfg.ar_ready_delay_min, cfg.ar_ready_delay_max);

    repeat (ar_ready_delay) begin
      @(posedge cfg.vif.clk_i);
    end

    cfg.vif.ar_ready <= 1'b1;
    @(posedge cfg.vif.clk_i);
    cfg.vif.ar_ready <= 1'b0;
  end
endtask

