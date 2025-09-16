//
// Template for UVM-compliant transaction descriptor


`ifndef SLAVE_TXN__SV
`define SLAVE_TXN__SV


class slave_txn extends uvm_sequence_item;

   typedef enum {READ, WRITE } kinds_e;
   rand kinds_e kind;
   typedef enum {IS_OK, ERROR} status_e;
   rand status_e status;
   rand byte sa;

   // ToDo: Add constraint blocks to prevent error injection
   // ToDo: Add relevant class properties to define all transactions
   // ToDo: Modify/add symbolic transaction identifiers to match

   constraint slave_txn_valid {
      // ToDo: Define constraint to make descriptor valid
      status == IS_OK;
   }
   `uvm_object_utils_begin(slave_txn) 

      // ToDo: add properties using macros here
   
      `uvm_field_enum(kinds_e,kind,UVM_ALL_ON)
      `uvm_field_enum(status_e,status, UVM_ALL_ON)
   `uvm_object_utils_end
 
   extern function new(string name = "Trans");
endclass: slave_txn


function slave_txn::new(string name = "Trans");
   super.new(name);
endfunction: new


`endif // SLAVE_TXN__SV
