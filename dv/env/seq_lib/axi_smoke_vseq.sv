// Copyright lowRISC contributors (OpenTitan project).
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

// smoke test vseq
class axi_smoke_vseq extends axi_base_vseq;
  `uvm_object_utils(axi_smoke_vseq)

  `uvm_object_new

  task body();
    // `uvm_error(`gfn, "FIXME")
    axi_mst_random_seq mst_seq;
    `uvm_create_obj(axi_mst_random_seq, mst_seq);
    mst_seq.start(p_sequencer.axi_mst_sequencer_h);
  endtask : body

endclass : axi_smoke_vseq
