//  The phoeniX RISC-V Processor
//  A Reconfigurable Embedded Platform for Approximate Computing and Fault-Tolerant Applications

//  Description: Fetch Unit Module
//  Copyright 2025 Iran University of Science and Technology. <phoenix.digital.electronics@gmail.com>

//  Permission to use, copy, modify, and/or distribute this software for any
//  purpose with or without fee is hereby granted, provided that the above
//  copyright notice and this permission notice appear in all copies.

`include "Defines.v"

module Fetch_Unit
(
	input   wire    enable,                    

    input   wire    [31 : 0]    pc, 
    output  wire    [31 : 0]    next_pc,  
    
    //////////////////////////////
    // Memory Interface Signals //
    //////////////////////////////
    output  wire                memory_interface_enable,
    output  wire                memory_interface_state,
    output  wire    [31 : 0]    memory_interface_address,
    output  wire    [ 3 : 0]    memory_interface_frame_mask
);

    wire [29 : 0] incrementer_result;

    Incrementer 
    #(
        .LEN(30)
    )
    incrementer
    (
        .value(pc[31 : 2]),
        .result(incrementer_result)
    );

    assign  next_pc = (enable) ? {incrementer_result, 2'b00} : 'bz;

    assign  memory_interface_enable     =   (enable) ? `ENABLE  :   `DISABLE;
    assign  memory_interface_state      =   (enable) ? `READ    :   'bz;
    assign  memory_interface_address    =   (enable) ? pc       :   'bz;
    assign  memory_interface_frame_mask =   (enable) ? 4'b1111  :   'bz;
endmodule

module Incrementer
#(
    parameter LEN = 32
)
(
    input   wire [LEN - 1 : 0]  value,
    output  wire [LEN - 1 : 0]  result
);

    localparam COUNT = LEN / 4;
    `define SLICE  [(i * 4) + 3 : (i * 4)]

    wire [COUNT - 1 : 0] carry_chain;
    
    Incrementer_Unit IU_1 
    (
        .value(value[3 : 0]),
        .result(result[3 : 0]),
        .C_out(carry_chain[0])
    );

    wire [3 : 0] incrementer_unit_result [1 : COUNT];
    wire [COUNT - 1 : 1] incrementer_unit_carry_out;

    genvar i;
    generate
        for (i = 1; i < COUNT; i = i + 1)
        begin : Incrementer_Generate_Block
            Incrementer_Unit IU
            (
                .value(value`SLICE),
                .result(incrementer_unit_result[i]),
                .C_out(incrementer_unit_carry_out[i])
            );

            Mux_2to1_Incrementer MUX
            (
                .data_in_1({1'b0, value`SLICE}),
                .data_in_2({incrementer_unit_carry_out[i], incrementer_unit_result[i]}),
                .select(carry_chain[i - 1]),
                .data_out({carry_chain[i], result`SLICE})
            );
        end

        if (COUNT * 4 < LEN)
            assign result[LEN - 1 : (COUNT * 4)] = value[LEN - 1 : (COUNT * 4)] + carry_chain[COUNT - 1]; 
    endgenerate
endmodule

module Incrementer_Unit 
(
    input   wire [3 : 0]    value,
    output  wire [4 : 1]    result,
    output  wire            C_out
);

    assign result[1] = ~value[0];
    assign result[2] = value[1] ^ value[0];
    wire   C1   = value[1] & value[0];
    wire   C2   = value[2] & value[3];
    assign C_out = C1 & C2;
    wire   C3   = C1 & value[2];
    assign result[3] = value[2] ^ C1;
    assign result[4] = value[3] ^ C3;
endmodule

module Mux_2to1_Incrementer
#(
    parameter LEN = 5
) 
(
    input   wire [LEN - 1 : 0]  data_in_1,        
    input   wire [LEN - 1 : 0]  data_in_2,        
    input   wire                select,                   

    output  wire [LEN - 1 : 0]  data_out            
);

    assign  data_out = (select) ? data_in_2 : data_in_1;
endmodule