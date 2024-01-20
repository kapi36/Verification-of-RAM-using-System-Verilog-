class transaction ; 
  randc bit[7:0] din ; 
  randc bit[7:0] addr; 
  bit[7:0] dout; 
  bit wr ; 
endclass 

 class generator ; 
   mailbox mbx; 
   transaction t;
   event done; 
   integer i ; 
   
   function new(mailbox mbx); 
     this.mbx = mbx; 
   endfunction 
   
   task run(); 
     t  = new(); 
     for(i=0 ; i<50; i++) begin 
       t.randomize(); 
       mbx.put(t); 
       $display("[GEN]:Data send to driver din : %0d , addr;%0d", t.din , t.addr); 
       @(done); // sensing the event 
     end
   endtask 
 endclass



interface ram_intf(); 

logic clk, wr ,rst; 
logic [7:0] din ; 
logic [7:0] addr; 
logic [7:0] dout; 
endinterface


 class driver ; 
   mailbox mbx; 
   transaction t;
   event done; 
   virtual ram_intf vif; 
   
   function new(mailbox mbx); 
     this.mbx = mbx; 
   endfunction 
   
   task run(); 
     t  = new(); 
     forever begin 
       mbx.get(t); 
       vif.din = t.din ; 
       vif.addr = t.addr; 
       $display("[DRV]:Interface Triggered din : %0d , addr: %0d wr:%0d", t.din , t.addr,vif.wr); 
       @(posedge vif.clk) ; 
       
       if(t.wr == 1'b0)
         @(posedge vif.clk)
      
       ->(done); // triggering the event 
     end
   endtask 
 endclass 

class monitor ; 
  mailbox mbx; 
  transaction t; 
  virtual ram_intf vif; 
   
   function new(mailbox mbx); 
     this.mbx = mbx; 
   endfunction 
  
  task run(); 
     t  = new(); 
     forever begin 
       @(posedge vif.clk) ;
       
       if(t.wr == 1'b1)begin
       t.wr = vif.wr ; 
       t.din = vif.din  ; 
       t.addr = vif.addr;
       t.dout = 0;
       end
       
       if(t.wr == 1'b0) begin 
         @(posedge vif.clk) ;
       t.wr = vif.wr ; 
       t.din = vif.din  ; 
       t.addr = vif.addr;
       t.dout = vif.dout;
       end
       
       mbx.put(t);  
       $display("[MON]:Data send to Scoreboard : %0d , addr: %0d wr:%0d", t.din , t.addr,vif.wr);  
     end
  endtask 
endclass 

class scoreboard ;
  transaction t; 
  mailbox mbx; 
  reg [7:0]tarr[256] = '{default : 0 } ; 
  
   function new(mailbox mbx); 
     this.mbx = mbx; 
   endfunction 
  
  task run() ; 
    forever begin 
      mbx.get(t) ; 
      if(t.wr ==1'b1)begin
        tarr[t.addr] = t.din ; 
        $display("[SCO] : Data stored din : %0d addr : %0d ", t.din,t.addr);
      end
      
      if (t.wr ==1'b0)begin
        if(t.dout == 0 ) 
          $display("[SCO] : No Data Written at this Location Test Passed");
        else if (t.dout == tarr[t.addr])
           $display("[SCO] : Valid Data found Test Passed");
        else
          $display("Test failed "); 
      end
    end
  endtask 
endclass 

class enviornment ; 
  generator g ; 
  driver d ; 
  monitor m; 
  scoreboard s; 
  mailbox gdmbx; 
  mailbox msmbx;
event gddone ; 
  
  virtual ram_intf vif ; 
  
  function new(mailbox gdmbx , mailbox msmbx) ; 
    this.gdmbx = gdmbx;
    this.msmbx = msmbx ; 
    g = new(gdmbx) ; 
    d = new(gdmbx ) ; 
    m = new(msmbx); 
    s = new(msmbx); 
  endfunction
  
  task run (); 
    g.done = gddone ; 
    d.done = gddone ; 
     d.vif = vif; 
    m.vif = vif; 
    
    fork 
      g.run(); 
      d.run(); 
      m.run(); 
      s.run(); 
    join 
  endtask 
endclass 
 

module tb();
 
 enviornment e;
ram_intf vif();
mailbox gdmbx, msmbx;
 
ram dut (vif.clk, vif.wr,vif.rst, vif.din, vif.addr, vif.dout);
 
always #5 vif.clk = ~vif.clk;
 
 
initial begin
vif.clk = 0;
vif.rst = 1;
#50;
$display("[TOP] : System Reset Done");
$display("[TOP] : Starting Write Transaction");  
vif.wr = 1;
vif.rst = 0;
#250;
$display("[TOP] : Starting Read Transaction");   
vif.wr = 0;
#200;  
end
 
initial begin
gdmbx = new();
msmbx = new();
 
e = new(gdmbx,msmbx);
e.vif = vif;
#50;  
e.run();
#600;
$finish;
end
 
  initial begin
    $dumpfile("dump.vcd");
    $dumpvars;
  end
 
 
 
endmodule
      
  
