// Copyright lowRISC contributors (OpenTitan project).
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

class axi_base_test extends dv_base_test #(
    .CFG_T(axi_env_cfg),
    .ENV_T(axi_env)
);

  `uvm_component_utils(axi_base_test)
  `uvm_component_new

  // the base class dv_base_test creates the following instances:
  // axi_env_cfg: cfg
  // axi_env:     env

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    cfg.has_ral = 1'b0;
    cfg.m_axi_mst_agent_cfg.b_ready_delay_min = 0;
    cfg.m_axi_mst_agent_cfg.b_ready_delay_max = 10;
    cfg.m_axi_mst_agent_cfg.r_ready_delay_min = 0;
    cfg.m_axi_mst_agent_cfg.r_ready_delay_max = 10;
    cfg.m_axi_slv_agent_cfg.aw_ready_delay_min = 0;
    cfg.m_axi_slv_agent_cfg.aw_ready_delay_max = 10;
    cfg.m_axi_slv_agent_cfg.w_ready_delay_min = 0;
    cfg.m_axi_slv_agent_cfg.w_ready_delay_max = 10;
    cfg.m_axi_slv_agent_cfg.ar_ready_delay_min = 0;
    cfg.m_axi_slv_agent_cfg.ar_ready_delay_max = 10;
    // create memory partitions
    cfg.m_memory_partitions = memory_partitions_cfg#(AXI_ADDR_WIDTH)::type_id::create("m_memory_partitions", this);
    if (!cfg.m_memory_partitions.randomize() with {
          m_mem_regions == MEM_CLOSE_REGIONS;
          m_base_addr == 0;
          m_max_mem_size == 32'h0000_4000;
          m_min_mem_size == 32'h0000_4000;
          m_max_partition_size == 32'h0000_2000;
          m_min_partition_size == 32'h0000_2000;
          m_max_num_partition == 2;
        }) begin
      `uvm_fatal("RANDOMIZE_FAILED", "MEMORY PARTITION");
    end
    cfg.m_memory_partitions.print_memconfig();
    cfg.m_axi_mst_agent_cfg.m_memory_partitions = cfg.m_memory_partitions;
  endfunction
  // the base class also looks up UVM_TEST_SEQ plusarg to create and run that seq in
  // the run_phase; as such, nothing more needs to be done

endclass : axi_base_test
