// (C) 2001-2012 Altera Corporation. All rights reserved.
// Your use of Altera Corporation's design tools, logic functions and other 
// software and tools, and its AMPP partner logic functions, and any output 
// files any of the foregoing (including device programming or simulation 
// files), and any associated documentation or information are expressly subject 
// to the terms and conditions of the Altera Program License Subscription 
// Agreement, Altera MegaCore Function License Agreement, or other applicable 
// license agreement, including, without limitation, that your use is for the 
// sole purpose of programming logic devices manufactured by Altera and sold by 
// Altera or its authorized distributors.  Please refer to the applicable 
// agreement for further details.


// $Id: //acds/main/ip/sopc/components/verification/altera_tristate_conduit_bfm/altera_tristate_conduit_bfm.sv.terp#7 $
// $Revision: #7 $
// $Date: 2010/08/05 $
// $Author: klong $
//-----------------------------------------------------------------------------
// =head1 NAME
// altera_conduit_bfm
// =head1 SYNOPSIS
// Bus Functional Model (BFM) for a Standard Conduit BFM
//-----------------------------------------------------------------------------
// =head1 DESCRIPTION
// This is a Bus Functional Model (BFM) for a Standard Conduit Master.
// This BFM sampled the input/bidirection port value or driving user's value to 
// output ports when user call the API.  
// This BFM's HDL is been generated through terp file in Qsys/SOPC Builder.
// Generation parameters:
// output_name:                                       altera_conduit_bfm_0004
// role:width:direction:                              reset_n:1:input,cs:1:input,rs:1:input,data:16:bidir,write_n:1:input,read_n:1:input
//-----------------------------------------------------------------------------
`timescale 1 ns / 1 ns

module altera_conduit_bfm_0004
(
   sig_reset_n,
   sig_cs,
   sig_rs,
   sig_data,
   sig_write_n,
   sig_read_n
);

   //--------------------------------------------------------------------------
   // =head1 PINS 
   // =head2 User defined interface
   //--------------------------------------------------------------------------
   input sig_reset_n;
   input sig_cs;
   input sig_rs;
   inout wire [15 : 0] sig_data;
   input sig_write_n;
   input sig_read_n;

   // synthesis translate_off
   import verbosity_pkg::*;
   
   typedef logic ROLE_reset_n_t;
   typedef logic ROLE_cs_t;
   typedef logic ROLE_rs_t;
   typedef logic [15 : 0] ROLE_data_t;
   typedef logic ROLE_write_n_t;
   typedef logic ROLE_read_n_t;

   logic [0 : 0] reset_n_local;
   logic [0 : 0] cs_local;
   logic [0 : 0] rs_local;
   reg data_oe = 0;
   reg [15 : 0] data_temp;
   logic [15 : 0] data_local;
   logic [0 : 0] write_n_local;
   logic [0 : 0] read_n_local;

   //--------------------------------------------------------------------------
   // =head1 Public Methods API
   // =pod
   // This section describes the public methods in the application programming
   // interface (API). The application program interface provides methods for 
   // a testbench which instantiates, controls and queries state in this BFM 
   // component. Test programs must only use these public access methods and 
   // events to communicate with this BFM component. The API and module pins
   // are the only interfaces of this component that are guaranteed to be
   // stable. The API will be maintained for the life of the product. 
   // While we cannot prevent a test program from directly accessing internal
   // tasks, functions, or data private to the BFM, there is no guarantee that
   // these will be present in the future. In fact, it is best for the user
   // to assume that the underlying implementation of this component can 
   // and will change.
   // =cut
   //--------------------------------------------------------------------------
   
   event signal_input_reset_n_change;
   event signal_input_cs_change;
   event signal_input_rs_change;
   event signal_input_data_change;
   event signal_input_write_n_change;
   event signal_input_read_n_change;
   
   function automatic string get_version();  // public
      // Return BFM version string. For example, version 9.1 sp1 is "9.1sp1" 
      string ret_version = "11.1";
      return ret_version;
   endfunction

   // -------------------------------------------------------
   // reset_n
   // -------------------------------------------------------
   function automatic ROLE_reset_n_t get_reset_n();
   
      // Gets the reset_n input value.
      $sformat(message, "%m: called get_reset_n");
      print(VERBOSITY_DEBUG, message);
      return sig_reset_n;
      
   endfunction

   // -------------------------------------------------------
   // cs
   // -------------------------------------------------------
   function automatic ROLE_cs_t get_cs();
   
      // Gets the cs input value.
      $sformat(message, "%m: called get_cs");
      print(VERBOSITY_DEBUG, message);
      return sig_cs;
      
   endfunction

   // -------------------------------------------------------
   // rs
   // -------------------------------------------------------
   function automatic ROLE_rs_t get_rs();
   
      // Gets the rs input value.
      $sformat(message, "%m: called get_rs");
      print(VERBOSITY_DEBUG, message);
      return sig_rs;
      
   endfunction

   // -------------------------------------------------------
   // data
   // -------------------------------------------------------
   function automatic ROLE_data_t get_data();
   
      // Gets the data input value.
      $sformat(message, "%m: called get_data");
      print(VERBOSITY_DEBUG, message);
      return sig_data;
      
   endfunction

   function automatic void set_data (
      ROLE_data_t new_value
   );
      // Drive the new value to data.
      
      $sformat(message, "%m: method called arg0 %0d", new_value); 
      print(VERBOSITY_DEBUG, message);
      
      data_temp = new_value;
   endfunction
   
   function automatic void set_data_oe (
      bit enable
   );
      // bidir port data will work as output port when set to 1.
      // bidir port data will work as input port when set to 0.
      
      $sformat(message, "%m: method called arg0 %0d", enable); 
      print(VERBOSITY_DEBUG, message);
      
      data_oe = enable;
   endfunction

   // -------------------------------------------------------
   // write_n
   // -------------------------------------------------------
   function automatic ROLE_write_n_t get_write_n();
   
      // Gets the write_n input value.
      $sformat(message, "%m: called get_write_n");
      print(VERBOSITY_DEBUG, message);
      return sig_write_n;
      
   endfunction

   // -------------------------------------------------------
   // read_n
   // -------------------------------------------------------
   function automatic ROLE_read_n_t get_read_n();
   
      // Gets the read_n input value.
      $sformat(message, "%m: called get_read_n");
      print(VERBOSITY_DEBUG, message);
      return sig_read_n;
      
   endfunction

   assign sig_data = (data_oe == 1)? data_temp:'z;

   always @(sig_reset_n) begin
      if (reset_n_local != sig_reset_n)
         -> signal_input_reset_n_change;
      reset_n_local = sig_reset_n;
   end
   
   always @(sig_cs) begin
      if (cs_local != sig_cs)
         -> signal_input_cs_change;
      cs_local = sig_cs;
   end
   
   always @(sig_rs) begin
      if (rs_local != sig_rs)
         -> signal_input_rs_change;
      rs_local = sig_rs;
   end
   
   always @(sig_data) begin
      if (data_oe == 0) begin
         if (data_local != sig_data)
            -> signal_input_data_change;
         data_local = sig_data;
      end
   end
   
   always @(sig_write_n) begin
      if (write_n_local != sig_write_n)
         -> signal_input_write_n_change;
      write_n_local = sig_write_n;
   end
   
   always @(sig_read_n) begin
      if (read_n_local != sig_read_n)
         -> signal_input_read_n_change;
      read_n_local = sig_read_n;
   end
   


// synthesis translate_on

endmodule


