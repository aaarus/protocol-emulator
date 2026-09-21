`default_nettype none

module tt_um_aaarus_protocol_emulator (
    input  wire [7:0] ui_in,
    output wire [7:0] uo_out,

    input  wire [7:0] uio_in,
    output wire [7:0] uio_out,
    output wire [7:0] uio_oe,

    input  wire ena,
    input  wire clk,
    input  wire rst_n
);

    wire [3:0] gpio_in;
    wire [3:0] gpio_out;
    wire [3:0] gpio_oe;

    // Protocol GPIOs use uio[3:0]
    assign gpio_in = uio_in[3:0];

    assign uio_out[3:0] = gpio_out;
    assign uio_oe[3:0]  = gpio_oe;

    // Unused bidirectional pins
    assign uio_out[7:4] = 4'b0;
    assign uio_oe[7:4]  = 4'b0;

    // Dedicated outputs currently unused
    assign uo_out = 8'b0;

    top u_top (
        .clk      (clk),
        .rst      (rst_n),
        .gpio_in  (gpio_in),
        .gpio_out (gpio_out),
        .gpio_oe  (gpio_oe)
    );

    // Prevent unused-input warnings
    wire _unused = &{ena, ui_in};

endmodule

`default_nettype wire