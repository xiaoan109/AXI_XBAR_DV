class axi_mst_write_seq  extends axi_mst_random_seq;
  `uvm_object_utils(axi_mst_write_seq)

  // -----------------------------------------------------------------------
  // Constructor
  // -----------------------------------------------------------------------
  function new(string name = "axi_mst_write_seq", int number_txn = -1 );
      super.new(name, number_txn);
  endfunction:new

  // -----------------------------------------------------------------------
  // Body
  // -----------------------------------------------------------------------
  virtual task body( );
    // super.body();
    `uvm_info(`gfn, "Sequence axi_mst_write_seq is starting", UVM_DEBUG)

    // Sending `num_txn random write only transactions
    for ( int i = 0 ; i < num_txn ; i++ ) begin
      send_uniflit_write(.txn_number(i));
    end
    // Waiting for the reception of all responses
    wait( num_txn == num_rsp );
    `uvm_info(`gfn, "Sequence axi_mst_write_seq is ending", UVM_DEBUG)
  endtask: body

endclass: axi_mst_write_seq