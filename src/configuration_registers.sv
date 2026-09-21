module configuration_registers(input clk, rst, wr_tx_en, wr_rx_en, open_drain_en, 
    input [1:0] rx, tx, 
    output reg [1:0] tx_reg, rx_reg);

    reg open_drain;

    always @(posedge clk, negedge rst) begin 
        if (!rst) begin 
            tx_reg <= 0;
            rx_reg <= 0;
            open_drain <= 0;
        end
        else begin 
            if (wr_tx_en) tx_reg <= tx;
            if (wr_rx_en) rx_reg <= rx;
            if (open_drain_en) open_drain <= 1; //how will this be disabled?
        end
    end

    

endmodule