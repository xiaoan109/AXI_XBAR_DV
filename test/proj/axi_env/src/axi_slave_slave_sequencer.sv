//
// Template for UVM-compliant sequencer class
//


`ifndef SLAVE_SEQUENCER__SV
`define SLAVE_SEQUENCER__SV


typedef class slave_txn;
class slave_sequencer extends uvm_sequencer # (slave_txn);

   `uvm_component_utils(slave_sequencer)
   function new (string name,
                 uvm_component parent);
   super.new(name,parent);
   endfunction:new 
endclass:slave_sequencer

`endif // SLAVE_SEQUENCER__SV
