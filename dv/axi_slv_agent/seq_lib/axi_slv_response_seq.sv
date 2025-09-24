class axi_slv_response_seq extends axi_slv_base_seq;

  `uvm_object_utils(axi_slv_response_seq)

  `uvm_object_new

  virtual task body();
    axi_slv_item req;
    axi_slv_item rsp;
    bit err;
    bit rw;
    forever begin
      `uvm_create_obj(axi_slv_item, req)
      `uvm_create_obj(axi_slv_item, rsp)
      p_sequencer.wait_for_req(this, req);
      // generate response to req
      if (req.m_txn_type == AXI_WRITE_REQ) begin
        rw = 1;
      end else if (req.m_txn_type == AXI_READ_REQ) begin
        rw = 0;
      end else begin
        err = 1;
      end
      if (!rsp.randomize() with {
            m_id == req.m_id;
            m_txn_type == ((rw == 1) ? AXI_WRITE_RSP : AXI_READ_RSP);
            m_len == ((rw == 1) ? 0 : req.m_len);
            // TODO: finish left variables
          }) begin
        `uvm_error(`gfn, "Randomize failed")
      end
      //   rsp.m_txn_type = (rw == 1) ? AXI_WRITE_RSP : AXI_READ_RSP;
      p_sequencer.send_rsp(this, rsp);
    end

  endtask

endclass
