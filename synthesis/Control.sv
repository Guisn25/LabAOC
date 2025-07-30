module Control(
    input  logic                clock,
    input  logic                reset,
    input  IS::op_code_t        opcode,     
    input  logic [2:0]          funct3,     
    input  logic [6:0]          funct7,     
    input  logic                zero,
    input  logic                negative,      
    
    output logic                ctrl_signal[CTRL::ENDctrl],
    output logic [1:0]          IMMtype,
    output logic [1:0]          ALUsrcA,
    output logic [1:0]          ALUsrcB,
    output CTRL::alu_op_t       ALUctrl,
    output logic [1:0]          RETsrc,
    output CTRL::data_size_t    MEMdata
);

    typedef enum logic [4:0] {
        FETCH, 
        
        DECODE,
        
        EXEC_R,
        EXEC_S,
        EXEC_I,
        EXEC_B,
        EXEC_U,

        MEM_READ,
        
        MEM_WB,

        WB_REG,

        STATE_END
    } state_t;

    state_t state, next_state;

    always_ff @(posedge clock or posedge reset) begin
        if (reset)
            state <= FETCH;
        else
            state <= next_state;
    end

    always_comb begin
        next_state <= state;

        unique case (state)
            FETCH: begin
                ctrl_signal[CTRL::PCwrite]  = 1;
                ALUsrcA = 2'b00;
                ALUsrcB = 2'b10;
                ALUctrl = CTRL::ADDalu;
                RETsrc  = 2'b10;
                ctrl_signal[CTRL::MEMsrc]   = 0;
                ctrl_signal[CTRL::MEMwrite] = 0;
                ctrl_signal[CTRL::IRwrite]  = 1;
                next_state = DECODE;
            end

            DECODE: begin
                ALUsrcA = 2'b01;
                ALUsrcB = 2'b01;
                ALUctrl = CTRL::ADDalu;
                ctrl_signal[CTRL::PCwrite]  = 0;
                ctrl_signal[CTRL::IRwrite]  = 0;
                unique case (opcode)
                    IS::LUI:    nextstate = EXEC_U;
                    IS::AUIPC:  nextstate = EXEC_U;
                    IS::JAL:    IMMtype = 2'b11;  
                                nextstate = EXEC_U;
                    IS::JALR:   IMMtype = 2'b00;
                                nextstate = EXEC_I;
                    IS::BRANCH: IMMtype = 2'b10;
                                nextstate = EXEC_B;
                    IS::LOAD:   nextstate = EXEC_I;
                    IS::STORE:  nextstate = EXEC_S;
                    IS::OP_IMM: nextstate = EXEC_I;
                    IS::OP:     nextstate = EXEC_R;
                    //PLACEHOLDER
                    IS::FENCE:  nextstate = EXEC_I; 
                    IS::SYSTEM: nextstate = EXEC_I; 
                    default:    next_state = FETCH;
                endcase
            end

            EXEC_R:     type_R();

            EXEC_I:     type_I();

            EXEC_S:     type_S();

            EXEC_B:     type_B();

            EXEC_U:     type_U();

            WB_REG:     REG_wb();
            
            MEM_READ:   MEM_read();

            MEM_WRITE:  MEM_write();

            MEM_WB:     MEM_wb();

            default: next_state = FETCH;
        endcase
    end
    
    task type_R();
        ALUsrcA = 2'b10;
        ALUsrcB = 2'b00;
        case (funct3)
            3'b000: begin   //ADD|SUB
                ALUctrl = (funct7 == 7'b0100000) ? CTRL::SUBalu : CTRL::ADDalu;
            end
            3'b001: begin   //SLL
                ALUctrl = CTRL::SLLalu;
            end
            3'b010: begin   //SLT
                ALUctrl = CTRL::SUBalu;
            end
            3'b011: begin   //SLTU
                ALUctrl = CTRL::SUBalu;
            end
            3'b100: begin   //XOR
                ALUctrl = CTRL::XORalu;
            end
            3'b101: begin   //SRL|SRA
                ALUctrl = (funct7 == 7'b0100000) ? CTRL::SRAalu : CTRL::SRLalu;
            end
            3'b110: begin   //OR
                ALUctrl = CTRL::ORalu;
            end
            3'b111: begin   //AND
                ALUctrl = CTRL::ANDalu;
            end
        end
        next_state = WB_REG;
    endtask

    task type_I();
        ALUsrcA = 2'b10;
        IMMtype = 2'b00;
        ALUsrcB = 2'b01;
        case (opcode)
            IS::JALR: begin
                ALUctrl = CTRL::ADDalu;
                RETsrc  = 2'b00;
                ctrl_signal[CTRL::PCwrite] = 1;

                next_state = WB_REG;
            end
            IS::LOAD: begin
                ALUctrl = CTRL::ADDalu;

                next_state = MEM_READ;
            end
            IS::OP_IMM: begin
                case (funct3)
                    3'b000: begin   //ADDI
                        ALUctrl = CTRL::ADDalu;
                    end
                    3'b010: begin   //SLTI
                        ALUctrl = CTRL::SUBalu;
                    end
                    3'b011: begin   //SLTIU
                        ALUctrl = CTRL::SUBalu;
                    end
                    3'b100: begin   //XORI
                        ALUctrl = CTRL::XORalu;
                    end
                    3'b110: begin   //ORI
                        ALUctrl = CTRL::ORalu;
                    end
                    3'b111: begin   //ANDI
                        ALUctrl = CTRL::ANDalu;
                    end
                    3'b001: begin   //SLLI
                        ALUctrl = CTRL::ALLalu;
                    end
                    3'b101: begin   //SRLI|SRAI
                        ALUctrl = (funct7 == 7'b0100000) ? CTRL::SRAalu : CTRL::SRLalu;
                    end
                endcase
                next_state = WB_REG;
            end
        end
    endtask

    task type_S();
        ALUsrcA = 2'b10;
        IMMtype = 2'b01;
        ALUsrcB = 2'b01;
        ALUctrl = CTRL::ADDalu;
        
        next_state = MEM_WRITE;
    endtask

    task type_B();
        ALUsrcA = 2'b10;
        IMMtype = 2'b10;
        ALUsrcB = 2'b00;
        RETsrc  = 2'b00;
        case(funct3)
            3'b000: begin // BEQ
                ALUctrl = CTRL::SUBalu;
                ctrl_signal[CTRL::PCwrite] = zero;
            end
            3'b001: begin // BNE
                ALUctrl = CTRL::SUBalu;
                ctrl_signal[CTRL::PCwrite] = ~zero;
            end
            3'b100: begin // BLT
                ALUctrl = CTRL::SUBalu;
                ctrl_signal[CTRL::PCwrite] = negative;
            end
            3'b101: begin // BGE
                ALUctrl = CTRL::SUBalu;
                ctrl_signal[CTRL::PCwrite] = ~negative;
            end
            
            //PLACEHOLDER
            3'b110: begin // BLTU
                ALUctrl = CTRL::SUBalu;
                
                ctrl_signal[CTRL::PCwrite] = zero;
            end 
            3'b111: begin // BGEU
                ALUctrl = CTRL::SUBalu;
                
                ctrl_signal[CTRL::PCwrite] = zero;
            end
        end
        next_state = FETCH;
    endtask

    task type_U();
        IMMtype = 2'b11;
        case(opcode)
            IS::LUI: begin
                ALUsrcB = 2'b01;
                ALUctrl = CTRL::LUIalu;
            end
            IS::AUIPC: begin
                ALUsrcA = 2'b01;
                ALUsrcB = 2'b01;
                ALUctrl = CTRL::AUIPCalu;
            end
            IS::JAL: begin
                ALUsrcB = 2'b10;
                ALUctrl = CTRL::ADDalu;
                RETsrc  = 2'b00;
                ctrl_signal[CTRL::PCwrite] = 1;
            end
        end
        next_state = WB_REG;
    endtask

    task MEM_read();
        RETsrc  = 2'b00;
        ctrl_signal[CTRL::MEMsrc]   = 1;
        case (funct3)
            3'b000: begin
                MEMdata = CTRL::Byte;
            end
            3'b001: begin
                MEMdata = CTRL::HalfWord;
            end
            3'b010: begin
                MEMdata = CTRL::Word;
            end
            
            //PLACEHOLDER
            3'b100: begin
                MEMdata = CTRL::ByteUnsigned;
            end
            3'b101: begin
                MEMdata = CTRL::HalfWordUnsigned
            end
        end
        next_state = MEM_WB; 
    endtask

    task MEM_write();
        RETsrc  = 2'b00;
        ctrl_signal[CTRL::MEMsrc]   = 1;
        ctrl_signal[CTRL::MEMwrite] = 1;
        case (funct3)
            3'b000: begin
                MEMdata = CTRL::Byte;
            end
            3'b001: begin
                MEMdata = CTRL::HalfWord;
            end
            3'b010: begin
                MEMdata = CTRL::Word;
            end
        end
        next_state = FETCH;
    endtask

    task MEM_wb();
        RETsrc  = 2'b01;
        ctrl_signal[CTRL::REGwrite] = 1;

        next_state = FETCH;
    endtask

    task REG_wb();
        RETsrc  = 2'b00;
        ctrl_signal[CTRL::PCwrite]  = 0;
        ctrl_signal[CTRL::REGwrite] = 1;
        
        next_state = FETCH;
    endtask

endmodule
