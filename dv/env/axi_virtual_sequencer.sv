// Copyright lowRISC contributors (OpenTitan project).
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

class axi_virtual_sequencer extends dv_base_virtual_sequencer #(
    .CFG_T(axi_env_cfg),
    .COV_T(axi_env_cov)
  );
  `uvm_component_utils(axi_virtual_sequencer)

  axi_mst_sequencer axi_mst_sequencer_h;
  axi_slv_sequencer axi_slv_sequencer_h;
  clk_rst_sequencer clk_rst_sequencer_h;

  `uvm_component_new

endclass
