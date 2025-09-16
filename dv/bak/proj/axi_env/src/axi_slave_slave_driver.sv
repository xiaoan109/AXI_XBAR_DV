//
// Template for UVM-compliant physical-level transactor
//

`ifndef SLAVE_DRIVER__SV
`define SLAVE_DRIVER__SV

typedef class slave_txn;
typedef class slave_driver;

class slave_driver_callbacks extends uvm_callback;

   // ToDo: Add additional relevant callbacks
   // ToDo: Use "task" if callbacks cannot be blocking

   // Called before a transaction is executed
   virtual task pre_tx( slave_driver xactor,
                        slave_txn tr);
                                   
     // ToDo: Add relevant code

   endtask: pre_tx


   // Called after a transaction has been executed
   virtual task post_tx( slave_driver xactor,
                         slave_txn tr);
     // ToDo: Add relevant code

   endtask: post_tx

endclass: slave_driver_callbacks


class slave_driver extends uvm_driver # (slave_txn);

   
   typedef virtual slave_intf v_if; 
   v_if drv_if;
   `uvm_register_cb(slave_driver,slave_driver_callbacks); 
   
   extern function new(string name = "slave_driver",
                       uvm_component parent = null); 
 
      `uvm_component_utils_begin(slave_driver)
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
   extern protected virtual task send(slave_txn tr); 
   extern protected virtual task tx_driver();

endclass: slave_driver


function slave_driver::new(string name = "slave_driver",
                   uvm_component parent = null);
   super.new(name, parent);

   
endfunction: new


function void slave_driver::build_phase(uvm_phase phase);
   super.build_phase(phase);
   //ToDo : Implement this phase here

endfunction: build_phase

function void slave_driver::connect_phase(uvm_phase phase);
   super.connect_phase(phase);
   uvm_config_db#(v_if)::get(this, "", "slv_if", drv_if);
endfunction: connect_phase

function void slave_driver::end_of_elaboration_phase(uvm_phase phase);
   super.end_of_elaboration_phase(phase);
   if (drv_if == null)
       `uvm_fatal("NO_CONN", "Virtual port not connected to the actual interface instance");   
endfunction: end_of_elaboration_phase

function void slave_driver::start_of_simulation_phase(uvm_phase phase);
   super.start_of_simulation_phase(phase);
   //ToDo: Implement this phase here
endfunction: start_of_simulation_phase

 
task slave_driver::reset_phase(uvm_phase phase);
   super.reset_phase(phase);
   // ToDo: Reset output signals
endtask: reset_phase

task slave_driver::configure_phase(uvm_phase phase);
   super.configure_phase(phase);
   //ToDo: Configure your component here
endtask:configure_phase


task slave_driver::run_phase(uvm_phase phase);
   super.run_phase(phase);
   // phase.raise_objection(this,""); //Raise/drop objections in sequence file
   fork 
      tx_driver();
   join
   // phase.drop_objection(this);
endtask: run_phase


task slave_driver::tx_driver();
 forever begin
      slave_txn tr;
      // ToDo: Set output signals to their idle state
      this.drv_if.master.async_en      <= 0;
      `uvm_info("axi_env_DRIVER", "Starting transaction...",UVM_LOW)
      seq_item_port.get_next_item(tr);
      case (tr.kind) 
         slave_txn::READ: begin
            // ToDo: Implement READ transaction

         end
         slave_txn::WRITE: begin
            // ToDo: Implement READ transaction

         end
      endcase
	  `uvm_do_callbacks(slave_driver,slave_driver_callbacks,
                    pre_tx(this, tr))
      send(tr); 
      seq_item_port.item_done();
      `uvm_info("axi_env_DRIVER", "Completed transaction...",UVM_LOW)
      `uvm_info("axi_env_DRIVER", tr.sprint(),UVM_HIGH)
      `uvm_do_callbacks(slave_driver,slave_driver_callbacks,
                    post_tx(this, tr))

   end
endtask : tx_driver

task slave_driver::send(slave_txn tr);
   // ToDo: Drive signal on interface
  
endtask: send


`endif // SLAVE_DRIVER__SV


