//
// Template for Top module
//

`ifndef AXI_ENV_TOP__SV
`define AXI_ENV_TOP__SV

module axi_env_top();

   logic clk;
   logic rst;

   // Clock Generation
   parameter sim_cycle = 10;
   
   // Reset Delay Parameter
   parameter rst_delay = 50;

   always 
      begin
         #(sim_cycle/2) clk = ~clk;
      end

   master_intf mst_if(clk,rst);
   slave_intf slv_if(clk,rst);
   
   axi_env_tb_mod test(); 
   
   // ToDo: Include Dut instance here
  
   //Driver reset depending on rst_delay
   initial
      begin
         clk = 0;
         rst = 0;
      #1 rst = 1;
         repeat (rst_delay) @(clk);
         rst = 1'b0;
         @(clk);
   end

endmodule: axi_env_top

`endif // AXI_ENV_TOP__SV
