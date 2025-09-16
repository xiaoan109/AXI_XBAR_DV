// Copyright lowRISC contributors (OpenTitan project).
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

class clk_rst_base_seq extends dv_base_seq #(
    .REQ         (clk_rst_item),
    .CFG_T       (clk_rst_agent_cfg),
    .SEQUENCER_T (clk_rst_sequencer)
  );
  `uvm_object_utils(clk_rst_base_seq)

  `uvm_object_new

  virtual task body();
    `uvm_fatal(`gtn, "Need to override this when you extend from this class!")
  endtask

endclass
