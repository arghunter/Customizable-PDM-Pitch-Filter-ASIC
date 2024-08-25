// `include "mux_shift.v"
module i2s_bus(
    input wire clk,
    input wire rst,
    input wire lr_clk,
    input wire [31:0] bit_data,
    output reg out
); 
    // "dir::demux.v",
    // "dir::filter.v",
    // "dir::memory.v",
    // "dir::spi_port.v",
    // "dir::mux_shift.v",
    // "dir::i2s_bus.v",
    // "dir::top_module.v"
    wire [31:0] mux_outputs; 
    reg [7:0] counter;   
    reg dec_clk=0;
    genvar i;
    generate
        
        //Making the first one
        mux_shift u_mux_shift ( 
                .clk(clk),
                .rst(rst),
                .lr_clk(dec_clk),
                .last_shift(1'b0),
                .sum_res(bit_data[0]),
                .out(mux_outputs[0]) 
            );
        for (i=1; i<32; i=i+1) begin : mux_shift_inst
            mux_shift u_mux_shift (
                .clk(clk),
                .rst(rst),
                .lr_clk(dec_clk),
                .last_shift(mux_outputs[i-1]),
                .sum_res(bit_data[i]),
                .out(mux_outputs[i]) 
            );
        end
    endgenerate 
    always @(posedge clk or posedge rst) begin
         if (rst) begin
            counter <= 8'b0;
            dec_clk <= 1'b0;
        end else begin
            counter <= counter + 1;
            if (counter >= 64) begin
                counter <= 8'b0;
                
                dec_clk <= ~dec_clk;
            end
        end
    end
    always @(negedge clk) begin
        if (rst)
            out <= 1'b0;
        else
            out <= mux_outputs[31]; // assign last bit of mux_ouputs to out
    end
    
    
endmodule