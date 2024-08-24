module filter #(
    parameter MAX_LENGTH = 255 
)(
    input wire clk,            // System clock
    input wire rst,            // Reset signal
    input wire data,           // Input data
    input wire [7:0] length,   // Length of the filter
    output reg [7:0] sum       // Output sum
);


    reg shift_reg [0:MAX_LENGTH-1];

    integer i;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            
            sum <= 8'b0;
            for (i = 0; i < MAX_LENGTH; i = i + 1) begin
                shift_reg[i] <= 1'b0;
            end
        end else begin
           
            shift_reg[0] <= data;
            sum <= sum - shift_reg[length-1] + data;

            
            for (i = 1; i < MAX_LENGTH; i = i + 1) begin
                shift_reg[i] <= shift_reg[i-1];
            end
        end
    end
endmodule
