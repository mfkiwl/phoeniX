//  The phoeniX RISC-V Processor
//  A Reconfigurable Embedded Platform for Approximate Computing and Fault-Tolerant Applications

//  Description: Address Generation Unit (AGU) Module
//  Copyright 2025 Iran University of Science and Technology. <phoenix.digital.electronics@gmail.com>

//  Permission to use, copy, modify, and/or distribute this software for any
//  purpose with or without fee is hereby granted, provided that the above
//  copyright notice and this permission notice appear in all copies.

`include "Defines.v"

module Address_Generator
(
    input   wire [ 6 : 0] opcode, 
    input   wire [31 : 0] rs1,            
    input   wire [31 : 0] pc,
    input   wire [31 : 0] immediate,

    output  wire [31 : 0] address
);

    wire [31 : 0] adder_input_1;
    wire [31 : 0] adder_input_2;
    wire [31 : 0] adder_result;

    assign adder_input_1    =   (   opcode == `STORE    ||
                                    opcode == `LOAD     ||
                                    opcode == `JALR     )   ?   rs1 :
                                (   opcode == `JAL      ||
                                    opcode == `AUIPC    ||
                                    opcode == `BRANCH   )   ?   pc  :
                                    32'bz;

    assign adder_input_2    =   (   opcode == `STORE    ||
                                    opcode == `LOAD     ||
                                    opcode == `JALR     ||
                                    opcode == `JAL      ||
                                    opcode == `AUIPC    ||
                                    opcode == `BRANCH   )   ?   immediate  :
                                    32'bz;

    Address_Generator_CLA 
    #(
        .LEN(32)
    ) 
    address_generator
    (    
        .A      (   adder_input_1   ),
        .B      (   adder_input_2   ),
        .C_in   (   1'b0            ),
        .Sum    (   adder_result    )
    );

    assign address  =   (   opcode == `STORE    ||
                            opcode == `LOAD     ||
                            opcode == `JALR     ||
                            opcode == `JAL      ||
                            opcode == `AUIPC    ||
                            opcode == `BRANCH   )   ?   adder_result  :
                            32'bz;   
endmodule

module Address_Generator_CLA 
#(
    parameter LEN = 32
) 
(
    input   wire [LEN - 1 : 0]  A,
    input   wire [LEN - 1 : 0]  B,
    input   wire                C_in,
    
    output  wire [LEN - 1 : 0]  Sum
);

    wire [LEN : 0] Carry;
    wire [LEN : 0] CarryX;
    wire [LEN - 1 : 0] P;
    wire [LEN - 1 : 0] G;
    
    assign P = A | B;   
    assign G = A & B;   

    assign Carry[0] = C_in;

    genvar i;
    generate
        for (i = 1 ; i <= LEN; i = i + 1)
        begin : Address_Generator_CLA_Generate_Block_1
            assign Carry[i] = G[i - 1] | (P[i - 1] & Carry[i - 1]);
        end
    endgenerate

    generate
        for (i = 0; i < LEN; i = i + 1)
        begin : Address_Generator_CLA_Generate_Block_2
            Full_Adder_CLA FA (.A(A[i]), .B(B[i]), .C_in(Carry[i]), .C_out(CarryX[i + 1]), .Sum(Sum[i]));
        end
    endgenerate
endmodule

module Full_Adder_CLA 
(
    input   wire A,
    input   wire B,
    input   wire C_in,

    output  wire C_out,
    output  wire Sum
);
    
    assign C_out = (A && B) || (A && C_in) || (B && C_in);
    assign Sum = A ^ B ^ C_in; 
endmodule