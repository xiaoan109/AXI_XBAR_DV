// Copyright lowRISC contributors (OpenTitan project).
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

interface axi_mst_if #(  
  parameter int unsigned AXI_ADDR_WIDTH = 0,
  parameter int unsigned AXI_DATA_WIDTH = 0,
  parameter int unsigned AXI_ID_WIDTH   = 0,
  parameter int unsigned AXI_USER_WIDTH = 0
)(
  input logic clk_i,
  input logic rst_ni
);

  localparam int unsigned AXI_STRB_WIDTH = AXI_DATA_WIDTH / 8;

  typedef logic [AXI_ID_WIDTH-1:0]   id_t;
  typedef logic [AXI_ADDR_WIDTH-1:0] addr_t;
  typedef logic [AXI_DATA_WIDTH-1:0] data_t;
  typedef logic [AXI_STRB_WIDTH-1:0] strb_t;
  typedef logic [AXI_USER_WIDTH-1:0] user_t;

  // interface pins
  id_t              aw_id;
  addr_t            aw_addr;
  axi_pkg::len_t    aw_len;
  axi_pkg::size_t   aw_size;
  axi_pkg::burst_t  aw_burst;
  logic             aw_lock;
  axi_pkg::cache_t  aw_cache;
  axi_pkg::prot_t   aw_prot;
  axi_pkg::qos_t    aw_qos;
  axi_pkg::region_t aw_region;
  axi_pkg::atop_t   aw_atop;
  user_t            aw_user;
  logic             aw_valid;
  logic             aw_ready;

  data_t            w_data;
  strb_t            w_strb;
  logic             w_last;
  user_t            w_user;
  logic             w_valid;
  logic             w_ready;

  id_t              b_id;
  axi_pkg::resp_t   b_resp;
  user_t            b_user;
  logic             b_valid;
  logic             b_ready;

  id_t              ar_id;
  addr_t            ar_addr;
  axi_pkg::len_t    ar_len;
  axi_pkg::size_t   ar_size;
  axi_pkg::burst_t  ar_burst;
  logic             ar_lock;
  axi_pkg::cache_t  ar_cache;
  axi_pkg::prot_t   ar_prot;
  axi_pkg::qos_t    ar_qos;
  axi_pkg::region_t ar_region;
  user_t            ar_user;
  logic             ar_valid;
  logic             ar_ready;

  id_t              r_id;
  data_t            r_data;
  axi_pkg::resp_t   r_resp;
  logic             r_last;
  user_t            r_user;
  logic             r_valid;
  logic             r_ready;


  // debug signals



  // pragma translate_off
  `ifndef VERILATOR
  // Single-Channel Assertions: Signals including valid must not change between valid and handshake.
  // AW
  assert property (@(posedge clk_i) (aw_valid && !aw_ready |=> $stable(aw_id)));
  assert property (@(posedge clk_i) (aw_valid && !aw_ready |=> $stable(aw_addr)));
  assert property (@(posedge clk_i) (aw_valid && !aw_ready |=> $stable(aw_len)));
  assert property (@(posedge clk_i) (aw_valid && !aw_ready |=> $stable(aw_size)));
  assert property (@(posedge clk_i) (aw_valid && !aw_ready |=> $stable(aw_burst)));
  assert property (@(posedge clk_i) (aw_valid && !aw_ready |=> $stable(aw_lock)));
  assert property (@(posedge clk_i) (aw_valid && !aw_ready |=> $stable(aw_cache)));
  assert property (@(posedge clk_i) (aw_valid && !aw_ready |=> $stable(aw_prot)));
  assert property (@(posedge clk_i) (aw_valid && !aw_ready |=> $stable(aw_qos)));
  assert property (@(posedge clk_i) (aw_valid && !aw_ready |=> $stable(aw_region)));
  assert property (@(posedge clk_i) (aw_valid && !aw_ready |=> $stable(aw_atop)));
  assert property (@(posedge clk_i) (aw_valid && !aw_ready |=> $stable(aw_user)));
  assert property (@(posedge clk_i) (aw_valid && !aw_ready |=> aw_valid));
  // W
  assert property (@(posedge clk_i) ( w_valid && ! w_ready |=> $stable(w_data)));
  assert property (@(posedge clk_i) ( w_valid && ! w_ready |=> $stable(w_strb)));
  assert property (@(posedge clk_i) ( w_valid && ! w_ready |=> $stable(w_last)));
  assert property (@(posedge clk_i) ( w_valid && ! w_ready |=> $stable(w_user)));
  assert property (@(posedge clk_i) ( w_valid && ! w_ready |=> w_valid));
  // B
  assert property (@(posedge clk_i) ( b_valid && ! b_ready |=> $stable(b_id)));
  assert property (@(posedge clk_i) ( b_valid && ! b_ready |=> $stable(b_resp)));
  assert property (@(posedge clk_i) ( b_valid && ! b_ready |=> $stable(b_user)));
  assert property (@(posedge clk_i) ( b_valid && ! b_ready |=> b_valid));
  // AR
  assert property (@(posedge clk_i) (ar_valid && !ar_ready |=> $stable(ar_id)));
  assert property (@(posedge clk_i) (ar_valid && !ar_ready |=> $stable(ar_addr)));
  assert property (@(posedge clk_i) (ar_valid && !ar_ready |=> $stable(ar_len)));
  assert property (@(posedge clk_i) (ar_valid && !ar_ready |=> $stable(ar_size)));
  assert property (@(posedge clk_i) (ar_valid && !ar_ready |=> $stable(ar_burst)));
  assert property (@(posedge clk_i) (ar_valid && !ar_ready |=> $stable(ar_lock)));
  assert property (@(posedge clk_i) (ar_valid && !ar_ready |=> $stable(ar_cache)));
  assert property (@(posedge clk_i) (ar_valid && !ar_ready |=> $stable(ar_prot)));
  assert property (@(posedge clk_i) (ar_valid && !ar_ready |=> $stable(ar_qos)));
  assert property (@(posedge clk_i) (ar_valid && !ar_ready |=> $stable(ar_region)));
  assert property (@(posedge clk_i) (ar_valid && !ar_ready |=> $stable(ar_user)));
  assert property (@(posedge clk_i) (ar_valid && !ar_ready |=> ar_valid));
  // R
  assert property (@(posedge clk_i) ( r_valid && ! r_ready |=> $stable(r_id)));
  assert property (@(posedge clk_i) ( r_valid && ! r_ready |=> $stable(r_data)));
  assert property (@(posedge clk_i) ( r_valid && ! r_ready |=> $stable(r_resp)));
  assert property (@(posedge clk_i) ( r_valid && ! r_ready |=> $stable(r_last)));
  assert property (@(posedge clk_i) ( r_valid && ! r_ready |=> $stable(r_user)));
  assert property (@(posedge clk_i) ( r_valid && ! r_ready |=> r_valid));
  // Address-Channel Assertions: The address of the  last beat of a burst must be on the same 4 KiB
  // page as the address of the first beat of a burst. Bus is always word-aligned, word < page.
  assert property (@(posedge clk_i) aw_valid |-> (aw_burst != axi_pkg::BURST_INCR) || (
    axi_pkg::beat_addr(aw_addr, aw_size, aw_len, aw_burst, 0) >> 12 ==    // lowest beat address
    axi_pkg::beat_addr(aw_addr, aw_size, aw_len, aw_burst, aw_len) >> 12  // highest beat address
  )) else $error("AW burst crossing 4 KiB page boundary detected, which is illegal!");
  assert property (@(posedge clk_i) ar_valid |-> (ar_burst != axi_pkg::BURST_INCR) || (
    axi_pkg::beat_addr(ar_addr, ar_size, ar_len, ar_burst, 0) >> 12 ==    // lowest beat address
    axi_pkg::beat_addr(ar_addr, ar_size, ar_len, ar_burst, ar_len) >> 12  // highest beat address
  )) else $error("AR burst crossing 4 KiB page boundary detected, which is illegal!");
  `endif
  // pragma translate_on

  // task to wait a specific number of clock cycle
  task automatic wait_n_clock_cycle( int unsigned n_clock_cycle );
    for (int i = 0 ; i < n_clock_cycle ; i++) begin
      @(posedge clk_i);
    end
  endtask

endinterface
