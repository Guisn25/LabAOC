`timescale 1ns/1ps

module REGBank(
  input  logic        clock,
  input  logic        reset,
  input  logic        REGwrite,
  input  logic [4:0]  rs1,
  input  logic [4:0]  rs2,
  input  logic [4:0]  rd,
  input  logic [31:0] DATAwrite,
  
  output logic [31:0] Data_A,
  output logic [31:0] Data_B
);
    logic [31:0] regs [31:0];

    assign Data_A = regs[rs1];
    assign Data_B = regs[rs2];
    integer i;
    
    always_ff @(posedge clock) begin
      if (reset) begin
        for(i=0;i<32;i = i+1) begin
          regs[i] <= 32'b0;
        end
      end 
      if (REGwrite) begin
        regs[rd] <= DATAwrite;
      end
      regs[0] <= 32'b0;
    end
endmodule
