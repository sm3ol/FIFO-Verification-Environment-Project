package FIFO_monitor;
import FIFO_seq_item::*;
import uvm_pkg::*;
`include "uvm_macros.svh"

class FIFO_monitor extends uvm_monitor;
`uvm_component_utils (FIFO_monitor)

virtual FIFO_if FIFO_monitor_vif;
FIFO_seq_item rsp_seq_item;
uvm_analysis_port #(FIFO_seq_item) mon_ap;

function new(string name = "FIFO_monitor", uvm_component parent = null);
    super.new(name, parent);
endfunction


function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    mon_ap = new("mon_ap", this);
endfunction

task run_phase(uvm_phase phase);
    super.run_phase(phase);
    forever begin
        rsp_seq_item = FIFO_seq_item::type_id::create("rsp_seq_item");
        @(negedge FIFO_monitor_vif.clk);
        rsp_seq_item.data_in = FIFO_monitor_vif.data_in;
        rsp_seq_item.rst_n = FIFO_monitor_vif.rst_n;
        rsp_seq_item.rd_en = FIFO_monitor_vif.rd_en;
        rsp_seq_item.wr_en = FIFO_monitor_vif.wr_en;
        rsp_seq_item.data_out = FIFO_monitor_vif.data_out;
        rsp_seq_item.wr_ack = FIFO_monitor_vif.wr_ack;
        rsp_seq_item.full = FIFO_monitor_vif.full;
        rsp_seq_item.empty = FIFO_monitor_vif.empty;
        rsp_seq_item.overflow = FIFO_monitor_vif.overflow;
        rsp_seq_item.almostempty = FIFO_monitor_vif.almostempty;
        rsp_seq_item.almostfull = FIFO_monitor_vif.almostfull;
        rsp_seq_item.underflow = FIFO_monitor_vif.underflow;
        mon_ap.write(rsp_seq_item);
        `uvm_info ("run_phase", rsp_seq_item.convert2string(),UVM_HIGH)
    end
endtask
endclass
endpackage  


