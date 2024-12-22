module wptr_handler #(parameter PTR_WIDTH = 3) (
    input wclk, wrst_n, w_en,                // Write clock, reset, write enable
    input [PTR_WIDTH:0] g_rptr_sync,         // Synchronized read pointer (Gray)
    output reg [PTR_WIDTH:0] b_wptr, g_wptr, // Binary & Gray write pointers
    output reg full                          // Full flag
);
    reg [PTR_WIDTH:0] b_wptr_next, g_wptr_next; // Next values of pointers
    wire wfull;                               // Internal full condition

    // Increment binary write pointer on valid write
    assign b_wptr_next = b_wptr + (w_en & !full);

    // Convert binary to Gray Code
    assign g_wptr_next = (b_wptr_next >> 1) ^ b_wptr_next;

    always @(posedge wclk or negedge wrst_n) begin
        if (!wrst_n) begin
            b_wptr <= 0;  // Reset binary write pointer
            g_wptr <= 0;  // Reset Gray write pointer
        end else begin
            b_wptr <= b_wptr_next; // Update binary pointer
            g_wptr <= g_wptr_next; // Update Gray pointer
        end
    end

    // Detect FIFO full condition
    assign wfull = (g_wptr_next == {~g_rptr_sync[PTR_WIDTH:PTR_WIDTH-1], g_rptr_sync[PTR_WIDTH-2:0]});

    always @(posedge wclk or negedge wrst_n) begin
        if (!wrst_n)
            full <= 0; // Reset full flag
        else
            full <= wfull; // Update full flag
    end
endmodule
