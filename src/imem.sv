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

    logic [15:0] mem [0:DEPTH-1];

    integer i;

    initial begin
        // Initialize entire memory to zero
        for (i = 0; i < DEPTH; i = i + 1)
            mem[i] = 16'h0000;



        
        // Load program
        $readmemb("../src/imem.bin", mem);
    end

    assign data_out = mem[addr];

endmodule