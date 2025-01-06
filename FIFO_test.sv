package FIFO_test;
import FIFO_config_obj::*;
import FIFO_env::*;
import FIFO_reset_sequence::*;
import FIFO_main_sequence::*;
import FIFO_sequencer::*;
import uvm_pkg::*;
`include "uvm_macros.svh"

class FIFO_test extends uvm_test;
`uvm_component_utils (FIFO_test)
FIFO_env env;
FIFO_config_obj FIFO_config_obj_test;
virtual FIFO_if FIFO_driver_vif;
FIFO_reset_sequence reset_seq;
FIFO_main_sequence main_seq;

function new (string name = "FIFO_test", uvm_component parent = null);
    super.new(name,parent);
endfunction

function void build_phase (uvm_phase phase);
    super.build_phase(phase);
    env = FIFO_env::type_id::create("env",this);
    FIFO_config_obj_test = FIFO_config_obj::type_id::create("FIFO_config_obj_test");
    reset_seq = FIFO_reset_sequence::type_id::create("reset_seq");
    main_seq = FIFO_main_sequence::type_id::create("main_seq");


    if (!uvm_config_db #(virtual FIFO_if)::get(this, "", "FIFO_IF", FIFO_config_obj_test.FIFO_config_vif)) begin
        `uvm_fatal("build phase", "Driver - Unable to get the virtual interface of the FIFO from the uvm_config_db");
    end  

    uvm_config_db #(FIFO_config_obj)::set(this, "*", "CFG",FIFO_config_obj_test);
endfunction

task run_phase (uvm_phase phase);
    super.run_phase(phase);
    phase.raise_objection(this);
    `uvm_info("run_phase", "Reset Asserted", UVM_LOW)
    reset_seq.start(env.agt.sqr);
    `uvm_info("run_phase", "Reset Deasserted", UVM_LOW)

    `uvm_info("run_phase", "Stimulus Generation Started", UVM_LOW)
    main_seq.start(env.agt.sqr);
    `uvm_info("run_phase", "Stimulus Generation Ended", UVM_LOW)

    phase.drop_objection(this);
endtask
endclass
endpackage
