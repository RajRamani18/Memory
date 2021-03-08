
module mem ( mem_intf.mem busa );   //interface instance busa

timeunit      1ns;
timeprecision 1ns;

logic [7:0] memory [0:31];
  
  always @(posedge busa.clk)
    if (busa.write && !busa.read)
      #1 memory[busa.addr] <= busa.data_in;

  always_ff @(posedge busa.clk iff ((busa.read == '1)&&(busa.write == '0))) //flip-flop block and if-and-only-if
       busa.data_out <= memory[busa.addr];

endmodule
