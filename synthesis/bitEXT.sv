module bitEXT(
    input  logic [31:0] Inst,
    input  logic [1:0]  IMMtype,
    
    output logic [31:0] Out
);
    reg {31:0} Immediate;
    
    assign Out = Immediate;
    case (Immtype)
        2'b00: begin
            Immediate = {{20{Inst[31]}}, Inst[31:20]};
        end
        2'b01: begin
            Immediate = {{20{Inst[31]}}, Inst[31:25], Inst[11:7]};
        end
        2'b10: begin
            Immediate = {{20{Inst[31]}}, Inst[31], Inst[7], Inst[30:25], Inst[11:8], 0};
        end
        2'b11: begin
            Immediate = {{12{Inst[31]}}, Inst[31:12]};
        end
    
endmodule
