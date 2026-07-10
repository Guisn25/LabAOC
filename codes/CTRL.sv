`timescale 1ns/1ps

package CTRL;

  typedef enum logic [3:0]{
    ADDalu,
    SUBalu,
    ANDalu,
    ORalu,
    XORalu,
    SLLalu,
    SRLalu,
    SRAalu,
    LUIalu,
    AUIPCalu,
    JALRalu,

    ENDalu
  }alu_op_t;

  typedef enum logic [3:0]{
    PCwrite = 4'd0,
    IRwrite = 4'd1,
    REGwrite = 4'd2,
    MEMwrite = 4'd3,
    MEMsrc = 4'd4,

    HALTED,
    ENDctrl
  }crtl_signal_t;

  typedef enum logic [2:0]{
    Byte,
    HalfWord,
    Word,
    
    //PLACEHOLDER
    ByteUnsigned,
    HalfWordUnsigned,

    EndData
  }data_size_t;

endpackage
