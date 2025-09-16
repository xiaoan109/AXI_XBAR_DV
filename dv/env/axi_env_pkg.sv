// Copyright lowRISC contributors (OpenTitan project).
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

package axi_env_pkg;
  // dep packages
  import uvm_pkg::*;
  import top_pkg::*;
  import dv_utils_pkg::*;
  import axi_mst_agent_pkg::*;
  import axi_slv_agent_pkg::*;
  import clk_rst_agent_pkg::*;
  import dv_lib_pkg::*;

  // macro includes
  `include "uvm_macros.svh"
  `include "dv_macros.svh"

  // parameters

  // types
  typedef dv_base_reg_block axi_reg_block;

  // functions

  // package sources
  `include "axi_env_cfg.sv"
  `include "axi_env_cov.sv"
  `include "axi_virtual_sequencer.sv"
  `include "axi_scoreboard.sv"
  `include "axi_env.sv"
  `include "axi_vseq_list.sv"

endpackage
