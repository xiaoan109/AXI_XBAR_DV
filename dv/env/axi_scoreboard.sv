// Copyright lowRISC contributors (OpenTitan project).
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

class axi_scoreboard extends dv_base_scoreboard #(
    .CFG_T(axi_env_cfg),
    .COV_T(axi_env_cov)
  );
  `uvm_component_utils(axi_scoreboard)

  // local variables

  // TLM agent fifos
  uvm_tlm_analysis_fifo #(axi_mst_item) axi_mst_fifo;
  uvm_tlm_analysis_fifo #(axi_slv_item) axi_slv_fifo;

  // local queues to hold incoming packets pending comparison
  axi_mst_item axi_mst_q[$];
  axi_slv_item axi_slv_q[$];

  `uvm_component_new

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    axi_mst_fifo = new("axi_mst_fifo", this);
    axi_slv_fifo = new("axi_slv_fifo", this);
  endfunction

  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
  endfunction

  task run_phase(uvm_phase phase);
    super.run_phase(phase);
    fork
      process_axi_mst_fifo();
      process_axi_slv_fifo();
    join_none
  endtask

  virtual task process_axi_mst_fifo();
    axi_mst_item item;
    forever begin
      axi_mst_fifo.get(item);
      `uvm_info(`gfn, $sformatf("received axi_mst item:\n%0s", item.sprint()), UVM_HIGH)
    end
  endtask

  virtual task process_axi_slv_fifo();
    axi_slv_item item;
    forever begin
      axi_slv_fifo.get(item);
      `uvm_info(`gfn, $sformatf("received axi_slv item:\n%0s", item.sprint()), UVM_HIGH)
    end
  endtask

  virtual function void reset(string kind = "HARD");
    super.reset(kind);
    // reset local fifos queues and variables
  endfunction

  function void check_phase(uvm_phase phase);
    super.check_phase(phase);
    // post test checks - ensure that all local fifos and queues are empty
  endfunction

endclass
