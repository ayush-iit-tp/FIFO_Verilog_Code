module synchronizer #(parameter WIDTH = 3) (
    input clk,           // Clock signal for the target domain
    input rst_n,         // Active low reset
    input [WIDTH:0] d_in, // Input data to be synchronized
    output reg [WIDTH:0] d_out // Output synchronized data
);
    reg [WIDTH:0] q1; // Intermediate signal for the first flip-flop

    always @(posedge clk) begin
        if (!rst_n) begin
            q1 <= 0;        // Reset intermediate signal
            d_out <= 0;     // Reset synchronized output
        end else begin
            q1 <= d_in;     // Pass input to the first flip-flop
            d_out <= q1;    // Pass first flip-flop's output to the second
        end
    end
endmodule
