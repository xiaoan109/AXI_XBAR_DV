// Copyright lowRISC contributors (OpenTitan project).
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

package axi_mst_agent_pkg;
  // dep packages
  import uvm_pkg::*;
  import dv_utils_pkg::*;
  import dv_lib_pkg::*;
  import axi_xbar_dv_pkg::*;

  // macro includes
  `include "uvm_macros.svh"
  `include "dv_macros.svh"

  // parameters
  parameter int unsigned AXI_ADDR_WIDTH = 32'd32;

  // local types
  // forward declare classes to allow typedefs below
  typedef class axi_mst_item;
  typedef class axi_mst_agent_cfg;

  // reuse dv_base_sequencer as is with the right parameter set
  typedef dv_base_sequencer #(.ITEM_T(axi_mst_item),
                              .CFG_T (axi_mst_agent_cfg)) axi_mst_sequencer;

  // virtual intf
  typedef virtual axi_mst_if#(AXI_ADDR_WIDTH, AXI_DATA_WIDTH, AXI_ID_WIDTH, AXI_USER_WIDTH) axi_mst_vif;

  // functions

  // package sources
  `include "axi_mst_item.sv"
  `include "axi_mst_agent_cfg.sv"
  `include "axi_mst_agent_cov.sv"
  `include "axi_mst_driver.sv"
  `include "axi_mst_monitor.sv"
  `include "axi_mst_agent.sv"
  `include "axi_mst_seq_list.sv"

endpackage: axi_mst_agent_pkg
