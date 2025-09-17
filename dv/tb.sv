// Copyright lowRISC contributors (OpenTitan project).
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0
//
module tb;
  // dep packages
  import uvm_pkg::*;
  import dv_utils_pkg::*;
  import axi_env_pkg::*;
  import axi_test_pkg::*;

  // macro includes
  `include "uvm_macros.svh"
  `include "dv_macros.svh"

  wire clk, rst_n;

  // interfaces
  clk_rst_if clk_rst_if(.clk(clk), .rst_n(rst_n));
  axi_mst_if axi_mst_if();
  axi_slv_if axi_slv_if();


  // dut
  // axi dut (
  //   .clk_i                (clk      ),
  //   // TODO: add remaining IOs and hook them
  // );

  initial begin
    // drive clk and rst_n from clk_if
    clk_rst_if.set_active();
    uvm_config_db#(virtual clk_rst_if)::set(null, "*.env", "clk_rst_vif", clk_rst_if);
    uvm_config_db#(virtual axi_mst_if)::set(null, "*.env.m_axi_mst_agent*", "vif", axi_mst_if);
    uvm_config_db#(virtual axi_slv_if)::set(null, "*.env.m_axi_slv_agent*", "vif", axi_slv_if);
    $timeformat(-12, 0, " ps", 12);
    run_test();
  end

endmodule
