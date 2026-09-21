module instruction_parser(
    input [15:0] instruction, 
    output [3:0] opcode,
    output [1:0] gpio,
    output [7:0] loop_count, //verify length once
    output [3:0] loop_length,
    output [7:0] wait_delay_count,
    output evnt, //for wait
    output [11:0] delay_count,
    output [7:0] tx_load_value
    );

    assign opcode = instruction[15:12];
    assign gpio = instruction[1:0];
    assign loop_count = instruction[11:4];
    assign loop_length = instruction[3:0];
    assign wait_delay_count = instruction[11:4];
    assign evnt = instruction[2];
    assign delay_count = instruction[11:0];
    assign tx_load_value = instruction[7:0];




endmodule