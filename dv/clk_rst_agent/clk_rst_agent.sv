// Copyright lowRISC contributors (OpenTitan project).
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

class clk_rst_agent extends dv_base_agent #(
  .CFG_T          (clk_rst_agent_cfg),
  .DRIVER_T       (clk_rst_driver),
  .SEQUENCER_T    (clk_rst_sequencer),
  .MONITOR_T      (clk_rst_monitor),
  .COV_T          (clk_rst_agent_cov)
);

  `uvm_component_utils(clk_rst_agent)

  `uvm_component_new

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    // get clk_rst_if handle
    if (!uvm_config_db#(virtual clk_rst_if)::get(this, "", "vif", cfg.vif)) begin
      `uvm_fatal(`gfn, "failed to get clk_rst_if handle from uvm_config_db")
    end
  endfunction

endclass
