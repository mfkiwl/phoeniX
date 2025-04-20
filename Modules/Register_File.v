//  The phoeniX RISC-V Processor
//  A Reconfigurable Embedded Platform for Approximate Computing and Fault-Tolerant Applications

//  Description: 32x32 Register File Module
//  Copyright 2025 Iran University of Science and Technology. <phoenix.digital.electronics@gmail.com>

//  Permission to use, copy, modify, and/or distribute this software for any
//  purpose with or without fee is hereby granted, provided that the above
//  copyright notice and this permission notice appear in all copies.

`include "Defines.v"

module Register_File
#(
    parameter WIDTH = 32,
    parameter DEPTH = 5
)
(
    input   wire    clk,
    input   wire    reset,
    
    input   wire    read_enable_1,
    input   wire    read_enable_2,
    input   wire    write_enable,
    
    input   wire    [DEPTH - 1 : 0] read_index_1,
    input   wire    [DEPTH - 1 : 0] read_index_2,
    input   wire    [DEPTH - 1 : 0] write_index,

    input   wire    [WIDTH - 1 : 0] write_data,

    output  wire    [WIDTH - 1 : 0] read_data_1,
    output  wire    [WIDTH - 1 : 0] read_data_2
);

    localparam NUM_WORDS = 2**DEPTH;
	reg [WIDTH - 1 : 0] Registers [0 : NUM_WORDS - 1];      

    wire [NUM_WORDS - 1 : 0] write_enable_signal;

    genvar i;    	
    for (i = 0; i < NUM_WORDS; i = i + 1)
    begin
        assign write_enable_signal[i] = (write_index == (i)) ? write_enable : `DISABLE;
    end

    for (i = 0; i < NUM_WORDS; i = i + 1)
    begin
        always @(posedge clk or posedge reset) 
        begin
            if (reset)
                Registers[i] <= {WIDTH{1'b0}};

            else if (write_enable_signal[i])
                Registers[i] <= write_data;
        end    
    end

    assign read_data_1 = (read_enable_1) ? Registers[read_index_1] : 'bz;
    assign read_data_2 = (read_enable_2) ? Registers[read_index_2] : 'bz;
endmodule