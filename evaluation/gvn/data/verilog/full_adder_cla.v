module full_adder_cla (
  input  wire a,
  input  wire b,
  input  wire cp, // prev carry
  input  wire pp, // previous propagate
  input  wire gp, // previous generate
  output reg  p,
  output reg  g,
  output reg  c);

  assign p = a ^ b; // propagate
  assign g = a & b; // generate
  assign c = gp | pp & cp;

endmodule
