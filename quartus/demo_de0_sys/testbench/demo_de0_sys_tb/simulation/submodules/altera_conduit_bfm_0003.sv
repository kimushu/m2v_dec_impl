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
// output_name:                                       altera_conduit_bfm_0003
// role:width:direction:                              a:4:input,b:4:input,c:4:input,d:4:input,e:4:input,f:4:input,g:4:input,dp:4:input
//-----------------------------------------------------------------------------
`timescale 1 ns / 1 ns

module altera_conduit_bfm_0003
(
   sig_a,
   sig_b,
   sig_c,
   sig_d,
   sig_e,
   sig_f,
   sig_g,
   sig_dp
);

   //--------------------------------------------------------------------------
   // =head1 PINS 
   // =head2 User defined interface
   //--------------------------------------------------------------------------
   input [3 : 0] sig_a;
   input [3 : 0] sig_b;
   input [3 : 0] sig_c;
   input [3 : 0] sig_d;
   input [3 : 0] sig_e;
   input [3 : 0] sig_f;
   input [3 : 0] sig_g;
   input [3 : 0] sig_dp;

   // synthesis translate_off
   import verbosity_pkg::*;
   
   typedef logic [3 : 0] ROLE_a_t;
   typedef logic [3 : 0] ROLE_b_t;
   typedef logic [3 : 0] ROLE_c_t;
   typedef logic [3 : 0] ROLE_d_t;
   typedef logic [3 : 0] ROLE_e_t;
   typedef logic [3 : 0] ROLE_f_t;
   typedef logic [3 : 0] ROLE_g_t;
   typedef logic [3 : 0] ROLE_dp_t;

   logic [3 : 0] a_local;
   logic [3 : 0] b_local;
   logic [3 : 0] c_local;
   logic [3 : 0] d_local;
   logic [3 : 0] e_local;
   logic [3 : 0] f_local;
   logic [3 : 0] g_local;
   logic [3 : 0] dp_local;

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
   
   event signal_input_a_change;
   event signal_input_b_change;
   event signal_input_c_change;
   event signal_input_d_change;
   event signal_input_e_change;
   event signal_input_f_change;
   event signal_input_g_change;
   event signal_input_dp_change;
   
   function automatic string get_version();  // public
      // Return BFM version string. For example, version 9.1 sp1 is "9.1sp1" 
      string ret_version = "11.1";
      return ret_version;
   endfunction

   // -------------------------------------------------------
   // a
   // -------------------------------------------------------
   function automatic ROLE_a_t get_a();
   
      // Gets the a input value.
      $sformat(message, "%m: called get_a");
      print(VERBOSITY_DEBUG, message);
      return sig_a;
      
   endfunction

   // -------------------------------------------------------
   // b
   // -------------------------------------------------------
   function automatic ROLE_b_t get_b();
   
      // Gets the b input value.
      $sformat(message, "%m: called get_b");
      print(VERBOSITY_DEBUG, message);
      return sig_b;
      
   endfunction

   // -------------------------------------------------------
   // c
   // -------------------------------------------------------
   function automatic ROLE_c_t get_c();
   
      // Gets the c input value.
      $sformat(message, "%m: called get_c");
      print(VERBOSITY_DEBUG, message);
      return sig_c;
      
   endfunction

   // -------------------------------------------------------
   // d
   // -------------------------------------------------------
   function automatic ROLE_d_t get_d();
   
      // Gets the d input value.
      $sformat(message, "%m: called get_d");
      print(VERBOSITY_DEBUG, message);
      return sig_d;
      
   endfunction

   // -------------------------------------------------------
   // e
   // -------------------------------------------------------
   function automatic ROLE_e_t get_e();
   
      // Gets the e input value.
      $sformat(message, "%m: called get_e");
      print(VERBOSITY_DEBUG, message);
      return sig_e;
      
   endfunction

   // -------------------------------------------------------
   // f
   // -------------------------------------------------------
   function automatic ROLE_f_t get_f();
   
      // Gets the f input value.
      $sformat(message, "%m: called get_f");
      print(VERBOSITY_DEBUG, message);
      return sig_f;
      
   endfunction

   // -------------------------------------------------------
   // g
   // -------------------------------------------------------
   function automatic ROLE_g_t get_g();
   
      // Gets the g input value.
      $sformat(message, "%m: called get_g");
      print(VERBOSITY_DEBUG, message);
      return sig_g;
      
   endfunction

   // -------------------------------------------------------
   // dp
   // -------------------------------------------------------
   function automatic ROLE_dp_t get_dp();
   
      // Gets the dp input value.
      $sformat(message, "%m: called get_dp");
      print(VERBOSITY_DEBUG, message);
      return sig_dp;
      
   endfunction


   always @(sig_a) begin
      if (a_local != sig_a)
         -> signal_input_a_change;
      a_local = sig_a;
   end
   
   always @(sig_b) begin
      if (b_local != sig_b)
         -> signal_input_b_change;
      b_local = sig_b;
   end
   
   always @(sig_c) begin
      if (c_local != sig_c)
         -> signal_input_c_change;
      c_local = sig_c;
   end
   
   always @(sig_d) begin
      if (d_local != sig_d)
         -> signal_input_d_change;
      d_local = sig_d;
   end
   
   always @(sig_e) begin
      if (e_local != sig_e)
         -> signal_input_e_change;
      e_local = sig_e;
   end
   
   always @(sig_f) begin
      if (f_local != sig_f)
         -> signal_input_f_change;
      f_local = sig_f;
   end
   
   always @(sig_g) begin
      if (g_local != sig_g)
         -> signal_input_g_change;
      g_local = sig_g;
   end
   
   always @(sig_dp) begin
      if (dp_local != sig_dp)
         -> signal_input_dp_change;
      dp_local = sig_dp;
   end
   


// synthesis translate_on

endmodule


