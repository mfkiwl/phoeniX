//  The phoeniX RISC-V Processor
//  A Reconfigurable Embedded Platform for Approximate Computing and Fault-Tolerant Applications

//  Description: 32x32 Register Loading Table Module
//  Copyright 2025 Iran University of Science and Technology. <phoenix.digital.electronics@gmail.com>

//  Permission to use, copy, modify, and/or distribute this software for any
//  purpose with or without fee is hereby granted, provided that the above
//  copyright notice and this permission notice appear in all copies.

`include "Defines.v"

module Register_Loading_Table
#(
    parameter WIDTH = 32,
    parameter DEPTH = 5
)
(
    input wire clk,
    input wire reset,
    
    input wire read_enable,
    input wire write_enable,
    
    input wire [DEPTH - 1 : 0] read_index,
    input wire [DEPTH - 1 : 0] write_index,

    input wire [WIDTH - 1 : 0] write_data,

    output reg [WIDTH - 1 : 0] read_data
);
	reg [WIDTH - 1 : 0] Loading_Table [0 : 2**DEPTH - 1];      

    integer i;    	
    
    always @(posedge clk or posedge reset)
    begin
        if (reset)
        begin
            for (i = 0; i < 2**DEPTH; i = i + 1)
                Loading_Table[i] <= {WIDTH{1'b0}};
        end
        else if (write_enable == `ENABLE)
        begin
            Loading_Table[write_index] <= write_data;
        end
    end

    always @(*) 
    begin
        if (read_enable == `ENABLE)
            read_data <= Loading_Table[read_index];
        else
            read_data <= {WIDTH{1'bz}};
    end
endmodule