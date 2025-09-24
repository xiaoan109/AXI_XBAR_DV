class axi_slv_sequencer extends dv_base_sequencer #(
    .ITEM_T(axi_slv_item),
    .CFG_T (axi_slv_agent_cfg)
);

  `uvm_component_utils(axi_slv_sequencer)

  uvm_blocking_get_port #(axi_slv_item) get_port;

  `uvm_component_new

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    get_port = new("get_port", this);
  endfunction

  virtual task wait_for_req(uvm_sequence_base seq, output axi_slv_item req);
    wait_for_grant(seq);
    get_port.get(req);
  endtask

  virtual task send_rsp(uvm_sequence_base seq, axi_slv_item rsp);
    rsp.set_item_context(seq);
    seq.finish_item(rsp);
  endtask

endclass
