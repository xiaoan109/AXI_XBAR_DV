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

  // axi xbar parameters

  // Do not use axi user signals
  parameter int unsigned AXI_USER_WIDTH = 32'd1;
  parameter int unsigned NUM_MASTERS = 32'd1;
  parameter int unsigned NUM_SLAVES = 32'd1;
  parameter int unsigned MAX_MASTER_TRANS = 32'd8;
  parameter int unsigned MAX_SLAVE_TRANS = 32'd8;
  parameter bit FIFO_FALLTHROUGH = 1'b0;
  parameter bit [9:0] LATENCY_MODE = axi_pkg::CUT_ALL_AX;
  parameter int unsigned PIPE_STAGES = 32'd1;
  parameter int unsigned AXI_ID_WIDTH = 32'd8;
  parameter bit UNIQUE_IDS = 1'b0;
  parameter int unsigned AXI_ADDR_WIDTH = 32'd32;
  parameter int unsigned AXI_DATA_WIDTH = 32'd32;
  parameter int unsigned NUM_ADDR_RULES = NUM_SLAVES;
  // axi xbar cfg
  parameter axi_pkg::xbar_cfg_t Cfg = axi_pkg::xbar_cfg_t'{
    NoSlvPorts: NUM_MASTERS,
    NoMstPorts: NUM_SLAVES,
    MaxMstTrans: MAX_MASTER_TRANS,
    MaxSlvTrans: MAX_SLAVE_TRANS,
    FallThrough: FIFO_FALLTHROUGH,
    LatencyMode: LATENCY_MODE,
    PipelineStages: PIPE_STAGES,
    AxiIdWidthSlvPorts: AXI_ID_WIDTH,
    AxiIdUsedSlvPorts: AXI_ID_WIDTH,
    UniqueIds: UNIQUE_IDS,
    AxiAddrWidth: AXI_ADDR_WIDTH,
    AxiDataWidth: AXI_DATA_WIDTH,
    NoAddrRules: NUM_ADDR_RULES
  };
  // Currently no ATOPS
  parameter bit ATOPS = 1'b0;
  // Fully connected
  parameter bit [NUM_MASTERS-1:0][NUM_SLAVES-1:0] CONNECTIVITY = '1;

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

  typedef axi_pkg::xbar_rule_32_t         rule_t; // Has to be the same width as axi addr
  // Each slave has its own address range:
  localparam rule_t [NUM_ADDR_RULES-1:0] AddrMap = addr_map_gen();

  function rule_t [NUM_ADDR_RULES-1:0] addr_map_gen ();
    for (int unsigned i = 0; i < NUM_ADDR_RULES; i++) begin
      addr_map_gen[i] = rule_t'{
        idx:        unsigned'(i),
        start_addr:  i    * 32'h0000_2000,
        end_addr:   (i+1) * 32'h0000_2000,
        default:    '0
      };
    end
  endfunction


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
    .addr_map_i(),
    .en_default_mst_port_i(),
    .default_mst_port_i()
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
