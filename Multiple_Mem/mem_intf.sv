
interface mem_intf(input logic clk);
    
    timeunit      1ns;
    timeprecision 1ns;
    
    logic       read;
    logic       write; 
    logic [4:0] addr;
    logic [7:0] data_in;
    logic [7:0] data_out;
    
    modport tb  (input  data_out, clk, 
                 output data_in, addr, read, write);
    
    modport mem (output  data_out, 
                 input   clk, data_in, addr, read, write);
                         
endinterface: mem_intf
