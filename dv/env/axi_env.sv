// Copyright lowRISC contributors (OpenTitan project).
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

class axi_env extends dv_base_env #(
    .CFG_T              (axi_env_cfg),
    .COV_T              (axi_env_cov),
    .VIRTUAL_SEQUENCER_T(axi_virtual_sequencer),
    .SCOREBOARD_T       (axi_scoreboard)
  );
  `uvm_component_utils(axi_env)

  axi_mst_agent m_axi_mst_agent;
  axi_slv_agent m_axi_slv_agent;

  `uvm_component_new

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    // create components
    m_axi_mst_agent = axi_mst_agent::type_id::create("m_axi_mst_agent", this);
    uvm_config_db#(axi_mst_agent_cfg)::set(this, "m_axi_mst_agent*", "cfg", cfg.m_axi_mst_agent_cfg);
    cfg.m_axi_mst_agent_cfg.en_cov = cfg.en_cov;
    // create components
    m_axi_slv_agent = axi_slv_agent::type_id::create("m_axi_slv_agent", this);
    uvm_config_db#(axi_slv_agent_cfg)::set(this, "m_axi_slv_agent*", "cfg", cfg.m_axi_slv_agent_cfg);
    cfg.m_axi_slv_agent_cfg.en_cov = cfg.en_cov;
  endfunction

  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    if (cfg.en_scb) begin
      m_axi_mst_agent.monitor.analysis_port.connect(scoreboard.axi_mst_fifo.analysis_export);
      m_axi_slv_agent.monitor.analysis_port.connect(scoreboard.axi_slv_fifo.analysis_export);
    end
    if (cfg.is_active && cfg.m_axi_mst_agent_cfg.is_active) begin
      virtual_sequencer.axi_mst_sequencer_h = m_axi_mst_agent.sequencer;
    end
    if (cfg.is_active && cfg.m_axi_slv_agent_cfg.is_active) begin
      virtual_sequencer.axi_slv_sequencer_h = m_axi_slv_agent.sequencer;
    end
  endfunction

endclass
