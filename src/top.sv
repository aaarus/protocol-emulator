module top(
    input  wire       clk,
    input  wire       rst,
    input  wire [3:0] gpio_in,
    output wire [3:0] gpio_out,
    output wire [3:0] gpio_oe
);
    wire [15:0] instruction;

    wire [1:0] tx_config, rx_config;

    // INSTRUCTION PARSING !!!

    // Wire declarations to connect to the module outputs

    wire [3:0]  opcode;
    wire [1:0]  gpio;
    wire [7:0]  loop_count;
    wire [3:0]  loop_length;
    wire [7:0]  wait_delay_count;
    wire        evnt;
    wire [11:0] delay_count;
    wire [7:0]  tx_load_value;

    // Module Instantiation (Named Port Connection)
    instruction_parser u_instruction_parser (
        .instruction      (instruction),
        .opcode           (opcode),
        .gpio             (gpio),
        .loop_count       (loop_count),
        .loop_length      (loop_length),
        .wait_delay_count (wait_delay_count),
        .evnt             (evnt),
        .delay_count      (delay_count),
        .tx_load_value     (tx_load_value)
    );


    wire [1:0] loop_status;
    wire delay_zero;

    wire load_delay_counter;
    wire tx_shift_en;
    wire rx_shift_en;
    wire init_loop_en;
    wire wr_tx_config, wr_rx_config;
    wire set_open_drain;
    wire set_gpio, clr_gpio;
    wire tx_enable;
    wire dec_counter_en;
    wire tx_load_en;
    wire pc_mux_sel;
    wire pc_stall;

    control_unit cu(
        .clk(clk),
        .rst(rst),
        .opcode(opcode),
        .loop_status(loop_status),
        .load_counter_en(load_delay_counter),
        .tx_shift_en(tx_shift_en),
        .rx_shift_en(rx_shift_en),
        .init_loop_en(init_loop_en),
        .wr_tx_config(wr_tx_config),
        .wr_rx_config(wr_rx_config),
        .set_open_drain(set_open_drain),
        .set_gpio(set_gpio),
        .clr_gpio(clr_gpio),
        .tx_enable(tx_enable),
        .dec_counter_en(dec_counter_en),
        .tx_load_en(tx_load_en),
        .pc_mux_sel(pc_mux_sel),
        .pc_stall(pc_stall),
        .delay_zero(delay_zero)
    );

    wire [3:0] loop_length_latched;
    loop_handler loop_handler(
        .clk(clk),
        .rst(rst),
        .init_en(init_loop_en),
        .status(loop_status),
        .loop_length_in(loop_length),
        .loop_count_in(loop_count),
        .loop_length_latched(loop_length_latched)
    );

    delay_counter #(
        .N(12) 
    ) u_delay_counter (
        .clk(clk),     // connect to clock signal
        .rst_n(rst),   // connect to active-low reset signal
        .load    (load_delay_counter),    // connect to load enable signal
        .dec_en  (dec_counter_en),  // connect to decrement enable signal
        .data_in (delay_count), // connect to input data bus [N-1:0] //choose bw wait_delay_count and delay_count
        .count   (),    // connect to output count bus [N-1:0]
        .zero(delay_zero)
        );



    wire tx_serial_out;
    tx_reg #(
        .DATA_WIDTH(8) // Set width (change 8 to your desired width)
    ) u_tx_reg (
        .clk         (clk),         // Connect to clock signal
        .rst_n       (rst),       // Connect to active-low reset signal
        .load        (tx_load_en),        // Connect to load/shift control signal ??
        .parallel_in (tx_load_value), // Connect to parallel input bus [DATA_WIDTH-1:0]
        .serial_out  (tx_serial_out),   // Connect to serial output wire
        .shift_en   (tx_shift_en) // Connect to tx_enable signal
    );

    wire [3:0] gpio_values;
assign gpio_values = gpio_in;

    gpio #(
        .NUM_GPIO(4)
    ) u_gpio (
        .clk        (clk),
        .rst_n      (rst),

        .set_gpio   (set_gpio),
        .clr_gpio   (clr_gpio),

        .tx_bit     (tx_serial_out),
        .tx_config  (tx_config),
        .tx_enable  (tx_enable),

        .open_drain (4'b0000),

        .gpio_in    (gpio_in),
        .gpio_out   (gpio_out),
        .gpio_oe    (gpio_oe),

        .gpio_select(gpio)
    );

    wire rx_serial_in;


    // Instantiation template for the parameterized 1-bit MUX
    parameterized_1bit_mux #(
        .CHANNELS(4) // Set the number of input channels here (e.g., 4, 8, 16)
    ) u_mux_inst (
        .in_bus(gpio_values), 
        .sel(rx_config), 
        .out(rx_serial_in)  
    );



    rx_reg #(
        .N(8) // Set width
    ) u_rx_reg (
        .clk          (clk),          // Connect to clock signal
        .rst_n        (rst),        // Connect to active-low reset signal
        .enable       (rx_shift_en),       // Connect to shift enable signal
        .dir          (1'b1),          // Connect to direction control (0: Right, 1: Left)
        .serial_in    (rx_serial_in),    // Connect to serial input wire
        .parallel_out (/*empty for now*/)  // Connect to parallel output bus [N-1:0]
    );




    configuration_registers u_configuration_registers(
        .clk(clk),
        .rst(rst),
        .wr_tx_en(wr_tx_config),
        .wr_rx_en(wr_rx_config),
        .open_drain_en(1'b0),
        .rx(gpio),
        .tx(gpio),
        .tx_reg(tx_config), //verify once
        .rx_reg(rx_config) //verify once
    );


    wire [15:0] pc_addr_out;
    pc u_pc(
        .clk(clk),
        .rst(rst),
        .pc_mux_sel(pc_mux_sel),
        .pc_stall(pc_stall),
        .loop_length(loop_length_latched),
        .pc_addr_out(pc_addr_out)
    );

    imem u_imem(
        .addr(pc_addr_out),
        .data_out(instruction)
    );






endmodule