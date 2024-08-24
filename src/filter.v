module filter #(
    parameter MAX_LENGTH = 255
)(
    input wire clk,            // System clock
    input wire rst,            // Reset signal
    input wire data,           // Input data
    input wire [7:0] length,   // Length of the filter
    output reg [7:0] sum       // Output sum
);

    reg [MAX_LENGTH-1:0] shift_reg;

    integer i;
    
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            sum <= 8'b0;
            shift_reg <= {MAX_LENGTH{1'b0}};
        end else begin
            if (length > 0) begin
                sum <= sum - shift_reg[length-1] + data;
            end
            shift_reg <= {shift_reg[MAX_LENGTH-2:0], data};
        end
    end
endmodule
