`timescale 1ns / 1ps
module tb_synchronous_fifo();

    parameter DEPTH = 8;
    parameter DATA_WIDTH = 8;

    // Testbench signals
    reg clk;
    reg rst_n;
    reg w_en, r_en;
    reg [DATA_WIDTH-1:0] data_in;
    wire [DATA_WIDTH-1:0] data_out;
    wire full, empty;

    // Instantiate the FIFO module
    synchronous_fifo #(
        .DEPTH(DEPTH),
        .DATA_WIDTH(DATA_WIDTH)
    ) fifo_inst (
        .clk(clk),
        .rst_n(rst_n),
        .w_en(w_en),
        .r_en(r_en),
        .data_in(data_in),
        .data_out(data_out),
        .full(full),
        .empty(empty)
    );

    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk; // Generate a clock with a period of 10 ns
    end

    // Test sequence
    initial begin
        // Initialize signals
        rst_n = 0;
        w_en = 0;
        r_en = 0;
        data_in = 0;

        // Apply reset
        #10 rst_n = 1; // Release reset after 10 ns

        // Write some data
        #10 w_en = 1; data_in = 8'hA1; // Write A1
        #10 data_in = 8'hB2; // Write B2
        #10 data_in = 8'hC3; // Write C3
        #10 w_en = 0; // Stop writing

        // Read the data
        #10 r_en = 1; // Start reading
        #30 r_en = 0; // Stop reading

        // Write and read simultaneously
        #10 w_en = 1; data_in = 8'hD4; // Write D4
        #10 r_en = 1; data_in = 8'hE5; // Write E5 while reading
        #10 w_en = 0; r_en = 0; // Stop all operations

        // Finish simulation
        #50 $stop;
    end

endmodule
