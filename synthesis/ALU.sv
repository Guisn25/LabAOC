module ALU(
    input logic [31:0]    operandA,
    input logic [31:0]    operandB,
    input CTRL::alu_op_t  aluOp,
    
    output logic [31:0]   result,
    output logic          zero,
    output logic          negative,
    output logic          carry,
    output logic          overflow
);

  logic [32:0] resultAux;
  always_comb begin
    case (aluOp)
      CTRL::ADDalu:   resultAux = operandA + operandB;         
      CTRL::SUBalu:   resultAux = operandA - operandB;         
      CTRL::ANDalu:   resultAux = operandA & operandB;         
      CTRL::ORalu:    resultAux = operandA | operandB;         
      CTRL::XORalu:   resultAux = operandA ^ operandB;         
      CTRL::SLLalu:   resultAux = operandA << operandB[4:0];   
      CTRL::SRLalu:   resultAux = operandA >> operandB[4:0];   
      CTRL::SRAalu:   resultAux = $signed(operandA) >>> operandB[4:0]; 
      CTRL::LUIalu:   resultAux = operandB << 12;
      CTRL::AUIPCalu: resultAUX = operandA + (operandB << 12);
      CTRL::JALRalu:  resultAUX = (operandA + operandB) & ~(32'b1);                    
      default: resultAux = 33'b0;
    endcase
  end

  assign result = resultAux[31:0];
  assign carry = resultAux[32];
  assign zero = (result == 0);
  assign negative = result[31];
  assign overflow = (~operandA[31] & ~operandB[31] & result[31])|(operandA[31] & operandB[31] & ~result[31]) ;

endmodule
