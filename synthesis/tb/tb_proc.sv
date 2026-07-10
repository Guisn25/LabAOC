`timescale 1ns/1ps

module tb_proc;

    // -------------------------------------------------------------------------
    // Clock / Reset
    // -------------------------------------------------------------------------

    logic clock;
    logic reset;

    always #10 clock = ~clock;

    // -------------------------------------------------------------------------
    // External Memory Interface
    // -------------------------------------------------------------------------

    logic [31:0] In;

    logic        ReadWrite;
    CTRL::data_size_t  DataType;
    logic [31:0] DataOut;
    logic [31:0] AddressOut;

    // -------------------------------------------------------------------------
    // DUT
    // -------------------------------------------------------------------------

    proc dut(
        .clock(clock),
        .reset(reset),
        .In(In),

        .ReadWrite(ReadWrite),
        .DataType(DataType),
        .DataOut(DataOut),
        .AddressOut(AddressOut)
    );

    // -------------------------------------------------------------------------
    // Fake Memory
    // -------------------------------------------------------------------------

    logic [31:0] memory [0:255];

    always_comb begin
        In = memory[AddressOut[7:0]];
    end

    always_ff @(posedge clock) begin
        if (ReadWrite)
            memory[AddressOut[7:0]] <= DataOut;
    end

    // -------------------------------------------------------------------------
    // Helpers
    // -------------------------------------------------------------------------

    task automatic step;
    begin
        @(posedge clock);
        #1;
    end
    endtask

    task automatic cpu_reset;
    begin

        reset = 1;

        repeat (2)
            @(posedge clock);

        #1;

        reset = 0;

        #1;

    end
    endtask

    task automatic dump_state;
    begin
        $display("------------------------------------------------------------");
        $display("t=%0t", $time);
        $display("PC        = %h", dut.PCaddressOut);
        $display("Instr     = %h", dut.currentInst);
        $display("opcode    = %b", dut.Unit.opcode);
        $display("funct3    = %b", dut.Unit.funct3);
        $display("funct7    = %b", dut.Unit.funct7);
        $display("Addr      = %h", dut.currentAddress);
        $display("Addr_next = %h", AddressOut);
        $display("Write     = %b", ReadWrite);
        $display("rs1       = %b", dut.REGBank.rs1);
        $display("DataA     = %d", dut.RegA);
        $display("rs2       = %b", dut.REGBank.rs2);
        $display("DataB     = %d", dut.RegB);
        $display("WriteData = %h", DataOut);
        $display("Ret       = %h", dut.RET);
        $display("OperandA  = %d", dut.OperandA);
        $display("OperandB  = %d", dut.OperandB);
        $display("Immeadite = %b", dut.ExtendedImm);
        $display("ALUResult = %h", dut.ALUresult);
        $display("ALUOut    = %h", dut.ALUOut);
        $display("State     = %0d", dut.Unit.state);
        $display("MEMsrc    = %b", dut.ctrl_signals[CTRL::MEMsrc]);
        $display("In        = %h", dut.In);
        $display("RETsrc    = %b", dut.RETsrc);
        $display("ALUsrcA   = %b", dut.ALUsrcA);
        $display("ALUsrcB   = %b", dut.ALUsrcB);
        $display("memory    = %h", memory[AddressOut[7:0]]);
        $display("------------------------------------------------------------");
    end
    endtask

    // -------------------------------------------------------------------------
    // Test Program
    // -------------------------------------------------------------------------

    initial begin : TEST

        integer i;

        clock = 0;
        reset = 0;
        In    = 32'h0;

        for (i = 0; i < 256; i++)
            memory[i] = 32'h00000073;   //HALT 

        // ---------------------------------------------------------------------
        // Small dummy program
        // Replace these instructions as development progresses.
        // ---------------------------------------------------------------------

        memory[0] = 32'h00308093; //addi r1, r1,  3  000000000011/00001/000/00001/0010011
        memory[1] = 32'h00100113; //addi r2, r0,  1  000000000001/00000/000/00010/0010011
        memory[2] = 32'h402080B3; //sub  r1, r1, r2  0100000/00010/00001/000/00001/1000011
        memory[3] = 32'h00100823; //sb   r1, 16(r0)  0000000/00001/00000/000/10000/0100011
        memory[4] = 32'h01000403; //lb   r8, 16(r0)  000000010000/00000/000/01000/0000011
        memory[5] = 32'h00100263; //beq  r1, r0, 4   0000000/00001/00000/000/00100/1100011 
        memory[6] = 32'hFFFFC1EF; //jal  r3,  -4     1111|1111|1111|1111|1100/00011/1101111
        memory[7] = 32'h00000073; //HALT             0000000000000000000000000/1110011(SYSTEM)
        memory[8] = 32'h00000013; //addi r0, r0, 0   000000000000/00000/000/00000/0010011
        memory[9] = 32'h00100013; //addi r0, r0, 1   000000000001/00000/000/00000/0010011
        memory[10] = 32'h00000073; //HALT            0000000000000000000000000/1110011(SYSTEM)
        cpu_reset();

        repeat (75) begin
            dump_state();
            step();
        end

        $display("memoria gurdada      = %h", memory[16]);
        $display("registardor carregado= %h", dut.REGBank.regs[8]);

        $display("");
        $display("==================================================");
        $display(" End of processor integration test");
        $display("==================================================");
        $display("");

        $finish;

    end

    // -------------------------------------------------------------------------
    // Waveform
    // -------------------------------------------------------------------------

    initial begin
        $dumpfile("tests/proc.vcd");
        $dumpvars(0, tb_proc);
    end

endmodule
