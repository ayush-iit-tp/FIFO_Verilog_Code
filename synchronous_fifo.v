module synchronous_fifo #(
    parameter DEPTH = 8,         // Number of slots in the FIFO (how much data it can hold)
    parameter DATA_WIDTH = 8     // Size of each data entry in bits (e.g., 8 bits = 1 byte)
) (
    input clk,                   // The clock signal, keeps the design synchronized
    input rst_n,                 // Active-low reset signal, resets everything when low
    input w_en, r_en,            // Write enable and read enable signals
    input [DATA_WIDTH-1:0] data_in, // The data you want to write into the FIFO
    output reg [DATA_WIDTH-1:0] data_out, // The data that comes out when you read from the FIFO
    output full, empty           // Signals to show if FIFO is full or empty
);

    // Registers and wires used inside the module
    reg [$clog2(DEPTH)-1:0] w_ptr, r_ptr;   // Write and read pointers to track positions
    reg [DATA_WIDTH-1:0] fifo [DEPTH-1:0]; // Array to store the actual data
    reg [$clog2(DEPTH):0] count;           // Tracks how many entries are currently in the FIFO

    // Reset everything or update the count based on actions
    always @(posedge clk) begin
        if (!rst_n) begin
            // Reset: Clear everything
            w_ptr <= 0; // Start write pointer at 0
            r_ptr <= 0; // Start read pointer at 0
            data_out <= 0; // Clear output data
            count <= 0; // Nothing in the FIFO, so count is 0
        end else begin
            // Adjust the count based on write and read enables
            case ({w_en, r_en}) // Check both write and read enable signals together
                2'b00: count <= count;              // No read or write, so nothing changes
                2'b01: count <= count - 1'b1;       // Read enabled, reduce the count by 1
                2'b10: count <= count + 1'b1;       // Write enabled, increase the count by 1
                2'b11: count <= count;              // Both read and write enabled, count stays the same
            endcase
        end
    end

    // Write data to the FIFO when allowed
    always @(posedge clk) begin
        if (w_en & !full) begin // Only write if write enable is on and FIFO isn’t full
            fifo[w_ptr] <= data_in; // Store the input data at the write pointer location
            w_ptr <= w_ptr + 1;     // Move the write pointer to the next position
        end
    end

    // Read data from the FIFO when allowed
    always @(posedge clk) begin
        if (r_en & !empty) begin // Only read if read enable is on and FIFO isn’t empty
            data_out <= fifo[r_ptr]; // Output the data at the read pointer location
            r_ptr <= r_ptr + 1;      // Move the read pointer to the next position
        end
    end

    // Check if FIFO is full or empty
    assign full = (count == DEPTH); // If count matches depth, FIFO is full
    assign empty = (count == 0);    // If count is zero, FIFO is empty

endmodule
