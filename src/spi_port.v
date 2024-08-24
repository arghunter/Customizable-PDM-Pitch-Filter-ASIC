module spi_port (
    input wire clk,               // System clock
    input wire rst_n,             // Active-low reset
    input wire spi_clk,          // SPI clock
    input wire spi_mosi,         // Master Out Slave In
    output wire spi_miso,        // Master In Slave Out (Not implemented)
    input wire spi_cs_n,         // Chip Select (active-low)
    output reg [15:0] capture_reg
    
);

    reg [15:0] shift_reg;         // 16-bit shift register for incoming data
    reg cs_n_prev;                // Previous state of CS

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            shift_reg <= 16'b0;
            capture_reg <= 16'b0;
            cs_n_prev <= 1'b1;
        end else begin
            // Capture previous state of CS
            cs_n_prev <= spi_cs_n;

            if (!spi_cs_n) begin
                // Shift in data on each rising edge of SPI clock
                if (spi_clk) begin
                    shift_reg <= {shift_reg[14:0], spi_mosi};
                end
            end else if (cs_n_prev == 1'b0 && spi_cs_n == 1'b1) begin
                // When CS goes high (inactive), save the data to the capture register
                capture_reg <= shift_reg;
            end
        end
    end

    assign spi_miso = 1'b0;

endmodule
