module carry_lookahead_adder
  #(parameter W = 4)
  (input  wire [W-1:0] a,
   input  wire [W-1:0] b,
   input  wire         c_in,
   output wire [W-1:0] s,
   output wire         c_out);

  wire [W-1:0] c;
  wire [W-1:0] p;
  wire [W-1:0] g;

  wire [W-1:0] cp = {c[W-2:0], c_in};
  wire [W-1:0] pp = {p[W-2:0], 1'b1};
  wire [W-1:0] gp = {g[W-2:0], 1'b0};

  full_adder_cla clas [W-1:0] (
    .a     (a),
    .b     (b),
    .pp    (pp),
    .gp    (gp),
    .cp    (cp),
    .p     (p),
    .g     (g),
    .c     (c)
  );

  assign s = p ^ c;
  assign c_out = g[W-1] | p[W-1] & c[W-1];

endmodule
