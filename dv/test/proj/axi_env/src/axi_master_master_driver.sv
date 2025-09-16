//
// Template for UVM-compliant physical-level transactor
//

`ifndef MASTER_DRIVER__SV
`define MASTER_DRIVER__SV

typedef class master_txn;
typedef class master_driver;

class master_driver_callbacks extends uvm_callback;

   // ToDo: Add additional relevant callbacks
   // ToDo: Use "task" if callbacks cannot be blocking

   // Called before a transaction is executed
   virtual task pre_tx( master_driver xactor,
                        master_txn tr);
                                   
     // ToDo: Add relevant code

   endtask: pre_tx


   // Called after a transaction has been executed
   virtual task post_tx( master_driver xactor,
                         master_txn tr);
     // ToDo: Add relevant code

   endtask: post_tx

endclass: master_driver_callbacks


class master_driver extends uvm_driver # (master_txn);

   
   typedef virtual master_intf v_if; 
   v_if drv_if;
   `uvm_register_cb(master_driver,master_driver_callbacks); 
   
   extern function new(string name = "master_driver",
                       uvm_component parent = null); 
 
      `uvm_component_utils_begin(master_driver)
      // ToDo: Add uvm driver member
      `uvm_component_utils_end
   // ToDo: Add required short hand override method


   extern virtual function void build_phase(uvm_phase phase);
   extern virtual function void end_of_elaboration_phase(uvm_phase phase);
   extern virtual function void start_of_simulation_phase(uvm_phase phase);
   extern virtual function void connect_phase(uvm_phase phase);
   extern virtual task reset_phase(uvm_phase phase);
   extern virtual task configure_phase(uvm_phase phase);
   extern virtual task run_phase(uvm_phase phase);
   extern protected virtual task send(master_txn tr); 
   extern protected virtual task tx_driver();

endclass: master_driver


function master_driver::new(string name = "master_driver",
                   uvm_component parent = null);
   super.new(name, parent);

   
endfunction: new


function void master_driver::build_phase(uvm_phase phase);
   super.build_phase(phase);
   //ToDo : Implement this phase here

endfunction: build_phase

function void master_driver::connect_phase(uvm_phase phase);
   super.connect_phase(phase);
   uvm_config_db#(v_if)::get(this, "", "mst_if", drv_if);
endfunction: connect_phase

function void master_driver::end_of_elaboration_phase(uvm_phase phase);
   super.end_of_elaboration_phase(phase);
   if (drv_if == null)
       `uvm_fatal("NO_CONN", "Virtual port not connected to the actual interface instance");   
endfunction: end_of_elaboration_phase

function void master_driver::start_of_simulation_phase(uvm_phase phase);
   super.start_of_simulation_phase(phase);
   //ToDo: Implement this phase here
endfunction: start_of_simulation_phase

 
task master_driver::reset_phase(uvm_phase phase);
   super.reset_phase(phase);
   // ToDo: Reset output signals
endtask: reset_phase

task master_driver::configure_phase(uvm_phase phase);
   super.configure_phase(phase);
   //ToDo: Configure your component here
endtask:configure_phase


task master_driver::run_phase(uvm_phase phase);
   super.run_phase(phase);
   // phase.raise_objection(this,""); //Raise/drop objections in sequence file
   fork 
      tx_driver();
   join
   // phase.drop_objection(this);
endtask: run_phase


task master_driver::tx_driver();
 forever begin
      master_txn tr;
      // ToDo: Set output signals to their idle state
      this.drv_if.master.async_en      <= 0;
      `uvm_info("axi_env_DRIVER", "Starting transaction...",UVM_LOW)
      seq_item_port.get_next_item(tr);
      case (tr.kind) 
         master_txn::READ: begin
            // ToDo: Implement READ transaction

         end
         master_txn::WRITE: begin
            // ToDo: Implement READ transaction

         end
      endcase
	  `uvm_do_callbacks(master_driver,master_driver_callbacks,
                    pre_tx(this, tr))
      send(tr); 
      seq_item_port.item_done();
      `uvm_info("axi_env_DRIVER", "Completed transaction...",UVM_LOW)
      `uvm_info("axi_env_DRIVER", tr.sprint(),UVM_HIGH)
      `uvm_do_callbacks(master_driver,master_driver_callbacks,
                    post_tx(this, tr))

   end
endtask : tx_driver

task master_driver::send(master_txn tr);
   // ToDo: Drive signal on interface
  
endtask: send


`endif // MASTER_DRIVER__SV


