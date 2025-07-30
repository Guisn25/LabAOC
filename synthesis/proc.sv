module proc(
    input  logic        clock,
    input  logic        reset,
    input  logic [31:0] In,
    
    output logic        ReadWrite,
    output data_size_t  DataType,
    output logic [31:0] DataOut,
    output logic [31:0] AddressOut
);
    CTRL::ctrl_signal   ctrl_signals[CTRL::ENDctrl];
    
    logic [31:0] PCaddressIn, PCaddressOut;
    
    PC PC(
        .clock(clock),
        .reset(reset),
        .write(ctrl_signals[CTRL::PCwrite]),
        .PCin(Ret),
    
        .PCout(PCaddressOut)
    );

    REG IR(
        .clock(clock),
        .reset(reset),
        .write(ctrl_signals[CTRL::IRwrite]),
        .In(In),
        
        .Out(currentInst)
    );
    logic [31:0] currentInst;

    REG AR(
        .clock(clock),
        .reset(reset),
        .write(ctrl_signals[CTRL::IRwrite]),
        .In(PCaddressOut),
        
        .Out(currentAddress)
    );
    logic [31:0] currentAddress;

    REGBank REGBank(
        .clock(clock),
        .reset(reset),
        .REGwrite(ctrl_signals[CTRL::REGwrite]),
        .rs1(currentInst[19:15]),
        .rs2(currentInst[24:20]),
        .rd(currentInst[11:7]),
        .DATAwrite(Ret),
        
        .Data_A(RegA),
        .Data_B(RegB)
    );
    logic [31:0] RegA, RegB;

    REG A(
        .clock(clock),
        .reset(reset),
        .write(1'b1),
        .In(RegA),
        
        .Out(OutA)
    );
    logic [31:0] OutA;

    REG B(
        .clock(clock),
        .reset(reset),
        .write(1'b1),
        .In(RegB),
        
        .Out(OutB)
    );
    logic [31:0] OutB;
    assign DataOut = OutB;

    bitEXT EXT(
        .Inst(curretnInst),
        .IMMtype(IMMtype),
        
        .Out(ExtendedImm)
    );
    logic [31:0] ExtendedImm;

    logic [31:0] OperandA, OperandB;

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
    logic [31:0] ALUresult;
    logic zero, negative, carry, overflow;

    REG AluReg(
        .clock(clock),
        .reset(reset),
        .write(1'b1),
        .In(ALUresult),
        
        .Out(ALUOut)
    );
    logic [31:0] ALUOut;

    REG MEMReg(
        .clock(clock),
        .reset(reset),
        .write(1'b1),
        .In(In),
        
        .Out(DataOut)
    );
    logic [31:0] DataOut;

    Control Unit(
        .clock(clock),
        .reset(reset),
        .opcode(currentInst[6:0]),     
        .funct3(currentInst[14:12]),     
        .funct7(currentInst[31:25]),     
        .zero(zero),
        .negative(negative),      
        
        .ctrl_signal(ctrl_signals),
        .IMMtype(IMMtype),
        .ALUsrcA(ALUsrcA),
        .ALUsrcB(ALUsrcB),
        .ALUctrl(ALUctrl),
        .RETsrc(RETsrc),
        .MEM_data(DataType)
    );
    logic [1:0] IMMtype, ALUsrcA, ALUsrcB, RETsrc;
    CTRL::alu_op_t ALUctrl;

    always_comb begin
        case(ctrl_signals[CTRL::MEMsrc]) begin
            1'b0: begin
                AddressOut = PCaddressOut;
            end
            1'b1: begin
                AddressOut = Ret;
            end
        end
        case(ALUsrcA) begin
            2'b00: begin
                OperandA = AddressIn;
            end
            2'b01: begin
                OperandA = currentAddress;
            end
            2'b10: begin
                OperandA = OutA;
            end
        end
        case(ALUsrcB) begin
            2'b00: begin
                OperandB = OutB;
            end
            2'b01: begin
                OperandB = ExtendedIMM;
            end
            2'b10: begin
                OperandB = 32'd2;
            end
        end
        case(RETsrc) begin
            2'b00: begin
                Ret = AluOut;
            end
            2'b01: begin
                Ret = DataOut;
            end
            2'b10: begin
                Ret = ALUresult;
            end
        end
    end
logic [31:0] Ret;

endmodule
