// Copyright lowRISC contributors (OpenTitan project).
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

class axi_mst_agent extends dv_base_agent #(
  .CFG_T          (axi_mst_agent_cfg),
  .DRIVER_T       (axi_mst_driver),
  .SEQUENCER_T    (axi_mst_sequencer),
  .MONITOR_T      (axi_mst_monitor),
  .COV_T          (axi_mst_agent_cov)
);

  `uvm_component_utils(axi_mst_agent)

  `uvm_component_new

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    // get axi_mst_if handle
    if (!uvm_config_db#(virtual axi_mst_if)::get(this, "", "vif", cfg.vif)) begin
      `uvm_fatal(`gfn, "failed to get axi_mst_if handle from uvm_config_db")
    end
  endfunction

endclass
