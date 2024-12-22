module fifo_mem #(parameter DEPTH = 8, DATA_WIDTH = 8, PTR_WIDTH = 3) (
    input wclk, w_en, rclk, r_en,               // Clocks and enables
    input [PTR_WIDTH:0] b_wptr, b_rptr,         // Binary write & read pointers
    input [DATA_WIDTH-1:0] data_in,             // Data to write
    output reg [DATA_WIDTH-1:0] data_out        // Data to read
);
    reg [DATA_WIDTH-1:0] fifo [0:DEPTH-1]; // FIFO memory array

    always @(posedge wclk) begin
        if (w_en)
            fifo[b_wptr[PTR_WIDTH-1:0]] <= data_in; // Write data
    end

    assign data_out = fifo[b_rptr[PTR_WIDTH-1:0]]; // Read data
endmodule
