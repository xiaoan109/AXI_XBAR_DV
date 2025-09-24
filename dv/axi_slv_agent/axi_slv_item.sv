// Copyright lowRISC contributors (OpenTitan project).
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

// class axi_slv_item extends uvm_sequence_item;

//   // random variables

//   `uvm_object_utils_begin(axi_slv_item)
//   `uvm_object_utils_end

//   `uvm_object_new

// endclass


// currently axi_slv_item is the as axi_mst_item
class axi_slv_item extends axi_mst_agent_pkg::axi_mst_item;

  // random variables

  `uvm_object_utils_begin(axi_slv_item)
  `uvm_object_utils_end

  `uvm_object_new

endclass

