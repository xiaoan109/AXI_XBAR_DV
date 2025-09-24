# How to use opentitan uvmdvgen to generate dv files


### 1. Use ${OPENTITAN_ROOT}/utils/uvmdvgen.py

cd ${OPENTITAN_ROOT}

./utils/uvmdvgen.py axi -e -ea axi_mst axi_slv -eo [env dir]

./utils/uvmdvgen.py axi_mst -a -ao [agent dir]

./utils/uvmdvgen.py axi_slv -a -ao [agent dir]

### 2. Add common pkgs, axi pkgs and intf/sva/tb files to filelist

reference to dv/sim/filelist.f

### 3. Use your customize Makefile/perl/python scripts to start simulation

In my proj:

cd sim && make

### 4. Complete template source files to make test passed

At the very beginning, the make output is like this:

UVM_INFO @ 0 ps: reporter [RNTST] Running test axi_base_test...

UVM_FATAL @         0 ps: (dv_base_env_cfg.sv:75) [cfg] Check failed (is_initialized) Please invoke initialize() before randomizing this object.

To solve this fatal, one way is to add super.initialize() to the initialize function in class axi_env_cfg. 

Then we get the next error:

UVM_INFO @ 0 ps: reporter [RNTST] Running test axi_base_test...

UVM_FATAL @         0 ps: (dv_base_reg_block.sv:117) [dv_base_reg_block] this method is not supposed to be called directly!

This is caused by dv_base_env_cfg's call of reg_blk.build. So we change super.initialize() to is_initialized = 1'b1 directly.

And the get a Null object access error. To solve this, we add ral_model_names.delete() to he initialize function in class axi_env_cfg because currently no ral is used.

### 5. Add dut AXI XBAR

From submodule de/axi, we can select pulp axi_xbar_intf as our dut.

reference to dv/sim/dut_filelist.f

### 6. Set Master and Slave number both to 1

Test the simplest case, 1M1S.

Now complete the TODOs in every UVC.

#### 6.1 Complete axi_mst_item

Add all variables like id,addr,data,delay...

#### 6.2 Complete axi_mst_driver

A standard AXI master driver is completed.

#### 6.3 Complete axi_mst_random/write/read_seq

Send num_txn axi_mst_item to driver.

#### 6.4 Add a memory partition config to help us generate addr

Just like we set in the dut memory map(currently 0-0x1fff and 0x2000-0x3fff are set, at least 2 region, but the dut slave only support region 0 and

region 1 will going to the default slave and return a DECERR)

#### 6.5 Start a smoke test

We can see the addr between 0x0-0x1fff is stuck because of the miss of slave driver and the addr between 0x2000-0x3fff is returned with a DECERR response.

#### 6.6 Complete axi_slave_driver/sequencer(reactive driver)

A standard AXI slave driver(reactive driver) is completed.

An AXI slave sequencer is completed.

#### 6.7 Complete axi_slave_seq

Forever generate responses. In the future we will add a memory model in slave.

BUG: We don't set a constraint for req addr to avoid cross 4KiB problem.

TODO: Solve the above question.

#### ->TODO 6.8 Complete full UVCs(memory, monitor,scb...)
