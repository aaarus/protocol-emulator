module pc_reg(
    input clk, rst,
    output reg [15:0] pc_addr,
    input [15:0] pc_data_in
    );

    always @(posedge clk, negedge rst)
        if (!rst) begin 
            pc_addr <= 0;
        end
        else begin 
            pc_addr <= pc_data_in;
        end
endmodule 

module pc(input clk, rst, pc_stall,
    input pc_mux_sel,
    input [3:0] loop_length,  //ip from loop_handler
    output [15:0] pc_addr_out
    );

    wire [15:0] pc_data_in;
    assign pc_data_in = pc_stall
                  ? pc_addr_out
                  : (pc_mux_sel == 1'b0)
                    ? pc_addr_out + 16'd1
                    : pc_addr_out
                      - {{12{1'b0}}, loop_length}
                      + 16'd1;
                    
    pc_reg pc_reg(
        .clk(clk),
        .rst(rst),
        .pc_addr(pc_addr_out),
        .pc_data_in(pc_data_in)
    );


    
endmodule