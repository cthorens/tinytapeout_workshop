`default_nettype none
`timescale 1ns / 1ps

/* This testbench just instantiates the module and makes some convenient wires
   that can be driven / tested by the cocotb test.py.
*/
module tb ();

  // Dump the signals to a FST file. You can view it with gtkwave or surfer.
  initial begin
    $dumpfile("tb.fst");
    $dumpvars(0, tb);
    #1;
  end

  // Wire up the inputs and outputs:
  reg clk;
  wire [7:0] w_reg3;

  // Replace tt_um_example with your module name:
  tt_um_cthorens_vgatest user_project (
      .i_CLK    (clk),      // clock
      .o_REG3   (w_reg3)
  );

endmodule
