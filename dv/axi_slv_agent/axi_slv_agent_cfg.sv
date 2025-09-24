// Copyright lowRISC contributors (OpenTitan project).
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

class axi_slv_agent_cfg extends dv_base_agent_cfg;

  // interface handle used by driver, monitor & the sequencer, via cfg handle
  axi_slv_vif  vif;
  int unsigned aw_ready_delay_min;
  int unsigned aw_ready_delay_max;
  int unsigned w_ready_delay_min;
  int unsigned w_ready_delay_max;
  int unsigned ar_ready_delay_min;
  int unsigned ar_ready_delay_max;

  `uvm_object_utils_begin(axi_slv_agent_cfg)
  `uvm_object_utils_end

  `uvm_object_new

endclass
