module lab01_hello_logic;
  reg a;
  reg b;
  wire and_out;
  wire or_out;
  wire not_a;

  assign and_out = a & b;
  assign or_out = a | b;
  assign not_a = ~a;

  initial begin
    $dumpfile("lab01_hello_logic.vcd");
    $dumpvars(0, lab01_hello_logic);

    a = 0; b = 0;
    #10 a = 0; b = 1;
    #10 a = 1; b = 0;
    #10 a = 1; b = 1;
    #10 $finish;
  end

  initial begin
    $display("time a b and or not_a");
    $monitor("%4t %b %b  %b   %b   %b", $time, a, b, and_out, or_out, not_a);
  end
endmodule
