
module mem ( mem_intf.mem bus );   //interface instance busa

timeunit      1ns;
timeprecision 1ns;

logic [7:0] memory [0:31];
  
  always @(posedge bus.clk)
    if (bus.write && !bus.read)
      #1 memory[bus.addr] <= bus.data_in;

  always_ff @(posedge bus.clk iff ((bus.read == '1)&&(bus.write == '0))) //flip-flop block and if-and-only-if
       bus.data_out <= memory[bus.addr];

endmodule
