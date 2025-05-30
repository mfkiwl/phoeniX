//  The phoeniX RISC-V Processor
//  A Reconfigurable Embedded Platform for Approximate Computing and Fault-Tolerant Applications

//  Description: Load and Stroe Unit (LSU) Module
//  Copyright 2025 Iran University of Science and Technology. <phoenix.digital.electronics@gmail.com>

//  Permission to use, copy, modify, and/or distribute this software for any
//  purpose with or without fee is hereby granted, provided that the above
//  copyright notice and this permission notice appear in all copies.

`include "Defines.v"

module Load_Store_Unit
(
    input   wire    [ 6 : 0] opcode,                  
    input   wire    [ 2 : 0] funct3,                  

    input   wire    [31 : 0] address,           
    input   wire    [31 : 0] store_data,        
    output  wire    [31 : 0] load_data,         

    //////////////////////////////
    // Memory Interface Signals //
    //////////////////////////////
    output  wire    memory_interface_enable,
    output  wire    memory_interface_state,
    output  wire    [31 : 0] memory_interface_address,
    output  wire    [ 3 : 0] memory_interface_frame_mask,
    inout   wire    [31 : 0] memory_interface_data
);
    
    // Memory Interface Enable Signal Generation
    assign  memory_interface_enable     = (opcode == `LOAD || opcode == `STORE) ? `ENABLE : `DISABLE;
    assign  memory_interface_address    = (opcode == `LOAD || opcode == `STORE) ? {address[31 : 2], 2'b00} : 32'bz;

    // Memory State and Frame Mask Generation
    assign  memory_interface_state =    (   opcode == `LOAD    ) ? `READ    :
                                        (   opcode == `STORE   ) ? `WRITE   :
                                        1'bz;

    assign  memory_interface_frame_mask =   (   funct3 == `BYTE                 ||
                                                funct3 == `BYTE_UNSIGNED        )   ?   {                   
                                                                                        ~address[1] & ~address[0], 
                                                                                        ~address[1] &  address[0], 
                                                                                        address[1] & ~address[0], 
                                                                                        address[1] &  address[0]
                                                                                        }       :
                                            (   funct3 == `HALFWORD             ||  
                                                funct3 == `HALFWORD_UNSIGNED    )   ?   {
                                                                                        ~address[1],
                                                                                        ~address[1],
                                                                                        address[1],
                                                                                        address[1]
                                                                                        }       :
                                            (   funct3 == `WORD                 )   ?   4'b1111 :
                                            4'bz;

    wire    [31 : 0] load_data_value;

    assign  load_data_value     =   (   (funct3 == `BYTE                ) && (memory_interface_frame_mask == 4'b0001)   )   ?   {{24{memory_interface_data[31]}}, memory_interface_data[31 : 24]}   :
                                    (   (funct3 == `BYTE                ) && (memory_interface_frame_mask == 4'b0010)   )   ?   {{24{memory_interface_data[23]}}, memory_interface_data[23 : 16]}   :
                                    (   (funct3 == `BYTE                ) && (memory_interface_frame_mask == 4'b0100)   )   ?   {{24{memory_interface_data[15]}}, memory_interface_data[15 :  8]}   :
                                    (   (funct3 == `BYTE                ) && (memory_interface_frame_mask == 4'b1000)   )   ?   {{24{memory_interface_data[ 7]}}, memory_interface_data[ 7 :  0]}   :
                                    (   (funct3 == `BYTE_UNSIGNED       ) && (memory_interface_frame_mask == 4'b0001)   )   ?   {{24'd0}, memory_interface_data[31 : 24]}                           :
                                    (   (funct3 == `BYTE_UNSIGNED       ) && (memory_interface_frame_mask == 4'b0010)   )   ?   {{24'd0}, memory_interface_data[23 : 16]}                           :
                                    (   (funct3 == `BYTE_UNSIGNED       ) && (memory_interface_frame_mask == 4'b0100)   )   ?   {{24'd0}, memory_interface_data[15 :  8]}                           :
                                    (   (funct3 == `BYTE_UNSIGNED       ) && (memory_interface_frame_mask == 4'b1000)   )   ?   {{24'd0}, memory_interface_data[ 7 :  0]}                           :
                                    (   (funct3 == `HALFWORD            ) && (memory_interface_frame_mask == 4'b0011)   )   ?   {{16{memory_interface_data[31]}}, memory_interface_data[31 : 16]}   :
                                    (   (funct3 == `HALFWORD            ) && (memory_interface_frame_mask == 4'b1100)   )   ?   {{16{memory_interface_data[15]}}, memory_interface_data[15 :  0]}   :
                                    (   (funct3 == `HALFWORD_UNSIGNED   ) && (memory_interface_frame_mask == 4'b0011)   )   ?   {{16'd0}, memory_interface_data[31 : 16]}                           :
                                    (   (funct3 == `HALFWORD_UNSIGNED   ) && (memory_interface_frame_mask == 4'b1100)   )   ?   {{16'd0}, memory_interface_data[15 :  0]}                           :
                                    (   (funct3 == `WORD)                                                               )   ?   memory_interface_data                                               :
                                    32'bz;
    
    wire    [31 : 0] store_data_value;

    assign  store_data_value    =   (   (funct3 == `BYTE        ) && (memory_interface_frame_mask == 4'b0001)   )   ?   {   store_data[ 7 : 0],         24'bz   }   :
                                    (   (funct3 == `BYTE        ) && (memory_interface_frame_mask == 4'b0010)   )   ?   {   8'bz,   store_data[ 7 : 0], 16'bz   }   :
                                    (   (funct3 == `BYTE        ) && (memory_interface_frame_mask == 4'b0100)   )   ?   {   16'bz,  store_data[ 7 : 0], 8'bz    }   :
                                    (   (funct3 == `BYTE        ) && (memory_interface_frame_mask == 4'b1000)   )   ?   {   24'bz,  store_data[ 7 : 0]          }   :
                                    (   (funct3 == `HALFWORD    ) && (memory_interface_frame_mask == 4'b0011)   )   ?   {   store_data[15 : 0],         16'bz   }   :
                                    (   (funct3 == `HALFWORD    ) && (memory_interface_frame_mask == 4'b1100)   )   ?   {   16'bz,      store_data[15 : 0]      }   :
                                    (   (funct3 == `WORD        )                                               )   ?   store_data                                  :
                                    32'bz;

    assign load_data = (opcode == `LOAD) ? load_data_value : 32'bz;
    assign memory_interface_data = (opcode == `STORE) ? store_data_value : 32'bz;
endmodule