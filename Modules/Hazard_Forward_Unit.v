//  The phoeniX RISC-V Processor
//  A Reconfigurable Embedded Platform for Approximate Computing and Fault-Tolerant Applications

//  Description: Hazard Detection and Data Forwarding Unit Module
//  Copyright 2025 Iran University of Science and Technology. <phoenix.digital.electronics@gmail.com>

//  Permission to use, copy, modify, and/or distribute this software for any
//  purpose with or without fee is hereby granted, provided that the above
//  copyright notice and this permission notice appear in all copies.

`include "Defines.v"

module Hazard_Forward_Unit 
(
    input   wire [ 4 : 0] source_index,          
    
    input   wire [ 4 : 0] destination_index_1,
    input   wire [ 4 : 0] destination_index_2,

    input   wire [31 : 0] data_1,
    input   wire [31 : 0] data_2,

    input   wire enable_1,
    input   wire enable_2,
    
    output  wire forward_enable,
    output  wire [31 : 0] forward_data
);

    assign  forward_data    =   (source_index == destination_index_1 && enable_1 == `ENABLE) ?  data_1  :
                                (source_index == destination_index_2 && enable_2 == `ENABLE) ?  data_2  :
                                'bz;
    
    assign  forward_enable  =   (source_index == destination_index_1 && enable_1 == `ENABLE) ?  `ENABLE  :
                                (source_index == destination_index_2 && enable_2 == `ENABLE) ?  `ENABLE  :
                                `DISABLE;
endmodule