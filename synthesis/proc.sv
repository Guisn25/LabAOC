`timescale 1ns/1ps

module proc(
    input  logic        clock,
    input  logic        reset,
    input  logic [31:0] In,
    
    output logic        ReadWrite,
    output CTRL::data_size_t  DataType,
    output logic [31:0] DataOut,
    output logic [31:0] AddressOut
);
    logic [CTRL::ENDctrl:0] ctrl_signals;
    logic [31:0] RET, PCaddressOut;
    logic [31:0] currentInst;
    logic [31:0] currentAddress;
    logic [31:0] RegA, RegB;
    logic [31:0] OutA;
    logic [31:0] OutB;
    logic [1:0] Immtype, ALUsrcA, ALUsrcB, RETsrc;
    logic [31:0] ExtendedImm;
    logic [31:0] OperandA, OperandB;
    logic [31:0] ALUresult;
    logic zero, negative, carry, overflow;
    CTRL::alu_op_t ALUctrl;
    logic [31:0] ALUOut;
    logic [31:0] MEMOut;
   
  

    PC PC(
        .clock(clock),
        .reset(reset),
        .write(ctrl_signals[CTRL::PCwrite]),
        .PCin(RET),
    
        .PCout(PCaddressOut)
    );

    REG IR(
        .clock(clock),
        .reset(reset),
        .write(ctrl_signals[CTRL::IRwrite]),
        .In(In),
        
        .Out(currentInst)
    );

    REG AR(
        .clock(clock),
        .reset(reset),
        .write(ctrl_signals[CTRL::IRwrite]),
        .In(PCaddressOut),
        
        .Out(currentAddress)
    );

    REGBank REGBank(
        .clock(clock),
        .reset(reset),
        .REGwrite(ctrl_signals[CTRL::REGwrite]),
        .rs1(currentInst[19:15]),
        .rs2(currentInst[24:20]),
        .rd(currentInst[11:7]),
        .DATAwrite(RET),
        
        .Data_A(RegA),
        .Data_B(RegB)
    );

    REG A(
        .clock(clock),
        .reset(reset),
        .write(1'b1),
        .In(RegA),
        
        .Out(OutA)
    );

    REG B(
        .clock(clock),
        .reset(reset),
        .write(1'b1),
        .In(RegB),
        
        .Out(OutB)
    );
    assign DataOut = OutB;

    bitEXT EXT(
        .Inst(currentInst),
        .Immtype(Immtype),
        
        .Out(ExtendedImm)
    );


    ALU ALU(
        .operandA(OperandA),
        .operandB(OperandB),
        .aluOp(ALUctrl),
        
        .result(ALUresult),
        .zero(zero),
        .negative(negative),
        .carry(carry),
        .overflow(overflow)
    );

    REG AluReg(
        .clock(clock),
        .reset(reset),
        .write(1'b1),
        .In(ALUresult),
        
        .Out(ALUOut)
    );

    REG MEMReg(
        .clock(clock),
        .reset(reset),
        .write(1'b1),
        .In(In),
        
        .Out(MEMOut)
    );

    Control Unit(
        .clock(clock),
        .reset(reset),
        .opcode(currentInst[6:0]),     
        .funct3(currentInst[14:12]),     
        .funct7(currentInst[31:25]),     
        .zero(zero),
        .negative(negative),      
        
        .ctrl_signal(ctrl_signals),
        .Immtype(Immtype),
        .ALUsrcA(ALUsrcA),
        .ALUsrcB(ALUsrcB),
        .ALUctrl(ALUctrl),
        .RETsrc(RETsrc),
        .MEMdata(DataType)
    );
    assign ReadWrite = ctrl_signals[CTRL::MEMwrite];
    always_comb begin
        if(~ctrl_signals[CTRL::MEMsrc]) 
          AddressOut = PCaddressOut;
        else 
          AddressOut = RET;
        
        case(ALUsrcA) 
            2'b00: begin
                OperandA = PCaddressOut;
            end
            2'b01: begin
                OperandA = currentAddress;
            end
            2'b10: begin
                OperandA = OutA;
            end
          endcase
        case(ALUsrcB) 
            2'b00: begin
                OperandB = OutB;
            end
            2'b01: begin
                OperandB = ExtendedImm;
            end
            2'b10: begin
                OperandB = 32'd2;
            end
          endcase
        case(RETsrc) 
            2'b00: begin
                RET = ALUOut;
            end
            2'b01: begin
                RET = MEMOut;
            end
            2'b10: begin
                RET = ALUresult;
            end
          endcase        
    end

endmodule
