# Makefile for VCS

LD_LIBRARY_PATH = ${NOVAS_HOME}/share/PLI/VCS/LINUX

TEST_NAME = axi_base_test
FILELIST = filelist.f

LOG = simv.log
VERBO = MEDIUM
UVM_VER = uvm-1.2
SEED = 0
RANDSEED = 0
DEFINES = UVM
UVM_DEFINES = UVM_NO_DEPRECATED+UVM_OBJECT_MUST_HAVE_CONSTRUCTOR
USER_ARGS = 
OPTIONS = UVM_TR_RECORD + UVM_LOG_RECORD
# TRACE = UVM_CONFIG_DB_TRACE
# TRACE = UVM_OBJECTION_TRACE
TEST_LIST_NAME = testlist.f
ifndef TEST_FOLDER
override TEST_FOLDER = ${TEST_NAME}
endif

compile_switches = -sverilog -lca -debug_access+all -kdb +vcs+vcdpluson -timescale="1ns/100ps" -l comp.log -ntb_opts ${UVM_VER} -f ${FILELIST} +define+${UVM_DEFINES}+${DEFINES}
runtime_switches = -l ${TEST_FOLDER}/${LOG} +UVM_TESTNAME=${TEST_NAME} +UVM_VERBOSITY=UVM_${VERBO} ${USER_ARGS} +${TRACE} +${OPTION}

ifeq (${RANDSEED}, 1)
	runtime_switches += +ntb_random_seed_automatic
else
	runtime_switches += +ntb_random_seed=${SEED}
endif
ifdef COV
	compile_switches += -cm line+tgl+cond+branch+assert+fsm
	runtime_switches += -cm line+tgl+cond+branch+assert+fsm
endif

# SEQ = uvm_reg_bit_bash_seq

all: simv run

simv compile:
	vcs ${compile_switches}

run:
ifeq (${wildcard ${TEST_FOLDER}},)
	mkdir ${TEST_FOLDER}
endif
	./simv ${runtime_switches} +seq=${SEQ}
	cp sim.fsdb ${TEST_FOLDER}/sim.fsdb
ifdef COV
	cp -r simv.vdb ${TEST_FOLDER}/simv.vdb
endif

random: simv
	./simv ${runtime_switches} +seq=${SEQ}

regression:
	python regression_handling.py ${TEST_LIST_NAME}
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
	verdi -ssf ${TEST_FOLDER}/sim.fsdb &
# 
# verdi_tr:
# 	./simv +ntb_random_seed=$(seed) ${runtime_switches} +UVM_VERDI_TRACE
# 	verdi -play debug_files/${cmd} -nologo & 
# 
# verdi_i: simv
# 	./simv -gui=verdi +seq=${seq} +ntb_random_seed=$(seed) ${runtime_switches} +UVM_VERDI_TRACE &

verdi_cov:
	verdi -cov -covdir ${TEST_FOLDER}/simv.vdb &

verdi_merged:
	verdi -cov -covdir merged/simv.vdb &

clean:
	rm -rf csrc *.vdb *.vcd *.fsdb *.vpd \
	simv simv.daidir ucli.key vc_hdrs.h *.log \
	urgReport verdiLog novas.* vdCovLog \
	*_test* merged
