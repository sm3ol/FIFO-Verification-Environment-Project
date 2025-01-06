package FIFO_scoreboard;
import FIFO_seq_item::*;
import shared_package::*;
import uvm_pkg::*;
`include "uvm_macros.svh"

class FIFO_scoreboard extends uvm_scoreboard;
`uvm_component_utils(FIFO_scoreboard)
uvm_analysis_export #(FIFO_seq_item) sb_export;
uvm_tlm_analysis_fifo #(FIFO_seq_item) sb_fifo;
FIFO_seq_item seq_item_sb;

parameter FIFO_WIDTH = 16;
parameter FIFO_DEPTH = 8;
logic [FIFO_WIDTH-1:0] data_out_ref;
logic wr_ack_ref, overflow_ref;
logic full_ref, empty_ref, almostfull_ref, almostempty_ref, underflow_ref;
/////////////
logic [3:0] queue_size;
reg [FIFO_WIDTH-1:0] queue_ref [$];
/////////////		
logic [FIFO_WIDTH-1:0] fifo_memory[FIFO_DEPTH-1:0];  // Simulate internal FIFO memory
int wr_ptr = 0;  // Write pointer
int rd_ptr = 0;  // Read pointer
int count = 0;   // Number of elements in the FIFO


function new(string name = "FIFO_scoreboard", uvm_component parent = null);
    super.new(name, parent);
endfunction

function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    sb_export = new("sb_export", this);
    sb_fifo = new("sb_fifo", this);
endfunction

function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    sb_export.connect(sb_fifo.analysis_export);
endfunction

task run_phase(uvm_phase phase);
super.run_phase(phase);
forever begin
    sb_fifo.get(seq_item_sb);
    ref_model(seq_item_sb);
    if(seq_item_sb.data_out != data_out_ref) begin
        `uvm_error("run_phase", $sformatf("Comparison failed, Transactio recieved by the DUT: %s While the reference out:0b%0b", seq_item_sb.convert2string(), data_out_ref));
        error_count++;
    end
    else begin
        `uvm_info("run_phase", $sformatf("Correct FIFO out: %s", seq_item_sb.convert2string()), UVM_HIGH);
        correct_count++;
    end
end
endtask


task ref_model(FIFO_seq_item seq_item_chk);
queue_size = queue_ref.size(); // Get the size of the queue

    if (!seq_item_chk.rst_n) begin
        // Reset all pointers and flags
        for(integer i = 0; i < queue_size; i++) begin
            queue_ref.pop_front();  // Clear the queue when reset is active
        end
        wr_ptr = 0;
        rd_ptr = 0;
        count = 0;
        data_out_ref = '0; // Initialize data_out_ref properly
        wr_ack_ref = 0;
        overflow_ref = 0;
        underflow_ref = 0;
        full_ref = 0;
        empty_ref = 1; // FIFO starts empty
        almostfull_ref = 0;
        almostempty_ref = 0;
        queue_size = queue_ref.size();  // Update the queue size after clearing
    end
    else begin
        // Case block for different read/write enable scenarios
        case ({seq_item_chk.wr_en, seq_item_chk.rd_en})
            2'b00: begin
                // No read, no write, maintain current output
                data_out_ref = data_out_ref;
            end
            2'b10: begin
                // Write operation only
                if (queue_size != FIFO_DEPTH) begin
                    queue_ref.push_back(seq_item_chk.data_in);  // Push data to queue
                end
                data_out_ref = data_out_ref;
            end
            2'b01: begin
                // Read operation only
                if (queue_size != 0) begin
                    data_out_ref = queue_ref.pop_front();  // Pop data from queue
                end
            end
            2'b11: begin
                // Both read and write operation
                if (queue_size == 0) begin
                    // If empty, write new data
                    queue_ref.push_back(seq_item_chk.data_in);
                    data_out_ref = data_out_ref;
                end
                else if (queue_size == FIFO_DEPTH) begin
                    // If full, read data
                    data_out_ref = queue_ref.pop_front();
                end
                else begin
                    // Normal case: Read and then write
                    data_out_ref = queue_ref.pop_front();
                    queue_ref.push_back(seq_item_chk.data_in);
                end
            end
        endcase

        // Handle Overflow condition
        if (full_ref && seq_item_chk.wr_en) begin
            overflow_ref = 1;
        end else begin
            overflow_ref = 0;
        end

        // Handle Underflow condition
        if (empty_ref && seq_item_chk.rd_en) begin
            underflow_ref = 1;
        end else begin
            underflow_ref = 0;
        end

        // Manage Count Logic
        if ({seq_item_chk.wr_en, seq_item_chk.rd_en} == 2'b10 && !full_ref) begin
            count = count + 1;  // Increment on write
        end
        else if ({seq_item_chk.wr_en, seq_item_chk.rd_en} == 2'b01 && !empty_ref) begin
            count = count - 1;  // Decrement on read
        end

        // Calculate reference flags based on the current state of the FIFO
        full_ref = (count == FIFO_DEPTH) ? 1 : 0;
        empty_ref = (count == 0) ? 1 : 0;
        almostfull_ref = (count == FIFO_DEPTH - 1) ? 1 : 0;
        almostempty_ref = (count == 1) ? 1 : 0;
    end
endtask 

endclass
endpackage