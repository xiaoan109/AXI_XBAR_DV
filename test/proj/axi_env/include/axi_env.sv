//
// Template for UVM-compliant verification environment
//

`ifndef AXI_ENV__SV
`define AXI_ENV__SV




`include "mstr_slv_src.incl"

`include "axi_env_cfg.sv"


`include "axi_scb.sv"

`include "axi_env_cov.sv"

`include "mon_2cov.sv"


`include "ral_single.sv"
`include "ral_axi_env.sv"
// ToDo: Add additional required `include directives

`endif // AXI_ENV__SV
