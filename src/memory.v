module memory #(
    parameter NUM_ADDRESSES = 8 // Configurable number of addresses
)(
    input wire clk,                   // System clock
    input wire rst_n,                 // Active-low reset
    input wire [7:0] addr,            // 8-bit address
    input wire [7:0] data_in,         // 8-bit data input
    input wire wr_en,                 // Write enable
    input wire rd_en,                 // Read enable
    output reg [7:0] data_out        // 8-bit data output
);

    // Memory and length arrays declaration
    reg [7:0] memory [0:NUM_ADDRESSES-1]; // Memory array

    integer i;

    // Reset and memory initialization
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            for (i = 0; i < NUM_ADDRESSES; i = i + 1) begin
                memory[i] <= 8'b0;
                // length[i] <= 8'b0; // Initialize lengths to zero
            end
        end else if (wr_en) begin
            memory[addr] <= data_in;
        end
    end

    // Memory read operation
    always @(posedge clk) begin
        if (rd_en) begin
            data_out <= memory[addr];
        end
    end

endmodule
