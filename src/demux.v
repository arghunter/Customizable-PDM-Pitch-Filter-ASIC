module demux1to2 (
    input wire [7:0]sel,    // 2-bit select input
    input wire [7:0] d,           // Data input 
    output reg [7:0] a,
    output wire [7:0] b,            
);
    // Using a continuous assignment to implement the multiplexer logic
    always @(*) begin
        a=8'b00000000;
        b=8'b00000000;
        case(sel):
        1'b0: a=d;
        1'b1: b=d;
    end

endmodule