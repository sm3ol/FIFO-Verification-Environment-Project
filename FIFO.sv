module FIFO(FIFO_if.DUT DUT_if);

    localparam max_fifo_addr = $clog2(DUT_if.FIFO_DEPTH);

    logic [DUT_if.FIFO_WIDTH-1:0] mem [DUT_if.FIFO_DEPTH-1:0];

    logic [max_fifo_addr-1:0] wr_ptr, rd_ptr;
    logic [max_fifo_addr:0] count;
always @(posedge DUT_if.clk or negedge DUT_if.rst_n) begin
    if (!DUT_if.rst_n) begin
        wr_ptr <= 0;
        DUT_if.overflow <= 0;
        DUT_if.wr_ack <= 0;
    end else if (DUT_if.wr_en && count < DUT_if.FIFO_DEPTH) begin
        mem[wr_ptr] <= DUT_if.data_in;
        DUT_if.wr_ack <= 1;
        wr_ptr <= wr_ptr + 1;
        DUT_if.overflow <= 0; // No overflow since we're not full yet
    end else if (DUT_if.wr_en && DUT_if.full) begin
        DUT_if.wr_ack <= 0;  // Disable write acknowledgment
        DUT_if.overflow <= 1;  // Set overflow when wr_en is high and FIFO is full
    end else begin
        DUT_if.wr_ack <= 0;
        DUT_if.overflow <= 0; // No overflow when not writing
    end
end

    always @(posedge DUT_if.clk or negedge DUT_if.rst_n) begin
        if (!DUT_if.rst_n) begin
            rd_ptr <= 0;
            DUT_if.underflow <= 0;  //I add this line to reset underflow
        end
        else if (DUT_if.rd_en && count != 0) begin
            DUT_if.data_out <= mem[rd_ptr];
            rd_ptr <= rd_ptr + 1;
            DUT_if.underflow<=0;
        end
        else begin
            if (DUT_if.empty && DUT_if.rd_en) begin
                DUT_if.underflow <= 1;
            end

            else 
                DUT_if.underflow <= 0;
        
        end
    end

    always @(posedge DUT_if.clk or negedge DUT_if.rst_n) begin
        if (!DUT_if.rst_n) begin
            count <= 0;
        end
        else begin
            if ({DUT_if.wr_en, DUT_if.rd_en} == 2'b10 && !DUT_if.full) 
                count <= count + 1;
            else if ({DUT_if.wr_en, DUT_if.rd_en} == 2'b01 && !DUT_if.empty)
                count <= count - 1;
            else if (DUT_if.wr_en && DUT_if.rd_en && DUT_if.empty )
                count<=count+1;
            else if ( DUT_if.wr_en && DUT_if.rd_en && DUT_if.full )
                count <= count - 1;
                    
            
        end
    end

    assign DUT_if.full = (count == DUT_if.FIFO_DEPTH)? 1 : 0;
    assign DUT_if.empty = (count == 0)? 1 : 0;
    assign DUT_if.almostfull = (count == DUT_if.FIFO_DEPTH-1)? 1 : 0; 
    assign DUT_if.almostempty = (count == 1)? 1 : 0;
     always_comb begin
             full_assertion: assert ((count==DUT_if.FIFO_DEPTH)===DUT_if.full) ;
             almost_full_assertion: assert final(DUT_if.almostfull == (count == DUT_if.FIFO_DEPTH - 1)) else $error("Almost full condition failed");

             empty_assertion: assert final (DUT_if.empty== (count==0)? 1 : 0) ;

             almostempty_assertion: assert  final ( DUT_if.almostempty==(count == 1)? 1 : 0);
         end

          property p1;
              @(posedge DUT_if.clk) disable iff (!DUT_if.rst_n) 
                  (DUT_if.wr_en && count < DUT_if.FIFO_DEPTH) |=> (DUT_if.wr_ack);
          endproperty 

          property p2;
              @(posedge DUT_if.clk) disable iff (!DUT_if.rst_n) 
                  (!DUT_if.wr_en || count >= DUT_if.FIFO_DEPTH) |=> (!DUT_if.wr_ack);
          endproperty


          property p3;
          @(posedge DUT_if.clk) disable iff (!DUT_if.rst_n)
              (DUT_if.wr_en && DUT_if.full) |=> (DUT_if.overflow);
           endproperty

          

          property p5;
              @(posedge DUT_if.clk) disable iff (!DUT_if.rst_n) 
                  (count == DUT_if.FIFO_DEPTH) |-> (DUT_if.full);
          endproperty

          property p6;
              @(posedge DUT_if.clk) disable iff (!DUT_if.rst_n) 
                  (count !== DUT_if.FIFO_DEPTH) |-> (!DUT_if.full);
          endproperty

          property p7;
              @(posedge DUT_if.clk) disable iff (!DUT_if.rst_n) 
                  (count == 0) |-> (DUT_if.empty);
          endproperty

          property p8;
              @(posedge DUT_if.clk) disable iff (!DUT_if.rst_n) 
                  (count !== 0) |-> (!DUT_if.empty);
          endproperty

          property p9;
              @(posedge DUT_if.clk) disable iff (!DUT_if.rst_n) 
                  (count == DUT_if.FIFO_DEPTH-1) |-> (DUT_if.almostfull);
          endproperty

          property p10;
              @(posedge DUT_if.clk) disable iff (!DUT_if.rst_n) 
                  (count !== DUT_if.FIFO_DEPTH-1) |-> (!DUT_if.almostfull);
          endproperty

          property p11;
              @(posedge DUT_if.clk) disable iff (!DUT_if.rst_n) 
                  (count == 1) |-> (DUT_if.almostempty);
          endproperty

          property p12;
              @(posedge DUT_if.clk) disable iff (!DUT_if.rst_n) 
                  (count !== 1) |-> (!DUT_if.almostempty);
          endproperty

         
          property p13;
              @(posedge DUT_if.clk) disable iff (!DUT_if.rst_n) 
                  (DUT_if.empty && DUT_if.rd_en) |=> (DUT_if.underflow);       
          endproperty

            // Assertion for Property p1
p1_assertion: assert property (p1) else 
    $display("ERROR: wr_ack not asserted when wr_en is high and FIFO is not full at time %0t", $time);

// Assertion for Property p2
p2_assertion: assert property (p2) else 
    $display("ERROR: wr_ack asserted when wr_en is low or FIFO is full at time %0t", $time);

// Assertion for Property p3
p3_assertion: assert property (p3) else 
    $display("ERROR: Overflow not asserted when wr_en is high and FIFO is full at time %0t", $time);

// // Assertion for Property p4
// p4_assertion: assert property (p4) else 
//     $display("ERROR: Overflow asserted when wr_en is low or FIFO is not full at time %0t", $time);

// Assertion for Property p5
p5_assertion: assert property (p5) else 
    $display("ERROR: FIFO full flag not asserted when count equals FIFO depth at time %0t", $time);

// Assertion for Property p6
p6_assertion: assert property (p6) else 
    $display("ERROR: FIFO full flag asserted when count does not equal FIFO depth at time %0t", $time);

// Assertion for Property p7
p7_assertion: assert property (p7) else 
    $display("ERROR: FIFO empty flag not asserted when count is zero at time %0t", $time);

// Assertion for Property p8
p8_assertion: assert property (p8) else 
    $display("ERROR: FIFO empty flag asserted when count is not zero at time %0t", $time);

// Assertion for Property p9
p9_assertion: assert property (p9) else 
    $display("ERROR: FIFO almostfull flag not asserted when count equals FIFO depth - 2 at time %0t", $time);

// Assertion for Property p10
p10_assertion: assert property (p10) else 
    $display("ERROR: FIFO almostfull flag asserted when count does not equal FIFO depth - 2 at time %0t", $time);

// Assertion for Property p11
p11_assertion: assert property (p11) else 
    $display("ERROR: FIFO almostempty flag not asserted when count equals 1 at time %0t", $time);

// Assertion for Property p12
p12_assertion: assert property (p12) else 
    $display("ERROR: FIFO almostempty flag asserted when count does not equal 1 at time %0t", $time);


// Assertion for Property p14
p14_assertion: assert property (p13) else 
    $display("ERROR: Underflow asserted when rd_en is low or FIFO is not empty at time %0t", $time);


// Cover for Property p1
cover property (p1);

// Cover for Property p2
cover property (p2);

// Cover for Property p3
cover property (p3);

// Cover for Property p4
//over property (p4);

// Cover for Property p5
cover property (p5);

// Cover for Property p6
cover property (p6);

// Cover for Property p7
cover property (p7);

// Cover for Property p8
cover property (p8);

// Cover for Property p9
cover property (p9);

// Cover for Property p10
cover property (p10);

// Cover for Property p11
cover property (p11);

// Cover for Property p12
cover property (p12);

// Cover for Property p13
cover property (p13);


endmodule
