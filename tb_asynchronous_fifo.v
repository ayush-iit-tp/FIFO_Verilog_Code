module tb_asynchronous_fifo;

  parameter DATA_WIDTH = 8; // Width of the data (8 bits per data element)

  // Declare wires and registers for connecting the FIFO module
  wire [DATA_WIDTH-1:0] data_out; // Data output from FIFO
  wire full;                     // Indicates FIFO is full
  wire empty;                    // Indicates FIFO is empty
  reg [DATA_WIDTH-1:0] data_in;  // Data input to FIFO
  reg w_en, wclk, wrst_n;        // Write enable, write clock, and write reset
  reg r_en, rclk, rrst_n;        // Read enable, read clock, and read reset

  // Queue to hold written data for comparison during read operations
  reg [DATA_WIDTH-1:0] wdata_q[$], wdata; // Dynamic queue to simulate write-read behavior

  // Instantiate the asynchronous FIFO module
  asynchronous_fifo as_fifo (
    .wclk(wclk), .wrst_n(wrst_n), .rclk(rclk), .rrst_n(rrst_n),
    .w_en(w_en), .r_en(r_en), .data_in(data_in), .data_out(data_out),
    .full(full), .empty(empty)
  );

  // Generate write clock (wclk) with a period of 20ns (toggle every 10ns)
  always #10 wclk = ~wclk;

  // Generate read clock (rclk) with a period of 70ns (toggle every 35ns)
  always #35 rclk = ~rclk;

  // Initial block for write-side operations
  initial begin
    wclk = 1'b0;        // Initialize write clock to 0
    wrst_n = 1'b0;      // Assert write reset (active low)
    w_en = 1'b0;        // Disable write enable
    data_in = 0;        // Initialize data input to 0

    // Wait for 10 write clock cycles while in reset
    repeat(10) @(posedge wclk);
    wrst_n = 1'b1;      // Deassert write reset (enable write logic)

    // Perform write operations in two phases
    repeat(2) begin
      for (int i = 0; i < 30; i++) begin
        @(posedge wclk iff !full); // Wait for a positive clock edge if FIFO is not full
        w_en = (i % 2 == 0) ? 1'b1 : 1'b0; // Enable writing on even iterations
        if (w_en) begin
          data_in = $urandom;        // Generate random data to write
          wdata_q.push_back(data_in); // Store data in the queue for later comparison
        end
      end
      #50; // Delay between phases
    end
  end

  // Initial block for read-side operations
  initial begin
    rclk = 1'b0;        // Initialize read clock to 0
    rrst_n = 1'b0;      // Assert read reset (active low)
    r_en = 1'b0;        // Disable read enable

    // Wait for 20 read clock cycles while in reset
    repeat(20) @(posedge rclk);
    rrst_n = 1'b1;      // Deassert read reset (enable read logic)

    // Perform read operations in two phases
    repeat(2) begin
      for (int i = 0; i < 30; i++) begin
        @(posedge rclk iff !empty); // Wait for a positive clock edge if FIFO is not empty
        r_en = (i % 2 == 0) ? 1'b1 : 1'b0; // Enable reading on even iterations
        if (r_en) begin
          wdata = wdata_q.pop_front(); // Retrieve the expected data from the queue
          if (data_out !== wdata)      // Compare read data with expected data
            $error("Time = %0t: Comparison Failed: expected wr_data = %h, rd_data = %h", $time, wdata, data_out);
          else
            $display("Time = %0t: Comparison Passed: wr_data = %h and rd_data = %h", $time, wdata, data_out);
        end
      end
      #50; // Delay between phases
    end
    $finish; // Terminate simulation
  end

endmodule
