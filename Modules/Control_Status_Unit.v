//  The phoeniX RISC-V Processor
//  A Reconfigurable Embedded Platform for Approximate Computing and Fault-Tolerant Applications

//  Description: Control Status Unit Module
//  Copyright 2025 Iran University of Science and Technology. <phoenix.digital.electronics@gmail.com>

//  Permission to use, copy, modify, and/or distribute this software for any
//  purpose with or without fee is hereby granted, provided that the above
//  copyright notice and this permission notice appear in all copies.

`include "Defines.v"

module Control_Status_Unit 
(
    input   wire [ 6 : 0] opcode,
    input   wire [ 2 : 0] funct3,

    input   wire [31 : 0] CSR_in,
    input   wire [31 : 0] rs1,
    input   wire [ 4 : 0] unsigned_immediate,

    output  wire [31 : 0] rd,
    output  wire [31 : 0] CSR_out
);

    assign  rd  =   (   {funct3, opcode} == {`CSRRW,  `SYSTEM}  ||
                        {funct3, opcode} == {`CSRRS,  `SYSTEM}  ||
                        {funct3, opcode} == {`CSRRC,  `SYSTEM}  ||
                        {funct3, opcode} == {`CSRRWI, `SYSTEM}  ||
                        {funct3, opcode} == {`CSRRSI, `SYSTEM}  ||
                        {funct3, opcode} == {`CSRRCI, `SYSTEM}  )   ?   CSR_in : 
                        32'bz;

    assign  CSR_out =   (   {funct3, opcode} == {`CSRRW,  `SYSTEM}  )   ?   rs1                                     :
                        (   {funct3, opcode} == {`CSRRS,  `SYSTEM}  )   ?   CSR_in | rs1                            :
                        (   {funct3, opcode} == {`CSRRC,  `SYSTEM}  )   ?   CSR_in & ~rs1                           :
                        (   {funct3, opcode} == {`CSRRWI, `SYSTEM}  )   ?   {27'b0, unsigned_immediate}             :
                        (   {funct3, opcode} == {`CSRRSI, `SYSTEM}  )   ?   CSR_in | {27'b0, unsigned_immediate}    :
                        (   {funct3, opcode} == {`CSRRCI, `SYSTEM}  )   ?   CSR_in & ~{27'b0, unsigned_immediate}   :
                        32'bz;
endmodule
