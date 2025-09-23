// Copyright lowRISC contributors (OpenTitan project).
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

class axi_mst_item extends uvm_sequence_item;

  // random variables
  // AXI4 signals
  rand axi_dv_txn_type_t m_txn_type;
  rand axi_dv_err_t m_err;
  rand axi_sig_id_t m_id;
  rand axi_sig_addr_t m_addr;
  rand axi_sig_data_t m_data[$];
  rand axi_sig_wstrb_t m_wstrb[$];
  rand logic m_last[$];
  rand axi_sig_len_t m_len;
  rand axi_dv_size_t m_size;
  rand axi_dv_burst_t m_burst;
  rand axi_dv_lock_t m_lock;
  rand axi_sig_cache_t m_cache;
  rand axi_dv_prot_t m_prot;
  rand axi_sig_qos_t m_qos;
  rand axi_sig_region_t m_region;
  rand axi_sig_user_t m_user;
  rand axi_dv_resp_t m_resp[$];
  // W channel user signal
  rand axi_sig_user_t m_w_user;

  // AXI5 ATOP
  rand axi_sig_atop_t m_atop;

  // Memory type for the m_cache encoding
  rand axi_dv_mem_type_t m_mem_type;

  // Channel delay fields
  rand int unsigned m_delay_cycle_chan_X;  // Delay before driving the transaction on the AW/AR/B/R channels
  rand int unsigned m_delay_cycle_chan_W;  // Delay before driving the transaction on the W channel
  rand int unsigned m_delay_cycle_flits[$];  // Delay in cycles between two flits on the W or the R channels

  // Internal fields to generate m_atop field
  rand axi_sig_atop_type_t m_atop_type;  // Atomic transaction type (None, Load, Store, Compare, Swap)
  rand axi_sig_atop_endianness_t m_atop_endianness;  // Endianness that is required for arithmetic operation in case of AtomicStore and AtomicLoad
  rand axi_sig_atop_op_t m_atop_op;  // Operation encodings for AtomicStore and AtomicLoad

  // Timestamp: array that contains the timestamp of the reception of each
  // flit of the transaction. This fields is used only in the monitor.
  // Stil some reflection is needed for this fields
  time m_timestamp[$];

  `uvm_object_utils_begin(axi_mst_item)
    `uvm_field_int(m_id, UVM_DEFAULT | UVM_HEX)
    `uvm_field_int(m_addr, UVM_DEFAULT | UVM_HEX)
    `uvm_field_queue_int(m_data, UVM_DEFAULT | UVM_HEX)
    `uvm_field_queue_int(m_wstrb, UVM_DEFAULT | UVM_HEX)
    `uvm_field_queue_int(m_last, UVM_DEFAULT | UVM_DEC)
    `uvm_field_int(m_len, UVM_DEFAULT | UVM_DEC)
    `uvm_field_enum(axi_dv_size_t, m_size, UVM_DEFAULT)
    `uvm_field_enum(axi_dv_burst_t, m_burst, UVM_DEFAULT)
    `uvm_field_enum(axi_dv_lock_t, m_lock, UVM_DEFAULT)
    `uvm_field_int(m_cache, UVM_DEFAULT | UVM_BIN)
    `uvm_field_enum(axi_dv_prot_t, m_prot, UVM_DEFAULT)
    `uvm_field_int(m_qos, UVM_DEFAULT | UVM_HEX)
    `uvm_field_int(m_region, UVM_DEFAULT | UVM_HEX)
    `uvm_field_int(m_user, UVM_DEFAULT | UVM_HEX)
    `uvm_field_int(m_w_user, UVM_DEFAULT | UVM_HEX)
    `uvm_field_int(m_atop, UVM_DEFAULT | UVM_HEX)
    `uvm_field_queue_enum(axi_dv_resp_t, m_resp, UVM_DEFAULT)
    `uvm_field_enum(axi_dv_txn_type_t, m_txn_type, UVM_DEFAULT)
    `uvm_field_enum(axi_dv_err_t, m_err, UVM_DEFAULT)
    `uvm_field_enum(axi_dv_mem_type_t, m_mem_type, UVM_DEFAULT)
    `uvm_field_int(m_delay_cycle_chan_X, UVM_DEFAULT | UVM_NOCOMPARE)
    `uvm_field_int(m_delay_cycle_chan_W, UVM_DEFAULT | UVM_NOCOMPARE)
    `uvm_field_queue_int(m_delay_cycle_flits, UVM_DEFAULT | UVM_NOCOMPARE)
    `uvm_field_queue_int(m_timestamp, UVM_DEFAULT | UVM_NOCOMPARE)
  `uvm_object_utils_end

  `uvm_object_new


  // constraints
  // array length
  constraint c_data_length {m_data.size() == m_len + 1;}
  constraint c_wstrb_length {m_wstrb.size() == m_len + 1;}
  constraint c_last_length {m_last.size() == m_len + 1;}
  constraint c_resp_length {m_resp.size() == m_len + 1;}
  constraint c_delay_flits {m_delay_cycle_flits.size() == m_len + 1;}
  // last signal
  constraint c_last {
    foreach (m_last[i]) {
      if (i != m_last.size() - 1)
      m_last[i] == 0;
      else
      m_last[i] == 1;
    }
  }

  // delay cycle
  constraint c_delay_cycle_X {m_delay_cycle_chan_X inside {[0 : 10]};}
  constraint c_delay_cycle_W {m_delay_cycle_chan_W inside {[0 : 10]};}
  constraint c_delay_cycle_flits {
    foreach (m_delay_cycle_flits[i]) {
      m_delay_cycle_flits[i] inside {[0 : 5]};
    }
  }

  // ATOP constr
  constraint c_atop_size {
    (m_atop_type inside {ATOP_STORE, ATOP_LOAD, ATOP_SWAP}) -> (m_size inside {BYTES_1, BYTES_2, BYTES_4, BYTES_8});
    (m_atop_type == ATOP_CMP) -> (m_size inside {BYTES_2, BYTES_4, BYTES_8, BYTES_16, BYTES_32});
    // ((m_atop_type == ATOP_CMP) && (m_txn_type == AXI_WRITE_REQ)) -> (m_size inside {BYTES_2, BYTES_4, BYTES_8, BYTES_16, BYTES_32});
    // ((m_atop_type == ATOP_CMP) && (m_txn_type == AXI_READ_REQ)) -> (m_size inside {BYTES_1, BYTES_2, BYTES_4, BYTES_8, BYTES_16});
  }

  constraint c_atop_burst_type {
    (m_atop_type inside {ATOP_STORE, ATOP_LOAD, ATOP_SWAP}) -> (m_burst == INCR);
    // TODO: ATOP_CMP constr
  }

  constraint c_burst_type {m_burst inside {FIXED, INCR, WRAP};}

  constraint c_burst_len {
    (m_burst == FIXED) -> (m_len inside {[0 : 15]});
    (m_burst == INCR) -> (m_len inside {[0 : MAX_NB_TXN_BURST - 1]});
    (m_burst == WRAP) -> (m_len inside {1, 3, 7, 15});
  }

  constraint c_wrap_addr_aligned {(m_burst == WRAP) -> (m_addr % (2 ** m_size) == 0);}

  constraint c_prot {m_prot == UNPRIVILEGED_SECURE_DATA_ACCESS;}

  constraint c_mem_type {m_mem_type != CACHE_RESERVED;}

  constraint c_AW_cache_value {(m_txn_type == AXI_WRITE_REQ) -> (m_cache == get_cache_value(AXI_WRITE_REQ, m_mem_type));}

  constraint c_W_wstrb_size {
    foreach (m_wstrb[i]) {
      (m_txn_type == AXI_WRITE_REQ) -> ($countones(m_wstrb[i]) <= 2 ** m_size);
    }
  }

  constraint c_B_len {(m_txn_type == AXI_WRITE_RSP) -> (m_len == 0);}

  constraint c_AR_channel {(m_txn_type == AXI_READ_REQ) -> (m_atop_type == ATOP_NONE);}

  constraint c_AR_cache_value {(m_txn_type == AXI_READ_REQ) -> (m_cache == get_cache_value(AXI_READ_REQ, m_mem_type));}

  constraint c_atop_field {
    if ((m_atop_type == ATOP_LOAD) || (m_atop_type == ATOP_STORE))
    m_atop == (m_atop_type || (m_atop_endianness << 3) || m_atop_op);
    else
    m_atop == m_atop_type;
  }

  constraint c_atomic_txns {(m_atop_type != ATOP_NONE) -> (m_lock == NORMAL);}

  constraint c_atop_addr {(m_atop_type != ATOP_NONE) -> (m_addr == m_addr + m_addr % m_size);}

  constraint c_non_modifiable_txns {
    ((m_lock == EXCLUSIVE) || (m_atop_type != ATOP_NONE)) ->
    (m_mem_type inside {DEVICE_NON_BUFFERABLE, DEVICE_BUFFERABLE});
  }

  constraint c_excl_txns {
    (m_lock == EXCLUSIVE) ->
    ((m_len <= 15) && ($clog2((m_len + 1) * (2 ** m_size)) inside {[0 : 7]}));
  }

  // ------------------------------------------------------------------------
  // Ordering constraints
  // ------------------------------------------------------------------------
  constraint c_atop_type_before_atop {solve m_atop_type before m_atop;}
  constraint c_atop_type_before_cache {solve m_atop_type before m_mem_type;}
  constraint c_lock_before_cache {solve m_lock before m_mem_type;}
  constraint c_atop_type_before_lock {solve m_atop_type before m_lock;}
  constraint c_endianness_before_atop {solve m_atop_endianness before m_atop;}
  constraint c_size_before_wstrb {solve m_size before m_wstrb;}
  constraint c_type_before_len {solve m_txn_type before m_len;}

  constraint c_len_before_data {solve m_len before m_data;}
  constraint c_len_before_last {solve m_len before m_last;}
  constraint c_len_before_wstrb {solve m_len before m_wstrb;}
  constraint c_len_before_resp {solve m_len before m_resp;}
  constraint c_len_before_delay_flits {solve m_len before m_delay_cycle_flits;}
  // constraint c_len_before_timestamp {solve m_len before m_timestamp;}

  // Enum to logic conversion constraint
  constraint c_type_before_mem_type {solve m_txn_type before m_mem_type;}
  constraint c_mem_type_before_cache {solve m_mem_type before m_cache;}

  // Constraint for the atop support
  constraint c_atop_before_size {solve m_atop_type before m_size;}



  // post randomize for unaligned and narrow transfers
  function void post_randomize();
    int bus_nbytes, nb_bytes;
    int lower_byte_lane, upper_byte_lane;
    axi_sig_addr_t aligned_addr, address_n;
    axi_sig_addr_t lower_wrap_boundary, upper_wrap_boundary;
    int   container_size;
    logic wrap_en;

    super.post_randomize();

    // Using the equation of the specification, section A4.1.6 of the IHI022K
    // version of the amba axi protocol to regenerate a valid write strobe
    // for the transaction
    if (m_txn_type == AXI_WRITE_REQ) begin
      // Computing some variables
      bus_nbytes          = AXI_DATA_WIDTH / 8;
      nb_bytes            = 2 ** m_size;
      aligned_addr        = int'(m_addr / nb_bytes) * nb_bytes;
      container_size      = nb_bytes * (m_len + 1);
      lower_wrap_boundary = int'(m_addr / container_size) * container_size;
      upper_wrap_boundary = lower_wrap_boundary + container_size;
      wrap_en             = 0;
      foreach (m_wstrb[i]) begin
        logic flag;  // Flag which is only used for debug purpose: if there is a problem in the write strobe generation, an error is printed

        // Equation from the specification
        if (m_burst == FIXED) begin
          address_n = m_addr;
          lower_byte_lane = m_addr - int'(m_addr / bus_nbytes) * bus_nbytes;
          upper_byte_lane = aligned_addr + (nb_bytes - 1) - int'(m_addr / bus_nbytes) * bus_nbytes;
        end else begin
          if (i == 0) begin
            address_n       = m_addr;
            lower_byte_lane = m_addr - int'(m_addr / bus_nbytes) * bus_nbytes;
            upper_byte_lane = aligned_addr + (nb_bytes - 1) - int'(m_addr / bus_nbytes) * bus_nbytes;
          end else begin
            if (wrap_en) begin
              address_n = m_addr + (i * nb_bytes) - container_size;
            end else if ((m_burst == WRAP) && ((aligned_addr + i * nb_bytes) >= upper_wrap_boundary)) begin
              address_n = lower_wrap_boundary;
              wrap_en   = 1;
            end else begin
              address_n = aligned_addr + i * nb_bytes;
            end
            lower_byte_lane = address_n - int'(address_n / bus_nbytes) * bus_nbytes;
            upper_byte_lane = lower_byte_lane + nb_bytes - 1;
          end
        end

        // Cleaning the write strobe, to re randomize it bit by bit
        m_wstrb[i] = 'h0;
        flag = 1;
        for (int j = 0; j < bus_nbytes; j++) begin
          if ((j <= upper_byte_lane) && (j >= lower_byte_lane)) begin
            logic strb;
            if (!std::randomize(strb)) `uvm_error(`gfn, "Randomizing strb error")
            m_wstrb[i][j] = strb;
          end
          flag = 0;
        end

        if (flag) `uvm_error(`gfn, "Not entered the wstrb loop: error of byte lane computing")
      end
    end

    if (m_err != NO_ERR) `uvm_fatal("UNSUPPORTED_ERROR_MODE", $sformatf("The error mode %0p is not supported by this agent. Only the error mode NO_ERR is supported by this agent currently", m_err))

    if (m_prot != UNPRIVILEGED_SECURE_DATA_ACCESS)
      `uvm_fatal("UNSUPPORTED_PROT_MODE", $sformatf("The prot mode %0p is not supported by this agent. Only the burst mode UNPRIVILEGED_SECURE_DATA_ACCESS is supported by this agent currently", m_prot
                 ))

  endfunction : post_randomize


  // -----------------------------------------------------------------------
  // -----------------------------------------------------------------------
  // Functions/tasks
  // -----------------------------------------------------------------------
  // -----------------------------------------------------------------------

  // ------------------------------------------------------------------------
  // get_total_number_of_bytes_exchanged
  // Task in charge of counting the total number of bytes exchanged in the
  // transaction.
  // ------------------------------------------------------------------------
  function int get_total_number_of_bytes_exchanged();
    get_total_number_of_bytes_exchanged = (m_len + 1) * (2 ** m_size);
  endfunction : get_total_number_of_bytes_exchanged

  // ------------------------------------------------------------------------
  // get_total_number_of_bytes_in_mem
  // Task in charge of counting the total number of bytes written or read in
  // the memory by the transaction
  // ------------------------------------------------------------------------
  function int get_total_number_of_bytes_in_mem();
    int number_of_bytes = 0;

    case (m_txn_type)
      AXI_WRITE_REQ: begin
        foreach (m_wstrb[i]) begin
          number_of_bytes += $countones(m_wstrb[i]);
        end  // foreach
      end
      AXI_WRITE_RSP: number_of_bytes = 0;  // the write response has no fields indicating how many bytes were written in the memory
      AXI_READ_REQ:  number_of_bytes = this.get_total_number_of_bytes_exchanged();
      AXI_READ_RSP:  number_of_bytes = AXI_DATA_WIDTH * this.m_data.size();
    endcase
    get_total_number_of_bytes_in_mem = number_of_bytes;

  endfunction : get_total_number_of_bytes_in_mem

  // ------------------------------------------------------------------------
  // compare_bytes_in_mem
  // Function to compare the number of bytes written or read in the memory
  // between two transactions, which can have different data bus width
  // ------------------------------------------------------------------------
  function bit compare_bytes_in_mem(axi_mst_item other_txn);
    int this_number_of_bytes;
    int other_number_of_bytes;

    this_number_of_bytes  = this.get_total_number_of_bytes_in_mem();
    other_number_of_bytes = other_txn.get_total_number_of_bytes_in_mem();

    if (this_number_of_bytes != other_number_of_bytes) return 0;
    else return 1;

  endfunction : compare_bytes_in_mem


  // ------------------------------------------------------------------------
  // convert2string
  // ------------------------------------------------------------------------
  virtual function string convert2string;
    string s;
    string array;

    s = super.convert2string();
    s = $sformatf("%s, ID=%0h(h)", m_txn_type, m_id);

    if ((m_txn_type == AXI_WRITE_REQ) || (m_txn_type == AXI_READ_REQ)) begin
      s = $sformatf(
          "%0s, ADDR=%0h(h), LEN=%0h(h), SIZE=%0p(h), BURST=%0p(h), LOCK=%0p(d), CACHE=%0h(h), MEM_TYPE=%0p(p), PROT=%0b(b), QOS=%0h(h), REGION=%0h(h)",
          s,
          m_addr,
          m_len,
          m_size,
          m_burst,
          m_lock,
          m_cache,
          m_mem_type,
          m_prot,
          m_qos,
          m_region
      );
    end
    if ((m_txn_type == AXI_WRITE_REQ) || (m_txn_type == AXI_READ_RSP)) begin
      array = "";
      foreach (m_data[i]) array = $sformatf("%0s%0h ", array, m_data[i]);
      s = $sformatf("%0s, DATA=%0s(h)", s, array);
      if ((m_txn_type == AXI_WRITE_REQ)) begin
        array = "";
        foreach (m_wstrb[i]) array = $sformatf("%0s%0h ", array, m_wstrb[i]);
        s = $sformatf("%0s, WSTRB=%0s(h)", s, array);
      end
      s = $sformatf("%0s, LAST=%0p(p)", s, m_last);
    end
    if ((m_txn_type == AXI_WRITE_RSP) || (m_txn_type == AXI_READ_RSP)) begin
      array = "";
      foreach (m_resp[i]) array = $sformatf("%0s%0h ", array, m_resp[i]);
      s = $sformatf("%0s, RESP=%0s(h)", s, array);
    end

    if (m_txn_type == AXI_WRITE_REQ) begin
      s = $sformatf("%0s, ATOP=%0h(h)", s, m_atop);
    end

    s = $sformatf("%0s, DELAY_CHANNEL=%0d(d)", s, m_delay_cycle_chan_X);
    if (m_txn_type == AXI_WRITE_REQ) begin
      s = $sformatf("%0s, DELAY_W_CHANNEL=%0d(d)", s, m_delay_cycle_chan_W);
    end

    if ((m_txn_type == AXI_WRITE_REQ) || (m_txn_type == AXI_READ_RSP)) begin
      array = "";
      foreach (m_delay_cycle_flits[i]) array = $sformatf("%0s%0d ", array, m_delay_cycle_flits[i]);
      s = $sformatf("%0s, DELAY_FLITS=%0s(h)", s, array);
    end

    s = $sformatf("%0s, USER=%0h(h), TIME=%0p(p)", s, m_user, m_timestamp);
    return s;
  endfunction : convert2string

  // ------------------------------------------------------------------------
  // function append_write_flit()
  //
  // User provides a data flit and it is appended to the transaction.
  // It is assumed that the transaction is already initialized/randomized
  // when using this function.
  // By default, the function assume the response status is OK, but
  //      user can optionally specify the status.
  // By default, the function assumes the wrtsb is all 1’s.
  // By default, the function will tag the last flit that was received
  //     as last. But, user can optionally provided the last field, in
  //     which it is directly associated with the data.
  // ------------------------------------------------------------------------
  virtual function void append_write_flit(axi_sig_data_t data_i, axi_sig_wstrb_t wstrb_i = 2 ** (AXI_DATA_WIDTH / 8) - 1, logic last_i = 1'bx);
    if (m_len + 1 <= MAX_NB_TXN_BURST) begin
      m_len++;
      m_data.push_back(data_i);
      m_wstrb.push_back(wstrb_i);

      if (last_i == 1'bx) begin
        foreach (m_last[i]) m_last[i] = 0;
        m_last[m_len] = 1;
      end else begin
        m_last.push_back(last_i);
      end  // if
    end else begin
      `uvm_warning("ERROR_NB_TXN_BURST", $sformatf("Cannot add more flits to this transaction, as there is already the maximum number of flits"))
    end
  endfunction : append_write_flit

  // ------------------------------------------------------------------------
  // function append_read_flit()
  //
  // User provides a data flit and it is appended to the transaction.
  // It is assumed that the transaction is already initialized/randomized
  // when using this function.
  // By default, the function assume the response status is OK, but
  //      user can optionally specify the status.
  // By default, the function will tag the last flit that was received
  //     as last. But, user can optionally provided the last field, in
  //     which it is directly associated with the data.
  // ------------------------------------------------------------------------
  virtual function void append_read_flit(axi_sig_data_t data_i, axi_dv_resp_t resp_i = OKAY,  // assume OK status
                                         logic last_i  = 1'bx // set to X by default, let user over-ride
  );
    if (m_data.size() + 1 <= MAX_NB_TXN_BURST) begin
      m_data.push_back(data_i);  // append data flit
      m_resp.push_back(resp_i);  // append response
      if (last_i == 1'bx) begin
        foreach (m_last[i]) m_last[i] = 0;
        m_last[m_len+1] = 1;
      end else begin
        m_last.push_back(last_i);
      end  // if
    end else begin
      `uvm_warning("ERROR_NB_TXN_BURST", $sformatf("Cannot add more flits to this transaction, as there is already the maximum number of flits"))
    end
  endfunction : append_read_flit


  // ------------------------------------------------------------------------
  // set/get functions
  // ------------------------------------------------------------------------
  // ID
  function axi_sig_id_t get_id();
    get_id = m_id;
  endfunction : get_id

  function void set_id(axi_sig_id_t id_i);
    m_id = id_i;
  endfunction : set_id

  // ADDR
  function axi_sig_addr_t get_addr();
    get_addr = m_addr;
  endfunction : get_addr

  function void set_addr(axi_sig_addr_t addr_i);
    m_addr = addr_i;
  endfunction : set_addr

  // ALL DATA FLITS
  function void get_all_data_flits(ref axi_sig_data_t data_o[$]);
    foreach (m_data[i]) data_o[i] = m_data[i];
  endfunction : get_all_data_flits

  function void set_all_data_flits(axi_sig_data_t data_i[$]);
    foreach (data_i[i]) m_data[i] = data_i[i];
  endfunction : set_all_data_flits

  // DATA FLIT
  function void get_data_flit(ref axi_sig_data_t data_o, int index);
    if (index < m_data.size()) data_o = m_data[index];
    else `uvm_warning(`gfn, $sformatf("The index %0d is out of bound of the dynamic array of size %0d", index, m_data.size()))
  endfunction : get_data_flit

  function void set_data_flit(axi_sig_data_t data_i, int index);
    if (index < m_data.size()) m_data[index] = data_i;
    else `uvm_warning(`gfn, $sformatf("The index %0d is out of bound of the dynamic array of size %0d", index, m_data.size()))
  endfunction : set_data_flit

  // ALL WSTRB FLITS
  function void get_all_wstrb_flits(ref axi_sig_wstrb_t wstrb_o);
    foreach (m_wstrb[i]) wstrb_o[i] = m_wstrb[i];
  endfunction : get_all_wstrb_flits

  function void set_all_wstrb_flits(axi_sig_wstrb_t wstrb_i[]);
    foreach (wstrb_i[i]) m_wstrb[i] = wstrb_i[i];
  endfunction : set_all_wstrb_flits

  // WSTRB FLIT
  function void get_wstrb_flit(ref axi_sig_wstrb_t wstrb_o, int index);
    if (index < m_wstrb.size()) wstrb_o = m_wstrb[index];
    else `uvm_warning(`gfn, $sformatf("The index %0d is out of bound of the dynamic array of size %0d", index, m_wstrb.size()))
  endfunction : get_wstrb_flit

  function void set_wstrb_flit(axi_sig_wstrb_t wstrb_i, int index);
    if (index < m_wstrb.size()) m_wstrb[index] = wstrb_i;
    else `uvm_warning(`gfn, $sformatf("The index %0d is out of bound of the dynamic array of size %0d", index, m_wstrb.size()))
  endfunction : set_wstrb_flit

  // ALL LAST FLITS
  function void get_all_last_flits(ref logic last_o[]);
    foreach (m_last[i]) last_o[i] = m_last[i];
  endfunction : get_all_last_flits

  function void set_all_last_flits(logic [0:0] last_i[]);
    foreach (last_i[i]) m_last[i] = last_i[i];
  endfunction : set_all_last_flits

  // LAST FLIT
  function void get_last_flit(ref logic last_o, int index);
    if (index < m_last.size()) last_o = m_last[index];
    else `uvm_warning(`gfn, $sformatf("The index %0d is out of bound of the dynamic array of size %0d", index, m_last.size()))
  endfunction : get_last_flit

  function void set_last_flit(logic last_i, int index);
    if (index < m_last.size()) m_last[index] = last_i;
    else `uvm_warning(`gfn, $sformatf("The index %0d is out of bound of the dynamic array of size %0d", index, m_last.size()))
  endfunction : set_last_flit

  // LEN
  function logic [7:0] get_len();
    get_len = m_len;
  endfunction : get_len

  function void set_len(logic [7:0] len_i);
    m_len = len_i;
  endfunction : set_len

  // SIZE
  function axi_dv_size_t get_size();
    get_size = m_size;
  endfunction : get_size

  function void set_size(axi_dv_size_t size_i);
    m_size = size_i;
  endfunction : set_size

  // BURST
  function axi_dv_burst_t get_burst();
    get_burst = m_burst;
  endfunction : get_burst

  function void set_burst(axi_dv_burst_t burst_i);
    m_burst = burst_i;
  endfunction : set_burst

  // LOCK
  function axi_dv_lock_t get_lock();
    get_lock = m_lock;
  endfunction : get_lock

  function void set_lock(axi_dv_lock_t lock_i);
    m_lock = lock_i;
  endfunction : set_lock

  // CACHE
  function axi_sig_cache_t get_cache();
    get_cache = m_cache;
  endfunction : get_cache

  function void set_cache(axi_sig_cache_t cache_i);
    m_cache = cache_i;
  endfunction : set_cache

  // PROT
  function axi_dv_prot_t get_prot();
    get_prot = m_prot;
  endfunction : get_prot

  function void set_prot(axi_dv_prot_t prot_i);
    m_prot = prot_i;
  endfunction : set_prot

  // QOS
  function logic [3:0] get_qos();
    get_qos = m_qos;
  endfunction : get_qos

  function void set_qos(logic [3:0] qos_i);
    m_qos = qos_i;
  endfunction : set_qos

  // REGION
  function logic [3:0] get_region();
    get_region = m_region;
  endfunction : get_region

  function void set_region(logic [3:0] region_i);
    m_region = region_i;
  endfunction : set_region

  // USER
  function axi_sig_user_t get_user();
    get_user = m_user;
  endfunction : get_user

  function void set_user(axi_sig_user_t user_i);
    m_user = user_i;
  endfunction : set_user

  // ALL RESP FLITS
  function void get_all_resp_flits(ref axi_dv_resp_t resp_o[]);
    foreach (m_resp[i]) resp_o[i] = m_resp[i];
  endfunction : get_all_resp_flits

  function void set_all_resp_flits(axi_dv_resp_t resp_i[]);
    foreach (resp_i[i]) m_resp[i] = resp_i[i];
  endfunction : set_all_resp_flits

  // RESP FLIT
  function void get_resp_flit(ref axi_dv_resp_t resp_o, int index);
    if (index < m_resp.size()) resp_o = m_resp[index];
    else `uvm_warning(`gfn, $sformatf("The index %0d is out of bound of the dynamic array of size %0d", index, m_resp.size()))
  endfunction : get_resp_flit

  function void set_resp_flit(axi_dv_resp_t resp_i, int index);
    if (index < m_resp.size()) m_resp[index] = resp_i;
    else `uvm_warning(`gfn, $sformatf("The index %0d is out of bound of the dynamic array of size %0d", index, m_resp.size()))
  endfunction : set_resp_flit

  // ATOP
  function logic [5:0] get_atop();
    get_atop = m_atop;
  endfunction : get_atop

  function void set_atop(logic [5:0] atop_i);
    m_atop = atop_i;
  endfunction : set_atop


  // AX DELAY
  function int get_delay_AX();
    get_delay_AX = m_delay_cycle_chan_X;
  endfunction : get_delay_AX

  function void set_delay_AX(int delay_AX_i);
    m_delay_cycle_chan_X = delay_AX_i;
  endfunction : set_delay_AX

  // W DELAY
  function int get_delay_W();
    get_delay_W = m_delay_cycle_chan_W;
  endfunction : get_delay_W

  function void set_delay_W(int delay_W_i);
    m_delay_cycle_chan_W = delay_W_i;
  endfunction : set_delay_W

  // FLITS DELAY
  function void get_delay_flits(ref int delay_flits_o);
    foreach (m_delay_cycle_flits[i]) delay_flits_o[i] = m_delay_cycle_flits[i];
  endfunction : get_delay_flits

  function void set_delay_flits(int delay_flits_i[]);
    foreach (delay_flits_i[i]) m_delay_cycle_flits[i] = delay_flits_i[i];
  endfunction : set_delay_flits


endclass
