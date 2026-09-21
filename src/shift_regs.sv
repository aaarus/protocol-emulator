// for tx register. piso
module tx_reg #(
    parameter DATA_WIDTH = 8  // Parameterizable width, defaults to 8-bit
)(
    input  wire                  clk,         // System clock
    input  wire                  rst_n,       // Active-low asynchronous reset
    input  wire                  load,        // 1: Load parallel data
    input  wire                  shift_en,    // 1: Shift data out
    input  wire [DATA_WIDTH-1:0] parallel_in, // Parallel data input bus
    output wire                  serial_out   // Serial data output
);

    // Internal register holding the shifting state
    reg [DATA_WIDTH-1:0] shift_reg;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            shift_reg <= {DATA_WIDTH{1'b0}};
        end
        else if (load) begin
            // Synchronous parallel load
            shift_reg <= parallel_in;
        end
        else if (shift_en) begin
            // Right shift operation for LSB-first serial streaming
            shift_reg <= {1'b0, shift_reg[DATA_WIDTH-1:1]};
        end
        else begin
            // Hold current value
            shift_reg <= shift_reg;
        end
    end

    // LSB is the current serial output
    assign serial_out = shift_reg[0];

endmodule




// for rx. sipo
module rx_reg #(
    parameter N = 8 // Configurable data width (default 8 bits)
)(
    input  wire         clk,       // Clock signal
    input  wire         rst_n,     // Active-low asynchronous reset
    input  wire         enable,    // Shift enable
    input  wire         dir,       // Direction: 0 = Shift Right, 1 = Shift Left
    input  wire         serial_in, // Serial data input
    output reg  [N-1:0] parallel_out // Parallel data output
);

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            parallel_out <= {N{1'b0}}; // Clear register on reset
        end else if (enable) begin
            if (dir == 1'b1) begin
                // Shift Left: insert serial_in at LSB (index 0)
                parallel_out <= {parallel_out[N-2:0], serial_in};
            end else begin
                // Shift Right: insert serial_in at MSB (index N-1)
                parallel_out <= {serial_in, parallel_out[N-1:1]};
            end
        end
    end

endmodule