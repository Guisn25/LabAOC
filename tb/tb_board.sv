`timescale 1ns/1ps

module tb_board;

    logic CLOCK_50;
    logic reset;

    board dut(
        .CLOCK_50(CLOCK_50),
        .reset(reset)
    );

    // ------------------------------------------------------------
    // Clock
    // ------------------------------------------------------------

    initial begin
        CLOCK_50 = 0;
        forever #10 CLOCK_50 = ~CLOCK_50;
    end

    // ------------------------------------------------------------
    // Reset
    // ------------------------------------------------------------

    task automatic cpu_reset;
    begin
        reset = 1;

        repeat (2)
            @(posedge CLOCK_50);

        #1;
        reset = 0;

        @(posedge CLOCK_50);
        #1;
    end
    endtask

    // ------------------------------------------------------------
    // Monitor
    // ------------------------------------------------------------

    always @(posedge CLOCK_50) begin

        $display("------------------------------------------------------------");
        $display("t=%0t",$time);

        $display("PC         = %h", dut.RISCV.PCaddressOut);
        $display("Instruction= %h", dut.RISCV.currentInst);
        $display("State      = %0d", dut.RISCV.Unit.state);

        $display("MemAddr    = %h", dut.AddressProc);
        $display("Write      = %b", dut.ReadWrite);
        $display("WriteData  = %h", dut.DataProc);
        $display("ReadData   = %h", dut.InputProc);

        $display("MemoryWord = %h", dut.RomOut);

    end

    // ------------------------------------------------------------
    // Simulation
    // ------------------------------------------------------------
    initial begin
      $dumpfile("tests/board.vcd");
      $dumpvars(0, tb_board);
    end


    initial begin

        cpu_reset();

        repeat (80)
            @(posedge CLOCK_50);

        $display("\nSimulation finished.\n");
        $finish;

    end

endmodule
