/*module imem (
    input  logic        clk,
    input  logic        rst,
    input  logic [15:0] addr,
    output logic [15:0] data_out
);

    logic [15:0] mem [0:65535];

    initial begin
        $readmemh("imem.hex", mem);
    end

    always_ff @(posedge clk or posedge rst) begin
        if (rst)
            data_out <= 16'b0;
        else
            data_out <= mem[addr];
    end

endmodule */

module imem #(
    parameter int DEPTH = 256
) (
    input  logic [$clog2(DEPTH)-1:0] addr,
    output logic [15:0] data_out
);

    always_comb begin
        case (addr)
            8'd0: data_out = 16'b1000000000000000;
            8'd1: data_out = 16'b0010001000000010;
            8'd2: data_out = 16'b0101000000000000;
            8'd3: data_out = 16'b0110000000000000;

            default: data_out = 16'h0000;
        endcase
    end

endmodule