//  The phoeniX RISC-V Processor
//  A Reconfigurable Embedded Platform for Approximate Computing and Fault-Tolerant Applications

//  Description: Jump Branch Unit Module
//  Copyright 2025 Iran University of Science and Technology. <phoenix.digital.electronics@gmail.com>

//  Permission to use, copy, modify, and/or distribute this software for any
//  purpose with or without fee is hereby granted, provided that the above
//  copyright notice and this permission notice appear in all copies.

`include "Defines.v"

module Jump_Branch_Unit 
(
    input   wire    [ 6 : 0] opcode,
    input   wire    [ 2 : 0] funct3,
    input   wire    [ 2 : 0] instruction_type,

    input   wire    [31 : 0] rs1,
    input   wire    [31 : 0] rs2,
      
    output  wire    jump_branch_enable     
);

    wire branch_enable;
    wire jump_enable;
    
    assign branch_enable    =   (   (instruction_type == `B_TYPE) && (funct3 == `BEQ)   ) ?   ( ($signed(rs1) == $signed(rs2))  ? `ENABLE : `DISABLE ) :
                                (   (instruction_type == `B_TYPE) && (funct3 == `BNE)   ) ?   ( ($signed(rs1) != $signed(rs2))  ? `ENABLE : `DISABLE ) :
                                (   (instruction_type == `B_TYPE) && (funct3 == `BLT)   ) ?   ( ($signed(rs1) <  $signed(rs2))  ? `ENABLE : `DISABLE ) :
                                (   (instruction_type == `B_TYPE) && (funct3 == `BGE)   ) ?   ( ($signed(rs1) >= $signed(rs2))  ? `ENABLE : `DISABLE ) :
                                (   (instruction_type == `B_TYPE) && (funct3 == `BLTU)  ) ?   ( (rs1 <  rs2)                    ? `ENABLE : `DISABLE ) :
                                (   (instruction_type == `B_TYPE) && (funct3 == `BGEU)  ) ?   ( (rs1 >= rs2)                    ? `ENABLE : `DISABLE ) :
                                `DISABLE;

    assign jump_enable = (opcode == `JAL || opcode == `JALR) ? `ENABLE : `DISABLE;

    assign jump_branch_enable = (jump_enable || branch_enable) ? `ENABLE : `DISABLE;
endmodule