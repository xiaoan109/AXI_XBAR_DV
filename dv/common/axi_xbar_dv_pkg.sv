package axi_xbar_dv_pkg;

  //----------------------------------------------
  // AXI agent configuration typedefs
  // ---------------------------------------------
  // Driver idle values configuration
  typedef enum {ZERO,
                UNDEFINED,
                RANDOM
              } axi_dv_driver_idle_t;

  //----------------------------------------------
  // AXI transaction verification typedefs
  // ---------------------------------------------
  // Type of transaction supported
  typedef enum {AXI_READ_REQ,
                AXI_WRITE_REQ,
                AXI_READ_RSP,
                AXI_WRITE_RSP
              } axi_dv_txn_type_t;

  // AXI protocol supported
  typedef enum {AXI4,
                AXI5
              } axi_dv_ver_t;

  // LITE protocol supported
  typedef enum {NO_LITE,
                LITE
              } axi_dv_lite_t;

  // AXI protocol errors
  typedef enum {NO_ERR
              } axi_dv_err_t;

  // Internal types to generate ATOP field
  typedef enum logic [5:0] {ATOP_NONE  = 6'h00 ,
                            ATOP_STORE = 6'h10 ,
                            ATOP_LOAD  = 6'h20 ,
                            ATOP_SWAP  = 6'h30 ,
                            ATOP_CMP   = 6'h31
                          } axi_sig_atop_type_t;

  typedef enum logic {ATOP_LITTLE_END = 0 ,
                      ATOP_BIG_END    = 1
                    } axi_sig_atop_endianness_t;

  typedef enum logic [2:0] {ATOP_ADD  = 0 ,
                            ATOP_CLR  = 1 ,
                            ATOP_EOR  = 2 ,
                            ATOP_SET  = 3 ,
                            ATOP_SMAX = 4 ,
                            ATOP_SMIN = 5 ,
                            ATOP_UMAX = 6 ,
                            ATOP_UMIN = 7
                          } axi_sig_atop_op_t;

  //----------------------------------------------
  // AXI Fields typedefs
  // ---------------------------------------------
  typedef enum logic [2:0] {BYTES_1   = 3'h0 ,
                            BYTES_2   = 3'h1 ,
                            BYTES_4   = 3'h2 ,
                            BYTES_8   = 3'h3 ,
                            BYTES_16  = 3'h4 ,
                            BYTES_32  = 3'h5 ,
                            BYTES_64  = 3'h6 ,
                            BYTES_128 = 3'h7
                          } axi_dv_size_t;

  typedef enum logic [1:0] {FIXED    = 2'h0 ,
                            INCR     = 2'h1 ,
                            WRAP     = 2'h2 ,
                            RESERVED = 2'h3
                           } axi_dv_burst_t;

  typedef enum logic {NORMAL    = 'h0 ,
                      EXCLUSIVE = 'h1
                     } axi_dv_lock_t;

  typedef enum  {DEVICE_NON_BUFFERABLE                 ,
                 DEVICE_BUFFERABLE                     ,
                 NORMAL_NON_CACHEABLE_NON_BUFFERABLE   ,
                 NORMAL_NON_CACHEABLE_BUFFERABLE       ,
                 WRITE_THROUGH_NO_ALLOCATE             ,
                 WRITE_THROUGH_READ_ALLOCATE           ,
                 WRITE_THROUGH_WRITE_ALLOCATE          ,
                 WRITE_THROUGH_READ_AND_WRITE_ALLOCATE ,
                 WRITE_BACK_NO_ALLOCATE                ,
                 WRITE_BACK_READ_ALLOCATE              ,
                 WRITE_BACK_WRITE_ALLOCATE             ,
                 WRITE_BACK_READ_AND_WRITE_ALLOCATE    ,
                 CACHE_RESERVED
               } axi_dv_mem_type_t;

  typedef enum logic [2:0] {UNPRIVILEGED_SECURE_DATA_ACCESS            = 3'h0 ,
                            PRIVILEGED_SECURE_DATA_ACCESS              = 3'h1 ,
                            UNPRIVILEGED_NON_SECURE_DATA_ACCESS        = 3'h2 ,
                            PRIVILEGED_NON_SECURE_DATA_ACCESS          = 3'h3 ,
                            UNPRIVILEGED_SECURE_INSTRUCTION_ACCESS     = 3'h4 ,
                            PRIVILEGED_SECURE_INSTRUCTION_ACCESS       = 3'h5 ,
                            UNPRIVILEGED_NON_SECURE_INSTRUCTION_ACCESS = 3'h6 ,
                            PRIVILEGED_NON_SECURE_INSTRUCTION_ACCESS   = 3'h7
                          } axi_dv_prot_t;

  typedef enum logic [1:0] {OKAY   = 2'h0 ,
                            EXOKAY = 2'h1 ,
                            SLVERR = 2'h2 ,
                            DECERR = 2'h3
                          } axi_dv_resp_t;

  // Package Parameters
  parameter int MAX_NB_TXN_BURST = 256 ; // Maximum value from the protocol 

  // parameter int MAX_ID_WIDTH   = 64   ; // subjective maximum 
  // parameter int MAX_ADDR_WIDTH = 64   ; // subjective maximum
  // parameter int MAX_DATA_WIDTH = 1024 ; // subjective maximum
  // parameter int MAX_USER_WIDTH = 512  ; // subjective maximum

  parameter int unsigned AXI_ADDR_WIDTH = 32'd32;
  parameter int unsigned AXI_DATA_WIDTH = 32'd32;
  parameter int unsigned AXI_ID_WIDTH = 32'd8;
  parameter int unsigned AXI_USER_WIDTH = 32'd1;

  parameter int unsigned NUM_MASTERS = 32'd1;
  parameter int unsigned NUM_SLAVES = 32'd1;
  parameter int unsigned MAX_MASTER_TRANS = 32'd8;
  parameter int unsigned MAX_SLAVE_TRANS = 32'd8;
  parameter bit FIFO_FALLTHROUGH = 1'b0;
  parameter bit [9:0] LATENCY_MODE = axi_pkg::CUT_ALL_AX;
  parameter int unsigned PIPE_STAGES = 32'd1;
  parameter bit UNIQUE_IDS = 1'b0;
  parameter int unsigned NUM_ADDR_RULES = NUM_SLAVES;

  // axi xbar cfg
  parameter axi_pkg::xbar_cfg_t Cfg = axi_pkg::xbar_cfg_t'{
    NoSlvPorts: NUM_MASTERS,
    NoMstPorts: NUM_SLAVES,
    MaxMstTrans: MAX_MASTER_TRANS,
    MaxSlvTrans: MAX_SLAVE_TRANS,
    FallThrough: FIFO_FALLTHROUGH,
    LatencyMode: LATENCY_MODE,
    PipelineStages: PIPE_STAGES,
    AxiIdWidthSlvPorts: AXI_ID_WIDTH,
    AxiIdUsedSlvPorts: AXI_ID_WIDTH,
    UniqueIds: UNIQUE_IDS,
    AxiAddrWidth: AXI_ADDR_WIDTH,
    AxiDataWidth: AXI_DATA_WIDTH,
    NoAddrRules: NUM_ADDR_RULES
  };

  // Currently no ATOPS
  parameter bit ATOPS = 1'b0;

  // Fully connected
  parameter bit [NUM_MASTERS-1:0][NUM_SLAVES-1:0] CONNECTIVITY = '1;



  typedef axi_pkg::xbar_rule_32_t         rule_t; // Has to be the same width as axi addr
  // Each slave has its own address range:
  parameter rule_t [NUM_ADDR_RULES-1:0] AddrMap = addr_map_gen();

  function rule_t [NUM_ADDR_RULES-1:0] addr_map_gen ();
    for (int unsigned i = 0; i < NUM_ADDR_RULES; i++) begin
      addr_map_gen[i] = rule_t'{
        idx:        unsigned'(i),
        start_addr:  i    * 32'h0000_2000,
        end_addr:   (i+1) * 32'h0000_2000,
        default:    '0
      };
    end
  endfunction



  typedef logic [AXI_ID_WIDTH-1:0]      axi_sig_id_t      ;
  typedef logic [AXI_ADDR_WIDTH-1:0]    axi_sig_addr_t    ;
  typedef logic [AXI_DATA_WIDTH-1:0]    axi_sig_data_t    ;
  typedef logic [AXI_DATA_WIDTH/8-1:0]  axi_sig_wstrb_t   ;
  typedef logic [AXI_USER_WIDTH-1:0]    axi_sig_user_t    ;

  typedef logic [7:0] axi_sig_len_t    ;
  typedef logic [2:0] axi_sig_size_t   ;
  typedef logic [1:0] axi_sig_burst_t  ;
  typedef logic       axi_sig_lock_t   ;
  typedef logic [3:0] axi_sig_cache_t  ;
  typedef logic [3:0] axi_sig_region_t ;
  typedef logic [3:0] axi_sig_qos_t    ;
  typedef logic [5:0] axi_sig_atop_t   ;
  typedef logic [2:0] axi_sig_prot_t   ;
  typedef logic [1:0] axi_sig_resp_t   ;

  // Function to convert a mem_type enum value into a cache logic value,
  // depending of the txn_type
  function axi_sig_cache_t get_cache_value(axi_dv_txn_type_t txn_type, axi_dv_mem_type_t  mem_type );
    case ( txn_type )
      AXI_READ_REQ : begin
        case ( mem_type )
          DEVICE_NON_BUFFERABLE                 : return 4'b0000;
          DEVICE_BUFFERABLE                     : return 4'b0001;
          NORMAL_NON_CACHEABLE_NON_BUFFERABLE   : return 4'b0010;
          NORMAL_NON_CACHEABLE_BUFFERABLE       : return 4'b0011;
          WRITE_THROUGH_NO_ALLOCATE             : return 4'b1010;
          WRITE_THROUGH_READ_ALLOCATE           : return 4'b1110;
          WRITE_THROUGH_WRITE_ALLOCATE          : return 4'b1010;
          WRITE_THROUGH_READ_AND_WRITE_ALLOCATE : return 4'b1110;
          WRITE_BACK_NO_ALLOCATE                : return 4'b1011;
          WRITE_BACK_READ_ALLOCATE              : return 4'b1111;
          WRITE_BACK_WRITE_ALLOCATE             : return 4'b1011;
          WRITE_BACK_READ_AND_WRITE_ALLOCATE    : return 4'b1111;
          default                               : return 4'b0000;
        endcase // mem_type
      end // AXI_READ_REQ
      AXI_WRITE_REQ : begin
        case ( mem_type )
          DEVICE_NON_BUFFERABLE                 : return 4'b0000;
          DEVICE_BUFFERABLE                     : return 4'b0001;
          NORMAL_NON_CACHEABLE_NON_BUFFERABLE   : return 4'b0010;
          NORMAL_NON_CACHEABLE_BUFFERABLE       : return 4'b0011;
          WRITE_THROUGH_NO_ALLOCATE             : return 4'b0110;
          WRITE_THROUGH_READ_ALLOCATE           : return 4'b0110;
          WRITE_THROUGH_WRITE_ALLOCATE          : return 4'b1110;
          WRITE_THROUGH_READ_AND_WRITE_ALLOCATE : return 4'b1110;
          WRITE_BACK_NO_ALLOCATE                : return 4'b0111;
          WRITE_BACK_READ_ALLOCATE              : return 4'b0111;
          WRITE_BACK_WRITE_ALLOCATE             : return 4'b1111;
          WRITE_BACK_READ_AND_WRITE_ALLOCATE    : return 4'b1111;
          default                               : return 4'b0000;
        endcase // mem_type
      end // AXI_WRITE_REQ
      AXI_READ_RSP  : return 4'bxxxx ;
      AXI_WRITE_RSP : return 4'bxxxx ;
    endcase // txn_type
  endfunction

  // Function to convert a mem_type enum value into a cache logic value,
  // depending of the txn_type
  function axi_dv_mem_type_t get_mem_type(axi_dv_txn_type_t txn_type, axi_sig_cache_t cache);
    case ( txn_type )
      AXI_READ_REQ, AXI_READ_RSP : begin
        case ( cache )
          4'b0000 : return DEVICE_NON_BUFFERABLE                ;
          4'b0001 : return DEVICE_BUFFERABLE                    ;
          4'b0010 : return NORMAL_NON_CACHEABLE_NON_BUFFERABLE  ;
          4'b0011 : return NORMAL_NON_CACHEABLE_BUFFERABLE      ;
          4'b1010 : return WRITE_THROUGH_NO_ALLOCATE            ;
          4'b1110 : return WRITE_THROUGH_READ_ALLOCATE          ;
          4'b1010 : return WRITE_THROUGH_WRITE_ALLOCATE         ;
          4'b1110 : return WRITE_THROUGH_READ_AND_WRITE_ALLOCATE;
          4'b1011 : return WRITE_BACK_NO_ALLOCATE               ;
          4'b1111 : return WRITE_BACK_READ_ALLOCATE             ;
          4'b1011 : return WRITE_BACK_WRITE_ALLOCATE            ;
          4'b1111 : return WRITE_BACK_READ_AND_WRITE_ALLOCATE   ;
          default : return CACHE_RESERVED                       ;
        endcase // mtype
      end // AXI_READ_REQ
      AXI_WRITE_REQ, AXI_WRITE_RSP : begin
        case ( cache )
          4'b0000 : return DEVICE_NON_BUFFERABLE                ;
          4'b0001 : return DEVICE_BUFFERABLE                    ;
          4'b0010 : return NORMAL_NON_CACHEABLE_NON_BUFFERABLE  ;
          4'b0011 : return NORMAL_NON_CACHEABLE_BUFFERABLE      ;
          4'b0110 : return WRITE_THROUGH_NO_ALLOCATE            ;
          4'b0110 : return WRITE_THROUGH_READ_ALLOCATE          ;
          4'b1110 : return WRITE_THROUGH_WRITE_ALLOCATE         ;
          4'b1110 : return WRITE_THROUGH_READ_AND_WRITE_ALLOCATE;
          4'b0111 : return WRITE_BACK_NO_ALLOCATE               ;
          4'b0111 : return WRITE_BACK_READ_ALLOCATE             ;
          4'b1111 : return WRITE_BACK_WRITE_ALLOCATE            ;
          4'b1111 : return WRITE_BACK_READ_AND_WRITE_ALLOCATE   ;
          default : return CACHE_RESERVED                       ;
        endcase // mem_type
      end // AXI_WRITE_REQ
    endcase // txn_type
  endfunction

endpackage