`timescale 1ns / 1ps

module tb_latch_flipflop;
    reg d;
    reg enable;
    reg clk;
    reg reset_n;
    wire q_latch;
    wire q_ff;

    d_latch latch0 (.d(d), .enable(enable), .q(q_latch));
    d_flip_flop ff0 (.d(d), .clk(clk), .reset_n(reset_n), .q(q_ff));

    initial begin
        clk = 1'b0;
        forever #5 clk = ~clk;
    end

    initial begin
        $dumpfile("lab06_latch_flipflop.vcd");
        $dumpvars(0, tb_latch_flipflop);

        d = 1'b0;
        enable = 1'b0;
        reset_n = 1'b0;
        #12;

        reset_n = 1'b1;
        enable = 1'b1;
        d = 1'b1;
        #12;

        d = 1'b0;
        #8;

        enable = 1'b0;
        d = 1'b1;
        #20;

        enable = 1'b1;
        d = 1'b0;
        #20;

        $finish;
    end
endmodule
