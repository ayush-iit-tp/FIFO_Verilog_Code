module rptr_handler #(parameter PTR_WIDTH = 3) (
    input rclk, rrst_n, r_en,                // Read clock, reset, read enable
    input [PTR_WIDTH:0] g_wptr_sync,         // Synchronized write pointer (Gray)
    output reg [PTR_WIDTH:0] b_rptr, g_rptr, // Binary & Gray read pointers
    output reg empty                         // Empty flag
);
    reg [PTR_WIDTH:0] b_rptr_next, g_rptr_next; // Next values of pointers
    wire rempty;                               // Internal empty condition

    // Increment binary read pointer on valid read
    assign b_rptr_next = b_rptr + (r_en & !empty);

    // Convert binary to Gray Code
    assign g_rptr_next = (b_rptr_next >> 1) ^ b_rptr_next;

    always @(posedge rclk or negedge rrst_n) begin
        if (!rrst_n) begin
            b_rptr <= 0;  // Reset binary read pointer
            g_rptr <= 0;  // Reset Gray read pointer
        end else begin
            b_rptr <= b_rptr_next; // Update binary pointer
            g_rptr <= g_rptr_next; // Update Gray pointer
        end
    end

    // Detect FIFO empty condition
    assign rempty = (g_wptr_sync == g_rptr_next);

    always @(posedge rclk or negedge rrst_n) begin
        if (!rrst_n)
            empty <= 1; // Reset empty flag
        else
            empty <= rempty; // Update empty flag
    end
endmodule
