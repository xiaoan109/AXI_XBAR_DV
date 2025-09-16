// Copyright lowRISC contributors (OpenTitan project).
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

class axi_slv_agent extends dv_base_agent #(
  .CFG_T          (axi_slv_agent_cfg),
  .DRIVER_T       (axi_slv_driver),
  .SEQUENCER_T    (axi_slv_sequencer),
  .MONITOR_T      (axi_slv_monitor),
  .COV_T          (axi_slv_agent_cov)
);

  `uvm_component_utils(axi_slv_agent)

  `uvm_component_new

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    // get axi_slv_if handle
    if (!uvm_config_db#(virtual axi_slv_if)::get(this, "", "vif", cfg.vif)) begin
      `uvm_fatal(`gfn, "failed to get axi_slv_if handle from uvm_config_db")
    end
  endfunction

endclass
