`timescale 1ns/1ps

module bitEXT(
  input  logic [31:0] Inst,
  input  logic [1:0]  Immtype,
    
  output logic [31:0] Out
);
    reg [31:0] Immediate;
    
    assign Out = Immediate;
    always_comb begin
      unique case (Immtype)
          2'b00: begin
            Immediate = {{20{Inst[31]}}, Inst[31:20]};
          end
          2'b01: begin
            Immediate = {{20{Inst[31]}}, Inst[31:25], Inst[11:7]};
          end
          2'b10: begin
            Immediate = {{20{Inst[31]}}, Inst[31], Inst[7], Inst[30:25], Inst[11:8], 1'b0};
          end
          2'b11: begin
            Immediate = {{12{Inst[31]}}, Inst[31:12]};
          end
      endcase
    end
endmodule
