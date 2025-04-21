//  The phoeniX RISC-V Processor
//  A Reconfigurable Embedded Platform for Approximate Computing and Fault-Tolerant Applications

//  Description: RV32IEM Instruction Decoder Module
//  Copyright 2025 Iran University of Science and Technology. <phoenix.digital.electronics@gmail.com>

//  Permission to use, copy, modify, and/or distribute this software for any
//  purpose with or without fee is hereby granted, provided that the above
//  copyright notice and this permission notice appear in all copies.

`include "Defines.v"

module Instruction_Decoder 
(
    input   wire [31 : 0] instruction,

    output  wire [ 2 : 0] instruction_type,
    output  wire [ 6 : 0] opcode,
    output  wire [ 2 : 0] funct3,
    output  wire [ 6 : 0] funct7,
    output  wire [11 : 0] funct12,

    output  wire [ 4 : 0] read_index_1,
    output  wire [ 4 : 0] read_index_2,
    output  wire [ 4 : 0] write_index,
    output  wire [11 : 0] csr_index,

    output  wire read_enable_1,
    output  wire read_enable_2,
    output  wire write_enable,

    output  wire csr_read_enable,
    output  wire csr_write_enable
);

    assign  opcode  = instruction[ 6 :  0];
    assign  funct7  = instruction[31 : 25];
    assign  funct3  = instruction[14 : 12];
    assign  funct12 = instruction[31 : 20]; 

    assign  read_index_1 = instruction[19 : 15];
    assign  read_index_2 = instruction[24 : 20];
    assign  write_index  = instruction[11 :  7];
    assign  csr_index    = instruction[31 : 20];

    assign  instruction_type    =   ( opcode == `OP         )   ?   `R_TYPE         :
                                    ( opcode == `OP_FP      )   ?   `R_TYPE         :

                                    ( opcode == `LOAD       )   ?   `I_TYPE         :
                                    ( opcode == `LOAD_FP    )   ?   `I_TYPE         :
                                    ( opcode == `OP_IMM     )   ?   `I_TYPE         :
                                    ( opcode == `OP_IMM_32  )   ?   `I_TYPE         :
                                    ( opcode == `JALR       )   ?   `I_TYPE         :
                                    ( opcode == `SYSTEM     )   ?   `I_TYPE         :

                                    ( opcode == `STORE      )   ?   `S_TYPE         :
                                    ( opcode == `STORE_FP   )   ?   `S_TYPE         :

                                    ( opcode == `BRANCH     )   ?   `B_TYPE         :

                                    ( opcode == `AUIPC      )   ?   `U_TYPE         :
                                    ( opcode == `LUI        )   ?   `U_TYPE         :

                                    ( opcode == `JAL        )   ?   `J_TYPE         :
                                    `INVALID_TYPE;

    assign  read_enable_1   =   (   instruction_type == `R_TYPE     )   ?   `ENABLE     :
                                (   instruction_type == `I_TYPE     )   ?   `ENABLE     :
                                (   instruction_type == `S_TYPE     )   ?   `ENABLE     :
                                (   instruction_type == `B_TYPE     )   ?   `ENABLE     :
                                (   instruction_type == `U_TYPE     )   ?   `DISABLE    :
                                (   instruction_type == `J_TYPE     )   ?   `DISABLE    :
                                `DISABLE;
    
    assign  read_enable_2   =   (   instruction_type == `R_TYPE     )   ?   `ENABLE     :
                                (   instruction_type == `I_TYPE     )   ?   `DISABLE    :
                                (   instruction_type == `S_TYPE     )   ?   `ENABLE     :
                                (   instruction_type == `B_TYPE     )   ?   `ENABLE     :
                                (   instruction_type == `U_TYPE     )   ?   `DISABLE    :
                                (   instruction_type == `J_TYPE     )   ?   `DISABLE    :
                                `DISABLE;
    
    assign  write_enable    =   (   write_index == 'd0              )   ?   `DISABLE    :
                                (   instruction_type == `R_TYPE     )   ?   `ENABLE     :
                                (   instruction_type == `I_TYPE     )   ?   `ENABLE     :
                                (   instruction_type == `S_TYPE     )   ?   `DISABLE    :
                                (   instruction_type == `B_TYPE     )   ?   `DISABLE    :
                                (   instruction_type == `U_TYPE     )   ?   `ENABLE     :
                                (   instruction_type == `J_TYPE     )   ?   `ENABLE     :
                                `DISABLE;

    assign  csr_read_enable     =   (   (opcode == `SYSTEM) && (funct3 == `CSRRW)   )   ?   `ENABLE :
                                    (   (opcode == `SYSTEM) && (funct3 == `CSRRS)   )   ?   `ENABLE :
                                    (   (opcode == `SYSTEM) && (funct3 == `CSRRC)   )   ?   `ENABLE :
                                    (   (opcode == `SYSTEM) && (funct3 == `CSRRWI)  )   ?   `ENABLE :
                                    (   (opcode == `SYSTEM) && (funct3 == `CSRRSI)  )   ?   `ENABLE :
                                    (   (opcode == `SYSTEM) && (funct3 == `CSRRCI)  )   ?   `ENABLE :
                                    `DISABLE;

    assign  csr_write_enable    =   (   (opcode == `SYSTEM) && (funct3 == `CSRRW)   )   ?   `ENABLE & ~(csr_index[11] & csr_index[10])  :
                                    (   (opcode == `SYSTEM) && (funct3 == `CSRRS)   )   ?   `ENABLE & ~(csr_index[11] & csr_index[10])  :
                                    (   (opcode == `SYSTEM) && (funct3 == `CSRRC)   )   ?   `ENABLE & ~(csr_index[11] & csr_index[10])  :
                                    (   (opcode == `SYSTEM) && (funct3 == `CSRRWI)  )   ?   `ENABLE & ~(csr_index[11] & csr_index[10])  :
                                    (   (opcode == `SYSTEM) && (funct3 == `CSRRSI)  )   ?   `ENABLE & ~(csr_index[11] & csr_index[10])  :
                                    (   (opcode == `SYSTEM) && (funct3 == `CSRRCI)  )   ?   `ENABLE & ~(csr_index[11] & csr_index[10])  :
                                    `DISABLE;
endmodule