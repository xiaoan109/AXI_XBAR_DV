//
// Template for UVM Scoreboard

`ifndef AXI_SCB__SV
`define AXI_SCB__SV

   `uvm_analysis_imp_decl(_ingress)
   `uvm_analysis_imp_decl(_egress) 

class axi_scb extends uvm_scoreboard;

   uvm_analysis_imp_ingress #(master_txn,axi_scb) before_export;
   uvm_analysis_imp_egress #(slave_txn,axi_scb) after_export;
   // Built in UVM comparator will not be used. User has to define the compare logic

   `uvm_component_utils(axi_scb)
	extern function new(string name = "axi_scb",
                    uvm_component parent = null); 
	extern virtual function void build_phase (uvm_phase phase);
	extern virtual function void connect_phase (uvm_phase phase);
	extern virtual task main_phase(uvm_phase phase);
	extern virtual function void report_phase(uvm_phase phase);
 	extern function void write_ingress(master_txn tr);
	extern function void write_egress(slave_txn tr);

endclass: axi_scb


function axi_scb::new(string name = "axi_scb",
                 uvm_component parent);
   super.new(name,parent);
endfunction: new

function void axi_scb::build_phase(uvm_phase phase);
    super.build_phase(phase);
    before_export = new("before_export", this);
    after_export  = new("after_export", this);
endfunction:build_phase

function void axi_scb::connect_phase(uvm_phase phase);
endfunction:connect_phase

task axi_scb::main_phase(uvm_phase phase);
    super.main_phase(phase);
    phase.raise_objection(this,"scbd..");
    phase.drop_objection(this);
endtask: main_phase 

function void axi_scb::report_phase(uvm_phase phase);
    super.report_phase(phase);
endfunction:report_phase

function void axi_scb::write_ingress(master_txn tr);
// User needs to add functionality here 
endfunction

function  void axi_scb::write_egress(slave_txn tr);
endfunction
`endif // AXI_SCB__SV
