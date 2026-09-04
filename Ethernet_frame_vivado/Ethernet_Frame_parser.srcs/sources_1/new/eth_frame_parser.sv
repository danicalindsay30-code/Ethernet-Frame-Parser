`timescale 1ns / 1ps

module eth_frame_parser(input logic clk, valid_in, last_in,
                        input logic  [7:0] data_in, 
                        output logic [47:0] dest_mac_reg,
                        output logic [47:0]src_mac_reg,
                        output logic [15:0]eth_typ_reg);
                        //streaming payload path
                        
       enum {IDLE, DEST_MAC, SRC_MAC, ETH_TYP, PAYLD} present_state, next_state;
       
       //internal wires 
       logic [2:0] count; 
       
       //state logic 
       always_ff @(posedge clk)
          case(present_state)
              IDLE: if(valid_in == 1 && count == 0)
                       next_state = DEST_MAC; 
              DEST_MAC: if(valid_in == 1 && count == 5)
                              next_state = SRC_MAC;
              SRC_MAC: if(valid_in == 1 && count == 5)
                             next_state = ETH_TYP;
              ETH_TYP: if(valid_in == 1 && count == 1)
                            next_state = PAYLD; 
              PAYLD: if(valid_in == 1 && last_in == 1)
                        next_state = IDLE;                       
          endcase 
         //counter update 
         
           
       
       //combinational logic 
       
       
       //output logic 
                        
endmodule
