module ram(input clk, input wr , input rst, 
           input [7:0] din, input [7:0] addr,
           output reg [7:0] dout);   
  reg [7:0]mem[64]; 
  integer i ;
  
  always @(posedge clk) begin 
    if(rst==1'b1) begin 
      for(i= 0 ; i<256; i++)begin 
        mem[i] <= 0 ; 
      end 
    end
    else if(wr == 1) 
      mem[addr] = din ; 
    else 
      dout <= mem[addr] ; 
  end
endmodule 
       
      
      
