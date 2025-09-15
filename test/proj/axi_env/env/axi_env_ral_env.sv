//
// Template for UVM-compliant verification environment
//

`ifndef AXI_ENV_RAL_ENV__SV
`define AXI_ENV_RAL_ENV__SV
`include "axi_env.sv"
//ToDo: Include required files here
class reg_seq extends uvm_reg_sequence;
   ral_block_axi_env regmodel;

   `uvm_object_utils(reg_seq)

   function new(string name = "");
      super.new(name);
   endfunction:new

   task pre_body();
      $cast(regmodel,model);
   endtask

   task body;
      uvm_status_e status;
      uvm_reg_data_t data;
   //ToDo :Define the user sequence here
   endtask
endclass
//Including all the required component files here
class axi_env_ral_env extends uvm_env;
   axi_scb sb;
   ral_block_axi_env regmodel;
   reg_seq ral_sequence; 
   axi_master master_agent;
   axi_slave slave_agent;
   axi_env_cov cov;
   
   ral_adp reg2host;
   master_monitor_2cov_connect mon2cov;


    `uvm_component_utils(axi_env_ral_env)

   extern function new(string name="axi_env_ral_env", uvm_component parent=null);
   extern virtual function void build_phase(uvm_phase phase);
   extern virtual function void connect_phase(uvm_phase phase);
   extern function void start_of_simulation_phase(uvm_phase phase);
   extern virtual task reset_phase(uvm_phase phase);
   extern virtual task configure_phase(uvm_phase phase);
   extern virtual task run_phase(uvm_phase phase);
   extern virtual function void report_phase(uvm_phase phase);
   extern virtual task shutdown_phase(uvm_phase phase);

endclass: axi_env_ral_env

function axi_env_ral_env::new(string name= "axi_env_ral_env",uvm_component parent=null);
   super.new(name,parent);
endfunction:new

function void axi_env_ral_env::build_phase(uvm_phase phase);
   super.build_phase(phase);
   master_agent = axi_master::type_id::create("master_agent",this); 
   slave_agent = axi_slave::type_id::create("slave_agent",this);
 
   //ToDo: Register other components,callbacks and TLM ports if added by user  

   cov = axi_env_cov::type_id::create("cov",this); //Instantiating the coverage class

   mon2cov  = master_monitor_2cov_connect::type_id::create("mon2cov", this);
   mon2cov.cov = cov;
   sb = axi_scb::type_id::create("sb",this);
   
   this.regmodel = ral_block_axi_env::type_id::create("regmodel",this);
   regmodel.build();
   ral_sequence = reg_seq::type_id::create("ral_sequence");
   ral_sequence.model = regmodel; 
   reg2host = new("reg2host");
   // ToDo: To enable backdoor access specify the HDL path
   // ToDo: Register any required callbacks
endfunction: build_phase

function void axi_env_ral_env::connect_phase(uvm_phase phase);
   super.connect_phase(phase);
   //Connecting the monitor's analysis ports with axi_scb's expected analysis exports.
   master_agent.mast_mon.mon_analysis_port.connect(sb.before_export);
   slave_agent.slv_mon.mon_analysis_port.connect(sb.after_export);
   //Other monitor element will be connected to the after export of the scoreboard
   regmodel.default_map.set_sequencer(master_agent.mast_sqr,reg2host);
   master_agent.mast_mon.mon_analysis_port.connect(cov.cov_export);
endfunction: connect_phase

function void axi_env_ral_env::start_of_simulation_phase(uvm_phase phase);
   super.start_of_simulation_phase(phase);
   `ifdef UVM_VERSION_1_0
   uvm_top.print_topology();  
   factory.print();          
   `endif
   
   `ifdef UVM_VERSION_1_1
	uvm_root::get().print_topology(); 
    uvm_factory::get().print();      
   `endif

   `ifdef UVM_POST_VERSION_1_1
	uvm_root::get().print_topology(); 
    uvm_factory::get().print();      
   `endif

   //ToDo : Implement this phase here 
endfunction: start_of_simulation_phase


task axi_env_ral_env::reset_phase(uvm_phase phase);
   super.reset_phase(phase);
   //ToDo: Reset DUT
endtask:reset_phase

task axi_env_ral_env::configure_phase (uvm_phase phase);
   super.configure_phase(phase);
   //ToDo: Configure components here
endtask:configure_phase

task axi_env_ral_env::run_phase(uvm_phase phase);
   super.run_phase(phase);
   //ToDo: Run your simulation here
endtask:run_phase

function void axi_env_ral_env::report_phase(uvm_phase phase);
   super.report_phase(phase);
   //ToDo: Implement this phase here
endfunction:report_phase

task axi_env_ral_env::shutdown_phase(uvm_phase phase);
   super.shutdown_phase(phase);
   //ToDo: Implement this phase here
endtask:shutdown_phase
`endif // AXI_ENV_RAL_ENV__SV

