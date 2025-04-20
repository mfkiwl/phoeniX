//  The phoeniX RISC-V Processor
//  A Reconfigurable Embedded Platform for Approximate Computing and Fault-Tolerant Applications

//  Description: Control Status Register File Module
//  Copyright 2025 Iran University of Science and Technology. <phoenix.digital.electronics@gmail.com>

//  Permission to use, copy, modify, and/or distribute this software for any
//  purpose with or without fee is hereby granted, provided that the above
//  copyright notice and this permission notice appear in all copies.

`include "Defines.v"

module Control_Status_Register_File 
(
    input   wire clk,
    input   wire reset,

    input   wire [ 6 : 0] opcode,
    input   wire [ 2 : 0] funct3,
    input   wire [ 6 : 0] funct7,
    input   wire [11 : 0] funct12,
    input   wire [ 4 : 0] write_index,

    input   wire read_enable_csr,
    input   wire write_enable_csr,

    input   wire [11 : 0] csr_read_index,
    input   wire [11 : 0] csr_write_index,

    input   wire [31 : 0] csr_write_data,
    output  wire [31 : 0] csr_read_data,

    output  wire [31 : 0] alucsr_wire,
    output  wire [31 : 0] mulcsr_wire,
    output  wire [31 : 0] divcsr_wire
);

    // ------------------------ //
    // Control Status Registers //
    // ------------------------ //
    reg [31 : 0] alucsr_reg;       // Arithmetic Logic Unit Aproximation Control Register
    assign alucsr_wire = alucsr_reg;
    
    reg [31 : 0] mulcsr_reg;       // Multiplier Unit Aproximation Control Register
    assign mulcsr_wire = mulcsr_reg;

    reg [31 : 0] divcsr_reg;       // Divider Unit Aproximation Control Register
    assign divcsr_wire = divcsr_reg;

    reg [63 : 0] mcycle_reg;
    reg [63 : 0] minstret_reg;

    // ---------------- //
    // CSR Read Process //
    // ---------------- //
    wire [31 : 0] csr_read_value;

    assign csr_read_value   =   (   csr_read_index == `alucsr       )   ?   alucsr_reg              :
                                (   csr_read_index == `mulcsr       )   ?   mulcsr_reg              :
                                (   csr_read_index == `divcsr       )   ?   divcsr_reg              :
                                (   csr_read_index == `mcycle       )   ?   mcycle_reg[31 :  0]     :
                                (   csr_read_index == `mcycleh      )   ?   mcycle_reg[63 : 32]     :
                                (   csr_read_index == `minstret     )   ?   minstret_reg[31 :  0]   :
                                (   csr_read_index == `minstreth    )   ?   minstret_reg[63 : 32]   :
                                'bz;

    assign csr_read_data    =   (read_enable_csr) ? csr_read_value : 'bz;

    // ----------------- //
    // CSR Write Process //
    // ----------------- //
    always @(posedge clk or posedge reset)
    begin
        if (reset)
            alucsr_reg <= 32'd0; 
        else if (write_enable_csr && (csr_write_index == `alucsr))
            alucsr_reg <= csr_write_data;
    end

    always @(posedge clk or posedge reset)
    begin
        if (reset)
            mulcsr_reg <= 32'd0; 
        else if (write_enable_csr && (csr_write_index == `mulcsr))
            mulcsr_reg <= csr_write_data;
    end

    always @(posedge clk or posedge reset)
    begin
        if (reset)
            divcsr_reg <= 32'd0; 
        else if (write_enable_csr && (csr_write_index == `divcsr))
            divcsr_reg <= csr_write_data;
    end

    ////////////////////////////////
    //    Performance Counters    //
    ////////////////////////////////

    // -------------
    // Cycle Counter
    // -------------
    always @(posedge clk) 
    begin
        if (reset)  mcycle_reg <= 32'b0;
        else        mcycle_reg <= mcycle_reg + 32'd1; 
    end

    // -------------------
    // Instruction Counter
    // -------------------
    always @(posedge clk) 
    begin
        if (reset)  minstret_reg <= 32'b0;
        else if (!(
            opcode       == `NOP_opcode  &
            funct3       == `NOP_funct3  &  
            funct7       == `NOP_funct7  & 
            funct12      == `NOP_funct12 &
            write_index  == `NOP_write_index    
        ))
            minstret_reg <= minstret_reg + 32'd1;
    end
endmodule