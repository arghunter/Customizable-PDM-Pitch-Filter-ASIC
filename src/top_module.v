// `include "spi_port.v"
// `include "memory.v"
// `include "demux.v"
// `include "decimator.v"
// `include "filter.v"
// `include "i2s_bus.v"

module top_module(
    input wire clk,
    input wire rst,
    input wire spi_mosi,
    input wire spi_cs_n,
    input wire mic_data,
    output wire out,
    output wire mic_clk
);
wire [7:0] addr;
wire [7:0] value;
wire wr_en = 1;
wire rd_en = 1;
wire [7:0] mem_out;
wire [7:0] decimation_ratio;
wire dec_data;
wire dec_clk;
wire [7:0] filter_length;
wire [7:0] filter_out;
wire [15:0] capture_reg;
wire dummy;
assign addr = capture_reg[15:8];
assign value = capture_reg[7:0];
assign mic_clk = clk;

    spi_port u_spi_port(
        .clk(clk),
        .rst_n(!rst),
        .spi_clk(clk),
        .spi_mosi(spi_mosi),
        .spi_miso(dummy),
        .spi_cs_n(spi_cs_n),
        .capture_reg(capture_reg)
    );
    memory u_memory(
        .clk(clk),            
        .rst_n(!rst),          
        .addr(addr),     
        .data_in(value),  
        .wr_en(wr_en),          
        .rd_en(rd_en),          
        .data_out(mem_out) 
    );
    demux1to2 u_demux1to2(
        .sel(addr),
        .d(mem_out),
        .a(decimation_ratio), //Check that these don't reset 
        .b(filter_length)
    );
    decimator u_decimator(
        .clk(clk),              
        .rst(rst),              
        .decimation_ratio(decimation_ratio),
        .data(mic_data),             
        .out(dec_data),              
        .dec_clk(dec_clk)           
    );
    filter u_filter(
        .clk(dec_clk),         
        .rst(rst),         
        .data(dec_data),        
        .length(filter_length),
        .sum(filter_out)    
    );
    i2s_bus u_i2s_bus(
        .clk(clk),
        .rst(rst),
        .lr_clk(dec_clk),
        .bit_data(filter_out),
        .out(out)
    );




endmodule
