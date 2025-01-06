package FIFO_main_sequence;
import FIFO_seq_item::*;
import uvm_pkg::*;
`include "uvm_macros.svh"

class FIFO_main_sequence extends uvm_sequence #(FIFO_seq_item);
`uvm_object_utils(FIFO_main_sequence)

FIFO_seq_item seq_item;

function new (string name = "FIFO_main_sequence");
    super.new(name);
endfunction

task body;
        repeat(10000) begin
        seq_item = FIFO_seq_item::type_id::create("seq_item");
        start_item(seq_item);
        assert(seq_item.randomize());
        finish_item(seq_item);
        end

        repeat (1000) begin
            seq_item.data_in = $random;
            seq_item.rst_n = 1;
            seq_item.rd_en = 1;
            seq_item.wr_en = 0;
        end
        repeat (10) begin      
            seq_item.data_in = $random;
            seq_item.rst_n = 1;
            seq_item.rd_en = 0;
            seq_item.wr_en = 0;
        end
endtask
endclass
endpackage




