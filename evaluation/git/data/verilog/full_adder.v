module full_adder (
  input  wire a,
  input  wire b,
  input  wire c_in,
  output reg s,
  output reg c_out);

  assign {c_out, s} = a + b + c_in;

endmodule
