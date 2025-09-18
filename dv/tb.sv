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
  import axi_xbar_dv_pkg::*;

  // macro includes
  `include "uvm_macros.svh"
  `include "dv_macros.svh"

  wire clk, rst_n;

  // axi xbar parameters

  // interfaces
  clk_rst_if clk_rst_if(.clk(clk), .rst_n(rst_n));
  AXI_BUS #(AXI_ADDR_WIDTH, AXI_DATA_WIDTH, AXI_ID_WIDTH, AXI_USER_WIDTH) master [NUM_MASTERS-1:0] ();
  AXI_BUS #(AXI_ADDR_WIDTH, AXI_DATA_WIDTH, AXI_ID_WIDTH + $clog2(NUM_MASTERS), AXI_USER_WIDTH) slave [NUM_SLAVES-1:0] ();
  axi_mst_if #(AXI_ADDR_WIDTH, AXI_DATA_WIDTH, AXI_ID_WIDTH, AXI_USER_WIDTH) axi_mst_if [NUM_MASTERS-1:0] (clk);
  axi_slv_if #(AXI_ADDR_WIDTH, AXI_DATA_WIDTH, AXI_ID_WIDTH + $clog2(NUM_MASTERS), AXI_USER_WIDTH) axi_slv_if [NUM_SLAVES-1:0] (clk);
  `include "axi/assign.svh"
  for (genvar i = 0; i < NUM_MASTERS; i++) begin : gen_conn_dv_masters
    `AXI_ASSIGN(master[i], axi_mst_if[i])
  end
  for (genvar i = 0; i < NUM_SLAVES; i++) begin : gen_conn_dv_slaves
    `AXI_ASSIGN(axi_slv_if[i], slave[i])
  end


  // dut
  // axi dut (
  //   .clk_i                (clk      ),
  //   // TODO: add remaining IOs and hook them
  // );


  axi_xbar_intf #(
    .AXI_USER_WIDTH(AXI_USER_WIDTH),
    .Cfg(Cfg),
    .ATOPS(ATOPS),
    .CONNECTIVITY(CONNECTIVITY),
    .rule_t(rule_t)
  ) dut (
    .clk_i(clk),
    .rst_ni(rst_n),
    .test_i(1'b0),
    .slv_ports(master),
    .mst_ports(slave),
    .addr_map_i(AddrMap),
    .en_default_mst_port_i('0),
    .default_mst_port_i('0)
  );

  initial begin
    // drive clk and rst_n from clk_if
    clk_rst_if.set_active();
    uvm_config_db#(virtual clk_rst_if)::set(null, "*.env", "clk_rst_vif", clk_rst_if);
    uvm_config_db#(virtual axi_mst_if #(AXI_ADDR_WIDTH, AXI_DATA_WIDTH, AXI_ID_WIDTH, AXI_USER_WIDTH))::set(null, "*.env.m_axi_mst_agent*", "vif", axi_mst_if[0]);
    uvm_config_db#(virtual axi_slv_if #(AXI_ADDR_WIDTH, AXI_DATA_WIDTH, AXI_ID_WIDTH + $clog2(NUM_MASTERS), AXI_USER_WIDTH))::set(null, "*.env.m_axi_slv_agent*", "vif", axi_slv_if[0]);
    $timeformat(-12, 0, " ps", 12);
    run_test();
  end

endmodule
