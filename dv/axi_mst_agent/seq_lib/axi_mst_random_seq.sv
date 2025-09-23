class axi_mst_random_seq extends axi_mst_base_seq;
  `uvm_object_utils(axi_mst_random_seq)

  // Number of sequence_item of the sequence
  int                    num_txn;
  int                    num_rsp;

  // With this variable enabled the responses are stored in an Assocaitive
  // Array. This can be used to retrieve the responses specially in the case
  // of read 
  protected bit          enable_manage_response;

  // Associative array of queues for storing the responses of each transactions,
  // for each type of transactions. Allows to to access the response 
  protected axi_mst_item write_rsp_queue        [axi_sig_id_t][$];
  protected axi_mst_item read_rsp_queue         [axi_sig_id_t][$];

  //memory region
  static int             region;

  function new(string name = "axi_mst_random_seq", int number_txn = -1);
    super.new(name);

    if (number_txn == -1) begin
      // Getting the number of transaction for the sequence from a plusargs 
      if (!$value$plusargs("NUM_TXN=%d", num_txn)) begin
        num_txn = 100;
      end  // if
    end else begin
      num_txn = number_txn;
    end
    `uvm_info(`gfn, $sformatf("NUM_TXN=%0d", num_txn), UVM_LOW);

    // Activating the response handler feature : the response handler
    // receives the responses from the driver and its processed by a call
    // back which is define below in the response_handler function.
    use_response_handler(1);

    // initialising the number of response
    num_rsp = 0;

  endfunction : new

  virtual task body();
    // super.body();
    `uvm_info(`gfn, "Sequence axi_mst_random_seq is starting", UVM_DEBUG)

    // Sending `num_txn random transactions
    for (int i = 0; i < num_txn; i++) begin
      send_uniflit_req(.txn_number(i));
    end
    // Waiting for the reception of all responses
    wait (num_txn == num_rsp);
    `uvm_info(`gfn, "Sequence axi_mst_random_seq is ending", UVM_DEBUG)
  endtask

  virtual task post_body();
    super.post_body();
    // Waiting for the reception of all responses in the case of id management
    // wait (p_sequencer.is_id_queue_empty() == 1);
  endtask : post_body

  virtual task send_txn(input axi_mst_item item,  // Transaction to send to the driver
                        input int txn_number = 0        // Debug input, to print the number of the transaction if this transaction is part of a bigger sequence of transactions.
    );
    axi_mst_item item_clone;

    if (!$cast(item_clone, item.clone())) `uvm_error(`gfn, "Error during the cast of the transaction");

    // Start the item
    start_item(item_clone);

    // Increment the counter for debug purposes
    if (item_clone.m_txn_type == AXI_WRITE_REQ) begin
      // In the case of an atop, as there will be 2 responses for
      // 1 request, decrease the num_rsp to avoid ending the sequence too
      // soon
      if (item_clone.m_atop[5]) begin
        num_rsp--;
      end
    end

    // Send the transction to the driver
    finish_item(item_clone);
  endtask

  protected task send_txn_get_rsp(input axi_mst_item item,  // Transaction to send to the driver
                                  output axi_mst_item rsp);
    axi_mst_item item_clone;
    enable_manage_response = 1;

    if (!$cast(item_clone, item.clone())) `uvm_error(`gfn, "Error during the cast of the transaction");

    // Start the item
    start_item(item_clone);

    // Send the transction to the driver
    finish_item(item_clone);

    // Wait for response
    case (item_clone.m_txn_type)
      AXI_READ_REQ:  get_rd_rsp(item_clone.m_id, rsp);
      AXI_WRITE_REQ: get_wr_rsp(item_clone.m_id, rsp);
    endcase
  endtask

  virtual task send_uniflit_req(input axi_dv_err_t err = NO_ERR, input int txn_number = 0);

    axi_mst_item   item;
    axi_sig_addr_t req_addr;

    // Creating the transaction and setting its configuration before the
    // randomization
    `uvm_create_obj(axi_mst_item, item)

    region   = cfg.m_memory_partitions.get_mem_region();
    req_addr = cfg.m_memory_partitions.get_addr_in_mem_region(region);

    // Randomization of the transaction
    if (!item.randomize() with {
          m_txn_type inside {AXI_WRITE_REQ, AXI_READ_REQ};
          m_err == err;
          m_atop_type == ATOP_NONE;
          m_len == 1;
          m_addr == req_addr;
        })
      `uvm_error(`gfn, "Error randomizing the request metadata");
    `uvm_info(`gfn, $sformatf("REQ, Info: %0s", item.convert2string()), UVM_DEBUG)

    send_txn(item, txn_number);

  endtask

  protected task send_uniflit_write(input axi_dv_err_t err = NO_ERR, input int txn_number = 0);

    axi_mst_item   item;
    axi_sig_addr_t req_addr;

    // Creating the transaction with its configuration
    `uvm_create_obj(axi_mst_item, item)

    region   = cfg.m_memory_partitions.get_mem_region();
    req_addr = cfg.m_memory_partitions.get_addr_in_mem_region(region);

    // Randomizing the transaction
    if (!item.randomize() with {
          m_txn_type == AXI_WRITE_REQ;
          m_err == err;
          m_atop_type == ATOP_NONE;
          m_len == 0;
          m_addr == req_addr;
        })
      `uvm_error(`gfn, "Error randomizing the write request metadata");

    send_txn(item, txn_number);

  endtask

  protected task send_uniflit_read(input axi_dv_err_t err = NO_ERR, input int txn_number = 0);

    axi_mst_item   item;
    axi_sig_addr_t req_addr;

    // Creating the transaction with its configuration
    `uvm_create_obj(axi_mst_item, item)

    region   = cfg.m_memory_partitions.get_mem_region();
    req_addr = cfg.m_memory_partitions.get_addr_in_mem_region(region);

    // Randomization of the transaction
    if (!item.randomize() with {
          m_txn_type == AXI_READ_REQ;
          m_err == err;
          m_atop_type == ATOP_NONE;
          m_len == 0;
          m_addr == req_addr;
        })
      `uvm_error(`gfn, "Error randomizing the read request metadata");

    // Sending the transaction via the send_txn task
    send_txn(item, txn_number);

  endtask

  function void response_handler(uvm_sequence_item response);
    axi_mst_item axi_response;

    `uvm_info(`gfn, $sformatf("Response handler responses=%0d", num_rsp), UVM_DEBUG);
    // Cast the response from an uvm_sequence_axi_response to a axi_mst_item
    if (!$cast(axi_response, response)) `uvm_error(`gfn, "Error during the cast of the response");


    // Stock the responses in a queue 
    // A get_rsp(id, type) can be used to get the responses
    if (enable_manage_response) begin
      case (axi_response.m_txn_type)
        AXI_WRITE_RSP: write_rsp_queue[axi_response.m_id].push_back(axi_response);
        AXI_READ_RSP:  read_rsp_queue[axi_response.m_id].push_back(axi_response);
      endcase
    end

    // Increment the number of response
    num_rsp++;
  endfunction : response_handler

  // ------------------------------
  // API to get the responses 
  // ------------------------------
  virtual task get_wr_rsp(input axi_sig_id_t id, output axi_mst_item rsp);

    // Wait until a response is seen 
    wait (write_rsp_queue.exists(id));
    wait (write_rsp_queue[id].size() > 0);
    rsp = write_rsp_queue[id].pop_front();

  endtask

  virtual task get_rd_rsp(input axi_sig_id_t id, output axi_mst_item rsp);

    // Wait until a response is seen 
    wait (read_rsp_queue.exists(id));
    wait (read_rsp_queue[id].size() > 0);
    rsp = read_rsp_queue[id].pop_front();

  endtask

endclass : axi_mst_random_seq
