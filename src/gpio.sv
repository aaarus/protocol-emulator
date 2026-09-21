module gpio #(
    parameter int NUM_GPIO = 4
) (
    input  logic                  clk,
    input  logic                  rst_n,

    // SET/CLR GPIO control
    input  logic [1:0]            gpio_select,
    input  logic                  set_gpio,
    input  logic                  clr_gpio,

    // TX
    input  logic                  tx_bit,
    input  logic [$clog2(NUM_GPIO)-1:0] tx_config,
    input  logic                  tx_enable,

    // Per-GPIO open drain
    input  logic [NUM_GPIO-1:0]   open_drain,

// GPIO pad interface
input  logic [NUM_GPIO-1:0] gpio_in,
output logic [NUM_GPIO-1:0] gpio_out,
output logic [NUM_GPIO-1:0] gpio_oe
);

    logic [NUM_GPIO-1:0] gpio_out_reg;

    logic [NUM_GPIO-1:0] tx_selected;
    logic [NUM_GPIO-1:0] gpio_value;
    assign gpio_out = gpio_value;

    /*
     * ---------------------------------------------------------
     * GPIO output register
     * ---------------------------------------------------------
     *
     * gpio_select selects which GPIO is affected.
     * set_gpio sets that GPIO to 1.
     * clr_gpio clears that GPIO to 0.
     *
     * SET has priority over CLR if both are asserted.
     */
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            gpio_out_reg <= '0;
        end
        else begin
            if (set_gpio)
                gpio_out_reg[gpio_select] <= 1'b1;
            else if (clr_gpio)
                gpio_out_reg[gpio_select] <= 1'b0;
        end
    end

    /*
     * ---------------------------------------------------------
     * TX destination decoder
     * ---------------------------------------------------------
     */
    always_comb begin
        tx_selected = '0;

        if (tx_enable)
            tx_selected[tx_config] = 1'b1;
    end

    /*
     * ---------------------------------------------------------
     * GPIO logical output
     * ---------------------------------------------------------
     *
     * TX overrides normal GPIO output on selected pin.
     */
    always_comb begin
        for (int i = 0; i < NUM_GPIO; i++) begin
            if (tx_selected[i])
                gpio_value[i] = tx_bit;
            else
                gpio_value[i] = gpio_out_reg[i];
        end
    end

    /*
     * ---------------------------------------------------------
     * Open-drain conversion
     * ---------------------------------------------------------
     */
    always_comb begin
        for (int i = 0; i < NUM_GPIO; i++) begin
            if (open_drain[i])
                gpio_oe[i] = ~gpio_value[i];
            else
                gpio_oe[i] = 1'b1;
        end
    end

    /*
     * ---------------------------------------------------------
     * Actual GPIO pads
     * ---------------------------------------------------------
     */


    /*
     * ---------------------------------------------------------
     * GPIO input
     * ---------------------------------------------------------
     */


endmodule