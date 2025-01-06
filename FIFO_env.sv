package FIFO_env;

import FIFO_agent::*;
import FIFO_scoreboard::*;
import FIFO_coverage::*;
import uvm_pkg::*;
`include "uvm_macros.svh"

class FIFO_env extends uvm_env;
    `uvm_component_utils(FIFO_env)

    FIFO_agent agt;
    FIFO_scoreboard sb;
    FIFO_coverage cov;

    function new(string name = "FIFO_env", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        agt = FIFO_agent::type_id::create("agt", this);
        sb = FIFO_scoreboard::type_id::create("sb", this);
        cov = FIFO_coverage::type_id::create("cov", this);
    endfunction: build_phase

    function void connect_phase(uvm_phase phase);
        agt.agt_ap.connect(sb.sb_export);
        agt.agt_ap.connect(cov.cov_export);
    endfunction

endclass
endpackage