module asynchronous_fifo #(parameter DEPTH = 8, DATA_WIDTH = 8) (
    input wclk, wrst_n, rclk, rrst_n,          // Clocks and resets
    input w_en, r_en,                         // Write & read enables
    input [DATA_WIDTH-1:0] data_in,           // Input data
    output [DATA_WIDTH-1:0] data_out,         // Output data
    output full, empty                        // Status flags
);
    parameter PTR_WIDTH = $clog2(DEPTH);       // Pointer width based on depth

    wire [PTR_WIDTH:0] g_wptr_sync, g_rptr_sync; // Synchronized pointers
    wire [PTR_WIDTH:0] b_wptr, g_wptr, b_rptr, g_rptr;

    // Instantiate components
    synchronizer #(PTR_WIDTH) sync_wptr (rclk, rrst_n, g_wptr, g_wptr_sync);
    synchronizer #(PTR_WIDTH) sync_rptr (wclk, wrst_n, g_rptr, g_rptr_sync);
    wptr_handler #(PTR_WIDTH) wptr_h (wclk, wrst_n, w_en, g_rptr_sync, b_wptr, g_wptr, full);
    rptr_handler #(PTR_WIDTH) rptr_h (rclk, rrst_n, r_en, g_wptr_sync, b_rptr, g_rptr, empty);
    fifo_mem #(DEPTH, DATA_WIDTH, PTR_WIDTH) fifom (wclk, w_en, rclk, r_en, b_wptr, b_rptr, data_in, data_out);
endmodule
