module halve_adder (
 input  wire a,
 input  wire b,
 output reg s,
 output reg c);

  assign {c, s} = a + b;

endmodule
