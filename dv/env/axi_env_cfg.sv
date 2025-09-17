// Copyright lowRISC contributors (OpenTitan project).
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

class axi_env_cfg extends dv_base_env_cfg;

  // ext component cfgs
  rand axi_mst_agent_cfg m_axi_mst_agent_cfg;
  rand axi_slv_agent_cfg m_axi_slv_agent_cfg;

  // RAL indicator
  bit has_ral;

  `uvm_object_utils_begin(axi_env_cfg)
    `uvm_field_object(m_axi_mst_agent_cfg, UVM_DEFAULT)
    `uvm_field_object(m_axi_slv_agent_cfg, UVM_DEFAULT)
    `uvm_field_int(has_ral, UVM_DEFAULT)
  `uvm_object_utils_end

  `uvm_object_new

  virtual function void initialize(bit [31:0] csr_base_addr = '1);
    // add super initialize call
    // super.initialize();
    is_initialized = 1'b1;
    // currently no ral
    ral_model_names.delete();
    // create axi_mst agent config obj
    m_axi_mst_agent_cfg = axi_mst_agent_cfg::type_id::create("m_axi_mst_agent_cfg");
    // create axi_slv agent config obj
    m_axi_slv_agent_cfg = axi_slv_agent_cfg::type_id::create("m_axi_slv_agent_cfg");
  endfunction

endclass
