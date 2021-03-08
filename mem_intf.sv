
interface mem_intf(input logic clk);
    
    timeunit      1ns;
    timeprecision 1ns;
    
    logic       read;
    logic       write; 
    logic [4:0] addr;
    logic [7:0] data_in;
    logic [7:0] data_out;
    
    modport tb  (input  data_out, clk, 
                 output data_in, addr, read, write,
                 import read_mem, write_mem);
    
    modport mem (output  data_out, 
                 input   clk, data_in, addr, read, write);


    task write_mem (input [4:0] waddr,
                    input [7:0] wdata,
                    input       debug = 0);
        @(negedge clk); 
            write <= 1; 
            read <= 0; 
            addr <= waddr; 
            data_in <= wdata;
        
        @(negedge clk); 
            write <= 0;
        
        if(debug == 1)
            $display("Write Data = %h @ Address = %d ", wdata, waddr);        
    endtask : write_mem


    task read_mem(input  [4:0] raddr,
                  output [7:0] rdata,
                  input        debug = 0);
                  
        @(negedge clk); 
            write <= 0; 
            read <= 1; 
            addr <= raddr;
        
        @(negedge busa.clk); 
            read <= 0; 
            rdata = data_out;
        
        if(debug == 1)
            $display("Read Data = %h @ Address = %d", rdata, raddr);           
    endtask

                         
endinterface: mem_intf
