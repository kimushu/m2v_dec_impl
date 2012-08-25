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
// output_name:                                       altera_conduit_bfm_0005
// role:width:direction:                              MISO:1:output,MOSI:1:input,SCLK:1:input,SS_n:1:input
//-----------------------------------------------------------------------------
`timescale 1 ns / 1 ns

module altera_conduit_bfm_0005
(
   sig_MISO,
   sig_MOSI,
   sig_SCLK,
   sig_SS_n
);

   //--------------------------------------------------------------------------
   // =head1 PINS 
   // =head2 User defined interface
   //--------------------------------------------------------------------------
   output sig_MISO;
   input sig_MOSI;
   input sig_SCLK;
   input sig_SS_n;

   // synthesis translate_off
   import verbosity_pkg::*;
   
   typedef logic ROLE_MISO_t;
   typedef logic ROLE_MOSI_t;
   typedef logic ROLE_SCLK_t;
   typedef logic ROLE_SS_n_t;

   reg MISO_temp;
   logic [0 : 0] MOSI_local;
   logic [0 : 0] SCLK_local;
   logic [0 : 0] SS_n_local;

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
   
   event signal_input_MOSI_change;
   event signal_input_SCLK_change;
   event signal_input_SS_n_change;
   
   function automatic string get_version();  // public
      // Return BFM version string. For example, version 9.1 sp1 is "9.1sp1" 
      string ret_version = "11.1";
      return ret_version;
   endfunction

   // -------------------------------------------------------
   // MISO
   // -------------------------------------------------------

   function automatic void set_MISO (
      ROLE_MISO_t new_value
   );
      // Drive the new value to MISO.
      
      $sformat(message, "%m: method called arg0 %0d", new_value); 
      print(VERBOSITY_DEBUG, message);
      
      MISO_temp = new_value;
   endfunction

   // -------------------------------------------------------
   // MOSI
   // -------------------------------------------------------
   function automatic ROLE_MOSI_t get_MOSI();
   
      // Gets the MOSI input value.
      $sformat(message, "%m: called get_MOSI");
      print(VERBOSITY_DEBUG, message);
      return sig_MOSI;
      
   endfunction

   // -------------------------------------------------------
   // SCLK
   // -------------------------------------------------------
   function automatic ROLE_SCLK_t get_SCLK();
   
      // Gets the SCLK input value.
      $sformat(message, "%m: called get_SCLK");
      print(VERBOSITY_DEBUG, message);
      return sig_SCLK;
      
   endfunction

   // -------------------------------------------------------
   // SS_n
   // -------------------------------------------------------
   function automatic ROLE_SS_n_t get_SS_n();
   
      // Gets the SS_n input value.
      $sformat(message, "%m: called get_SS_n");
      print(VERBOSITY_DEBUG, message);
      return sig_SS_n;
      
   endfunction

   assign sig_MISO = MISO_temp;

   always @(sig_MOSI) begin
      if (MOSI_local != sig_MOSI)
         -> signal_input_MOSI_change;
      MOSI_local = sig_MOSI;
   end
   
   always @(sig_SCLK) begin
      if (SCLK_local != sig_SCLK)
         -> signal_input_SCLK_change;
      SCLK_local = sig_SCLK;
   end
   
   always @(sig_SS_n) begin
      if (SS_n_local != sig_SS_n)
         -> signal_input_SS_n_change;
      SS_n_local = sig_SS_n;
   end
   


// synthesis translate_on

endmodule


