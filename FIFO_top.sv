import FIFO_test::*;
import uvm_pkg::*;
`include "uvm_macros.svh"

module top;
    bit clk;
    initial begin
        forever begin
            #1 clk = ~clk;
        end
    end

    FIFO_if FIFO_intf (clk);
    FIFO DUT (FIFO_intf);

    initial begin
        uvm_config_db #(virtual FIFO_if)::set(null, "uvm_test_top", "FIFO_IF", FIFO_intf);
        run_test ("FIFO_test");
    end
endmodule