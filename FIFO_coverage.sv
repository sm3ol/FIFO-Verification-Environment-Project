package FIFO_coverage;
import FIFO_seq_item::*;
import shared_package::*;
import uvm_pkg::*;
`include "uvm_macros.svh" 

class FIFO_coverage extends uvm_component;
    `uvm_component_utils(FIFO_coverage)
    uvm_analysis_export #(FIFO_seq_item) cov_export;
    uvm_tlm_analysis_fifo #(FIFO_seq_item) cov_fifo;
    FIFO_seq_item seq_item_cov;

        covergroup write_read_covgrp;
            // Define coverpoints for the signals
            wr_en_lable       : coverpoint seq_item_cov.wr_en;
            rd_en_lable       : coverpoint seq_item_cov.rd_en;
            full_lable        : coverpoint seq_item_cov.full;
            almostfull_lable  : coverpoint seq_item_cov.almostfull;
            overflow_lable    : coverpoint seq_item_cov.overflow;
            wr_ack_lable      : coverpoint seq_item_cov.wr_ack;
            empty_lable       : coverpoint seq_item_cov.empty;
            almostempty_lable : coverpoint seq_item_cov.almostempty;
            underflow_lable   : coverpoint seq_item_cov.underflow;

            // Cross coverage
            write_enable_full_bin        : cross wr_en_lable, full_lable;
            write_enable_almostfull_bin  : cross wr_en_lable, almostfull_lable;
            write_enable_overflow_bin    : cross wr_en_lable, overflow_lable
            {
                ignore_bins write_0_overflow_1 = (binsof(wr_en_lable) intersect {0} && binsof(overflow_lable) intersect {1});
            }
            write_enable_wr_ack_bin      : cross wr_en_lable, wr_ack_lable 
            {
                ignore_bins write_0_wr_ack_1 = (binsof(wr_en_lable) intersect {0} && binsof(wr_ack_lable) intersect {1});
            }
            read_enable_empty_bin        : cross rd_en_lable, empty_lable;
            read_enable_almostempty_bin  : cross rd_en_lable, almostempty_lable;
            read_enable_underflow_bin    : cross rd_en_lable, underflow_lable
            {
                ignore_bins read_0_underflow_1 = (binsof(rd_en_lable) intersect {0} && binsof(underflow_lable) intersect {1});
            }
        endgroup

    function new(string name = "FIFO_coverage", uvm_component parent = null);
        super.new(name, parent);
        write_read_covgrp = new();
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        cov_export = new("cov_export", this);
        cov_fifo = new("cov_fifo", this);
    endfunction

    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        cov_export.connect(cov_fifo.analysis_export);
    endfunction

    task run_phase(uvm_phase phase);
        super.run_phase(phase);
        forever begin
            cov_fifo.get(seq_item_cov);
            write_read_covgrp.sample();
        end
    endtask

endclass
endpackage