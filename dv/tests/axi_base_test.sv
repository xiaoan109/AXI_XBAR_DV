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
  endfunction
  // the base class also looks up UVM_TEST_SEQ plusarg to create and run that seq in
  // the run_phase; as such, nothing more needs to be done

endclass : axi_base_test
