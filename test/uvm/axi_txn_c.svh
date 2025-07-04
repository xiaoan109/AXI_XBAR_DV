// AXI transaction class
class axi_txn_c extends uvm_sequence_item;
    protected string name;

    // AXI4 fileds
    rand axi_dv_txn_type_t m_txn_type;

endclass