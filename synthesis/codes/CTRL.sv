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
    PCwrite = 0,
    IRwrite = 1,
    REGwrite = 2,
    MEMwrite = 3,
    MEMsrc = 4,

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