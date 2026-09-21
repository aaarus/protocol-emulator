module control_unit(
    input clk, 
    input rst,
    input [3:0] opcode,
    input [1:0] loop_status,
    input delay_zero,
    

    output reg load_counter_en,
    output reg tx_shift_en,
    output reg rx_shift_en,
    output reg init_loop_en,
    output reg wr_tx_config, wr_rx_config,
    output reg set_open_drain, //will take care later
    output reg set_gpio, clr_gpio,
    output reg tx_enable,
    output reg dec_counter_en,
    output reg tx_load_en,
    output reg pc_mux_sel,
    output reg pc_stall
    );

    reg [1:0] state, next_state;
    localparam NORMAL = 2'b00;
    localparam LOOPING = 2'b01;
    localparam STALL = 2'b10;

    always @(posedge clk, negedge rst) begin 
        if (!rst) begin 
            state <= NORMAL;
        end
        else begin 
            state <= next_state;
        end
    end


    // loop states

    localparam STATUS_LOOP = 2'b00; 
    localparam STATUS_INC = 2'b01;
    localparam STATUS_EXIT = 2'b10;





    // cu 3 states? normal, loop, delay/wait
    localparam SHIFT_OUT = 4'b0000;
    localparam SHIFT_IN = 4'b0001;
    localparam LOOP = 4'b0010;
    localparam WAIT = 4'b0011;
    localparam DELAY = 4'b0100;
    localparam SET_GPIO = 4'b0101;
    localparam CLR_GPIO = 4'b0110;
    localparam SET_GPIO_RX = 4'b0111;
    localparam SET_GPIO_TX = 4'b1000;
    localparam LOAD_TX = 4'b1001;


    //for normal combinational logic(in normal state)
    always_comb begin

        // Defaults
        load_counter_en = 0;
        tx_shift_en     = 0;
        rx_shift_en     = 0;
        init_loop_en    = 0;
        wr_tx_config    = 0;
        wr_rx_config    = 0;
        set_open_drain  = 0;
        set_gpio        = 0;
        clr_gpio        = 0;
        tx_enable       = 0;
        dec_counter_en  = 0;
        tx_load_en      = 0;
        pc_mux_sel      = 0;
        pc_stall        = 0;

        // Hold current state unless explicitly changed
        next_state = state;


        if (state == NORMAL) begin
            pc_mux_sel = 0;

            case(opcode)

                SHIFT_OUT: begin 
                    tx_enable = 1;
                    tx_shift_en = 1;
                    next_state = NORMAL;
                end

                SHIFT_IN: begin
                    //shifts in data
                    rx_shift_en = 1;
                    next_state = NORMAL;
                end

                LOOP: begin 
                    init_loop_en = 1;
                    next_state = LOOPING;
                end

                WAIT: begin 
                    load_counter_en = 1; 
                    next_state = STALL;
                end
                
                DELAY: begin 
                    load_counter_en = 1;
                    next_state = STALL;
                end

                SET_GPIO: begin 
                    set_gpio = 1;
                    next_state = NORMAL;

                end

                CLR_GPIO: begin 
                    clr_gpio = 1;
                    next_state = NORMAL;
                end

                SET_GPIO_RX: begin 
                    wr_rx_config = 1;
                    next_state = NORMAL;
                end

                SET_GPIO_TX: begin 
                    wr_tx_config = 1;
                    next_state = NORMAL;
                end

                LOAD_TX: begin 
                    tx_load_en = 1;
                    next_state = NORMAL;
                end

                default: begin 
                    next_state = NORMAL;
                end
            endcase

        end

        if (state == LOOPING) begin 
            pc_mux_sel = 0;
            if (loop_status == STATUS_LOOP) begin
                pc_mux_sel = 1;
            end
            else if (loop_status == STATUS_EXIT) begin
                pc_mux_sel = 0;
                next_state = NORMAL;
            end
        end

        if (state == STALL) begin 
            pc_stall = 1;
            dec_counter_en = 1;
            if (delay_zero) begin 
                next_state = NORMAL;
            end
            else begin 
                next_state = STALL;
            end
        end



    end

endmodule