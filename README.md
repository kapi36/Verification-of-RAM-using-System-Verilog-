# Verification-of-RAM-using-System-Verilog-

so in this git we are verifying the functionallity of a ram using system verilog 
so the design code is easy where i defined inputs - rst , wr, clk , and 8 bit din , 8 bit address , and 8 bit dout . the functionality is like if rst becomes high means we put every element 0 and for write we put the values on memory from din and for rd we put value in dout from memory 

 →  for testbench first define transcation class and put variables 
 →  next comes generator class which generate random stimulis . 
 →  for driver class first we get the values from generator class through mailbox  then send to interface wait and if the operation is write wait for 1 clk cycle and for read operation wait for 1 more clk cycle. 
  →  Next comes monitor class where we first wait for a clk cycle and if the opeation is write then we take the response from the interface to the data continer and if the operation is read then we first wait for 1 clk cycle and then we take the response from the interface.
   →  next comes scoreboard where main algorithm is defines if the write operation is there we just check the data is tarr[t.addr] == t.din ; 
      and if the operation is read then we check if it 0 means the write opeartion is not done on this address . but the test is passed and another case is that where we checking that value is same or not in the dout and tarr. 
      
**Result : ** 



![image](https://github.com/kapi36/Verification-of-RAM-using-System-Verilog-/assets/110424577/17639b00-d33d-4973-9de4-b90e08dd2912)

![image](https://github.com/kapi36/Verification-of-RAM-using-System-Verilog-/assets/110424577/d4e1c61c-a1e4-423b-81dd-a67451fa305d)
