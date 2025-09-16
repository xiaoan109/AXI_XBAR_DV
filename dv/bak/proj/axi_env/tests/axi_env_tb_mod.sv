//
// Template for UVM-compliant Program block

`ifndef AXI_ENV_TB_MOD__SV
`define AXI_ENV_TB_MOD__SV

`include "mstr_slv_intfs.incl"
module axi_env_tb_mod;

import uvm_pkg::*;

`include "axi_env_ral_env.sv"
`include "axi_env_test.sv"  //ToDo: Change this name to the testcase file-name

// ToDo: Include all other test list here
   typedef virtual master_intf v_if1;
   typedef virtual slave_intf v_if2;
   initial begin
      uvm_config_db #(v_if1)::set(null,"","mst_if",axi_env_top.mst_if); 
      uvm_config_db #(v_if2)::set(null,"","slv_if",axi_env_top.slv_if);
      run_test();
   end

endmodule: axi_env_tb_mod

`endif // AXI_ENV_TB_MOD__SV

