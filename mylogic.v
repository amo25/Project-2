// Structural description of a small combinational
// circuit, copied from the introductory Verilog example 
// in the lecture slides
//
// Author:  ALA  3/1/2011
// 
module mylogic(a, b, c, q);

  input a, b, c;
  output q;
  wire n1, n2;

  not INV1(n1, a);	// "not" is available instead of "inv"
  or  OR1(n2, b, c);
  and AND1(q, n1, n2);

endmodule 
