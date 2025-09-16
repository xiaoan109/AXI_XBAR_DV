//
// Template for UVM-compliant Coverage Class
//

`ifndef AXI_ENV_COV__SV
`define AXI_ENV_COV__SV

class axi_env_cov extends uvm_component;
   event cov_event;
   master_txn tr;
   uvm_analysis_imp #(master_txn, axi_env_cov) cov_export;
   `uvm_component_utils(axi_env_cov)
 
   covergroup cg_trans @(cov_event);
      coverpoint tr.kind;
      // ToDo: Add required coverpoints, coverbins
   endgroup: cg_trans


   function new(string name, uvm_component parent);
      super.new(name,parent);
      cg_trans = new;
      cov_export = new("Coverage Analysis",this);
   endfunction: new

   virtual function write(master_txn tr);
      this.tr = tr;
      -> cov_event;
   endfunction: write

endclass: axi_env_cov

`endif // AXI_ENV_COV__SV

