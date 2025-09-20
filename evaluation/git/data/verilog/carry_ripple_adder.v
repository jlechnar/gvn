module carry_ripple_adder
  #(parameter W = 16)
  (input  wire [W-1:0] a,
   input  wire [W-1:0] b,
   input  wire         c_in,
   output wire [W-1:0] s,
   output wire         c_out);

  wire [W-1:0] c;

  full_adder fas [W-1:0] (
    .a     (a),
    .b     (b),
    .c_in  ({c[W-2:0], c_in}),
    .s     (s),
    .c_out (c)
  );

  assign c_out = c[W-1];

endmodule
