`timescale 1ns / 1ps

module d_latch(
    input d,
    input enable,
    output reg q
);
    always @(*) begin
        if (enable) begin
            q = d;
        end
    end
endmodule

module d_flip_flop(
    input d,
    input clk,
    input reset_n,
    output reg q
);
    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            q <= 1'b0;
        end else begin
            q <= d;
        end
    end
endmodule
