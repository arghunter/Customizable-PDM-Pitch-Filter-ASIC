module decimator (
    input wire clk,               // System clock
    input wire rst,               // Reset signal
    input wire [7:0] decimation_ratio, // 8-bit decimation ratio
    input wire data,              // Input data
    output reg out,              // Output data
    output reg dec_clk           // Decimation clock output
);

    reg [7:0] counter;           

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            counter <= 8'b0;
            out <= 1'b0;
            dec_clk <= 1'b0;
        end else begin
            counter <= counter + 1;
            if (counter >= decimation_ratio) begin
                counter <= 8'b0;
                out <= data;
                dec_clk <= ~dec_clk;
            end
        end
    end

endmodule
