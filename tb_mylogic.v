// Test bench for the 'mylogic' module.
//
// Author:   ALA  3/1/2011
// 

module tb_mylogic;
   reg a,b,c; 
   wire q;

   mylogic dut(a,b,c,q);

   initial begin  // test stimulus
      a = 0;
      b = 0;
      c = 0;

      #5  b = 1;    // change b-&gt;1 at 5 ns
      #8  c = 1;    // change c-&gt;1 at 8 ns
      #20 a = 1;    // change a-&gt;1 at 20 ns
      #30 a = 0;    // change a-&gt;0 at 30 ns

   end

endmodule