`timescale 1ns/1ps

module tb_ALU;

    logic [31:0] operandA;
    logic [31:0] operandB;
    CTRL::alu_op_t aluOp;

    logic [31:0] result;
    logic zero;
    logic negative;
    logic carry;
    logic overflow;

    ALU dut(
        .operandA(operandA),
        .operandB(operandB),
        .aluOp(aluOp),
        .result(result),
        .zero(zero),
        .negative(negative),
        .carry(carry),
        .overflow(overflow)
    );

    task check_result(
        input [31:0] expected
    );
    begin
        #1;

        if(result !== expected) begin
            $display("FAIL @ %0t", $time);
            $display("  A        = %h", operandA);
            $display("  B        = %h", operandB);
            $display("  Result   = %h", result);
            $display("  Expected = %h", expected);
        end
        else begin
            $display("PASS @ %0t", $time);
        end
    end
    endtask

    initial begin

        $dumpfile("alu.vcd");
        $dumpvars(0,tb_ALU);

        //--------------------------------------------------
        // ADD
        //--------------------------------------------------

        operandA = 10;
        operandB = 20;
        aluOp    = CTRL::ADDalu;
        check_result(30);

        operandA = 32'hFFFFFFFF;
        operandB = 1;
        aluOp    = CTRL::ADDalu;
        check_result(0);

        //--------------------------------------------------
        // SUB
        //--------------------------------------------------

        operandA = 50;
        operandB = 20;
        aluOp    = CTRL::SUBalu;
        check_result(30);

        operandA = 20;
        operandB = 50;
        aluOp    = CTRL::SUBalu;
        check_result(32'hFFFFFFE2);

        //--------------------------------------------------
        // AND
        //--------------------------------------------------

        operandA = 32'hF0F0F0F0;
        operandB = 32'h0FF00FF0;
        aluOp    = CTRL::ANDalu;
        check_result(32'h00F000F0);

        //--------------------------------------------------
        // OR
        //--------------------------------------------------

        operandA = 32'hF0F0F0F0;
        operandB = 32'h0FF00FF0;
        aluOp    = CTRL::ORalu;
        check_result(32'hFFF0FFF0);

        //--------------------------------------------------
        // XOR
        //--------------------------------------------------

        operandA = 32'hAAAA5555;
        operandB = 32'hFFFF0000;
        aluOp    = CTRL::XORalu;
        check_result(32'h55555555);

        //--------------------------------------------------
        // SLL
        //--------------------------------------------------

        operandA = 1;
        operandB = 4;
        aluOp    = CTRL::SLLalu;
        check_result(16);

        //--------------------------------------------------
        // SRL
        //--------------------------------------------------

        operandA = 32'h80000000;
        operandB = 4;
        aluOp    = CTRL::SRLalu;
        check_result(32'h08000000);

        //--------------------------------------------------
        // SRA
        //--------------------------------------------------

        operandA = 32'h80000000;
        operandB = 4;
        aluOp    = CTRL::SRAalu;
        check_result(32'hF8000000);

        //--------------------------------------------------
        // LUI
        //--------------------------------------------------

        operandA = 0;
        operandB = 32'h12345;
        aluOp    = CTRL::LUIalu;
        check_result(32'h12345000);

        //--------------------------------------------------
        // AUIPC
        //--------------------------------------------------

        operandA = 32'h1000;
        operandB = 32'h10;
        aluOp    = CTRL::AUIPCalu;
        check_result(32'h11000);

        //--------------------------------------------------
        // JALR
        //--------------------------------------------------

        operandA = 100;
        operandB = 21;
        aluOp    = CTRL::JALRalu;
        check_result(120);

        //--------------------------------------------------
        // ZERO FLAG
        //--------------------------------------------------

        operandA = 1;
        operandB = 1;
        aluOp    = CTRL::SUBalu;

        #1;

        if(!zero)
            $display("FAIL ZERO FLAG");

        //--------------------------------------------------
        // NEGATIVE FLAG
        //--------------------------------------------------

        operandA = 1;
        operandB = 2;
        aluOp    = CTRL::SUBalu;

        #1;

        if(!negative)
            $display("FAIL NEGATIVE FLAG");

        //--------------------------------------------------
        // ADD OVERFLOW
        //--------------------------------------------------

        operandA = 32'h7FFFFFFF;
        operandB = 1;
        aluOp    = CTRL::ADDalu;

        #1;

        if(!overflow)
            $display("FAIL OVERFLOW FLAG");

        //--------------------------------------------------

        $display("TESTBENCH FINISHED");
        $finish;

    end

endmodule
