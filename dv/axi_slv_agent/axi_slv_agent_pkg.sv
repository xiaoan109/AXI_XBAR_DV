// Copyright lowRISC contributors (OpenTitan project).
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

package axi_slv_agent_pkg;
  // dep packages
  import uvm_pkg::*;
  import dv_utils_pkg::*;
  import dv_lib_pkg::*;
  import axi_xbar_dv_pkg::*;

  // macro includes
  `include "uvm_macros.svh"
  `include "dv_macros.svh"

  // parameters

  // local types
  // forward declare classes to allow typedefs below
  typedef class axi_slv_item;
  typedef class axi_slv_agent_cfg;

  // reuse dv_base_sequencer as is with the right parameter set
  typedef dv_base_sequencer #(.ITEM_T(axi_slv_item),
                              .CFG_T (axi_slv_agent_cfg)) axi_slv_sequencer;

  // virtual intf
  typedef virtual axi_slv_if#(AXI_ADDR_WIDTH, AXI_DATA_WIDTH, AXI_ID_WIDTH + $clog2(NUM_MASTERS), AXI_USER_WIDTH) axi_slv_vif;

  // functions

  // package sources
  `include "axi_slv_item.sv"
  `include "axi_slv_agent_cfg.sv"
  `include "axi_slv_agent_cov.sv"
  `include "axi_slv_driver.sv"
  `include "axi_slv_monitor.sv"
  `include "axi_slv_agent.sv"
  `include "axi_slv_seq_list.sv"

endpackage: axi_slv_agent_pkg
