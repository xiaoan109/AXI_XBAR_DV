//
// Template for UVM-compliant Monitor to Coverage Connector Callbacks
//

`ifndef MASTER_MONITOR_2COV_CONNECT
`define MASTER_MONITOR_2COV_CONNECT
class master_monitor_2cov_connect extends uvm_component;
   axi_env_cov cov;
   uvm_analysis_export # (master_txn) an_exp;
   `uvm_component_utils(master_monitor_2cov_connect)
   function new(string name="", uvm_component parent=null);
   	super.new(name, parent);
   endfunction: new

   virtual function void write(master_txn tr);
      cov.tr = tr;
      -> cov.cov_event;
   endfunction:write 
endclass: master_monitor_2cov_connect

`endif // MASTER_MONITOR_2COV_CONNECT
