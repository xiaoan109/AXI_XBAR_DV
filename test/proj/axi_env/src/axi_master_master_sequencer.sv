//
// Template for UVM-compliant sequencer class
//


`ifndef MASTER_SEQUENCER__SV
`define MASTER_SEQUENCER__SV


typedef class master_txn;
class master_sequencer extends uvm_sequencer # (master_txn);

   `uvm_component_utils(master_sequencer)
   function new (string name,
                 uvm_component parent);
   super.new(name,parent);
   endfunction:new 
endclass:master_sequencer

`endif // MASTER_SEQUENCER__SV
