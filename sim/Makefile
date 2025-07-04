# Makefile for VCS

CES64 = TRUE
LD_LIBRARY_PATH = ${NOVAS_HOME}/share/PLI/VCS/LINUX

test = axi_base_test
root_path = ${shell pwd}/..
program_path = ${root_path}/test/programs
# PROGRAM_TOP = ${program_path}/test.sv
package_path = ${root_path}/test/packages
PACKAGES = ${package_path}/axi_globals_pkg.sv ${package_path}/axi_stimulus_pkg.sv ${package_path}/axi_env_pkg.sv ${package_path}/axi_test_pkg.sv
TEST_TOP = ${PACKAGES} ${PROGRAM_TOP}
HARNESS_TOP = ${root_path}/test/tb_top.sv

rtl_path = ${root_path}/src
DUT = ${shell find ${rtl_path} -name "*.v" -o -name "*.sv"}

INCDIR = ${rtl_path}+${root_path}/test

TOP = ${TEST_TOP} ${HARNESS_TOP}
log = simv.log
verbosity = UVM_MEDIUM
uvm_ver = uvm-1.2
seed = 1
defines = 
uvm_defines = UVM_NO_DEPRECATED+UVM_OBJECT_MUST_HAVE_CONSTRUCTOR
plus = 
option = UVM_TR_RECORD + UVM_LOG_RECORD
# trace = UVM_CONFIG_DB_TRACE
# trace = UVM_OBJECTION_TRACE
testlist_name = testlist.f
ifndef test_folder
override test_folder = ${test}
endif

compile_switches = -sverilog -lca -debug_access+all -kdb +vcs+vcdpluson -timescale="1ns/100ps" -l comp.log -ntb_opts ${uvm_ver} ${DUT} ${TOP} +define+${uvm_defines}+${defines} \
									 +incdir+${INCDIR} \
									 -assert svaext \
									 -assert enable_diag \
									 -assert vpiSeqBeginTime \
							     -assert vpiSeqFail \
                   -assert enable_hier
runtime_switches = -l ${test_folder}/${log} +UVM_TESTNAME=${test} +UVM_VERBOSITY=${verbosity} +${plus} +${trace} +${option} \
									 +fsdb+sva_success \
                   -assert success

ifdef coverage
	compile_switches += -cm line+tgl+cond+branch+assert+fsm
	runtime_switches += -cm line+tgl+cond+branch+assert+fsm
endif

# seq = uvm_reg_bit_bash_seq

all: simv run

simv compile: ${DUT} ${TOP}
ifeq (${CES64},TRUE)
	vcs -full64 ${compile_switches}
	@echo "Compiled in 64-bit mode"
else
	vcs ${compile_switches}
	@echo "Compiled in 32-bit mode"
endif

run:
ifeq (${wildcard ${test_folder}},)
	mkdir ${test_folder}
endif
	./simv +ntb_random_seed=${seed} ${runtime_switches} +seq=${seq}
	cp sim.fsdb ${test_folder}/sim.fsdb
ifdef coverage
	cp -r simv.vdb ${test_folder}/simv.vdb
endif

random: simv
	./simv +ntb_random_seed_automatic ${runtime_switches} +seq=${seq}

regression:
	python regression_handling.py $(testlist_name)
	urg -full64 -dir *_test*/simv.vdb -dbname merged/simv.vdb
	

# ral:
# 	ralgen -uvm -t host_regmodel host.ralf

cover:
	urg -full64 -dir simv.vdb
	urg -full64 -dir simv.vdb -format text

# dve:
# 	dve -vpd vcdplus.vpd -session debug_files/$(tcl) &
# 
# dve_tr:
# 	./simv +ntb_random_seed=$(seed) ${runtime_switches}
# 	dve -vpd vcdplus.vpd -session debug_files/$(tr) &
# 
# dve_i: simv
# 	./simv -gui=dve +ntb_random_seed=$(seed) ${runtime_switches} +seq=${seq} &
# 
verdi:
	verdi -ssf ${test_folder}/sim.fsdb &
# 
# verdi_tr:
# 	./simv +ntb_random_seed=$(seed) ${runtime_switches} +UVM_VERDI_TRACE
# 	verdi -play debug_files/${cmd} -nologo & 
# 
# verdi_i: simv
# 	./simv -gui=verdi +seq=${seq} +ntb_random_seed=$(seed) ${runtime_switches} +UVM_VERDI_TRACE &

verdi_cov:
	verdi -cov -covdir ${test_folder}/simv.vdb &

verdi_merged:
	verdi -cov -covdir merged/simv.vdb &

list_tests:
	@cat ${root_path}/testlists/${testlist_name}

clean:
	rm -rf csrc *.vdb *.vcd *.fsdb *.vpd \
	simv simv.daidir ucli.key vc_hdrs.h *.log \
	urgReport verdiLog novas.* vdCovLog \
	*_test* merged
