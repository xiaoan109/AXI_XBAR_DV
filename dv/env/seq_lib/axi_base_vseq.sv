// Copyright lowRISC contributors (OpenTitan project).
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

class axi_base_vseq extends dv_base_vseq #(
    .CFG_T               (axi_env_cfg),
    .COV_T               (axi_env_cov),
    .VIRTUAL_SEQUENCER_T (axi_virtual_sequencer)
  );
  `uvm_object_utils(axi_base_vseq)

  // various knobs to enable certain routines
  bit do_axi_init = 1'b1;

  `uvm_object_new

  virtual task dut_init(string reset_kind = "HARD");
    super.dut_init();
    if (do_axi_init) axi_init();
  endtask

  virtual task dut_shutdown();
    // check for pending axi operations and wait for them to complete
    // TODO
  endtask

  // setup basic axi features
  virtual task axi_init();
    // `uvm_error(`gfn, "FIXME")
  endtask

endclass : axi_base_vseq
