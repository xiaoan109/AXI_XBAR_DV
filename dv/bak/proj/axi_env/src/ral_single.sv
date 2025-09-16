//
// Template for UVM-compliant RAL adapter sequence

class ral_adp extends uvm_reg_adapter;

`uvm_object_utils(ral_adp)

 function new (string name="");
   super.new(name);
 endfunction
 
   
 virtual function uvm_sequence_item reg2bus(const ref uvm_reg_bus_op rw);
  master_txn tr;
  tr = master_txn::type_id::create("tr"); 
  tr.kind = (rw.kind == UVM_READ) ? master_txn::READ : master_txn::WRITE; 
//  tr.addr = rw.addr;
//  tr.data = rw.data;
  return tr;
 endfunction

 virtual function void bus2reg (uvm_sequence_item bus_item,
                                ref uvm_reg_bus_op rw);
  master_txn tr;
  if (!$cast(tr, bus_item))
   `uvm_fatal("NOT_HOST_REG_TYPE", "bus_item is not correct type");
  rw.kind = tr.kind ? UVM_READ : UVM_WRITE;
//  rw.addr = tr.addr;
//  rw.data = tr.data;
//  rw.status = UVM_IS_OK;
 endfunction

endclass: ral_adp
