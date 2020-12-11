-- *****************************************************************************
-- Name:     simulink_toplevel_tb.vhd  
-- Project:  EE3130TU Mars Rover Project
-- Created:  04.10.20, 05.10.20
-- Author:   Bas Verdoes
-- Purpose:  TOPLEVEL_TB is a testbench for the entity SIMULINK_TOPLEVEL
-- *****************************************************************************

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity simulink_toplevel_tb is
end simulink_toplevel_tb;

architecture structural of simulink_toplevel_tb is

constant CLK_SCALE : INTEGER := 10000; -- Lower clock frequency by scale factor

signal CLK, NRST    : STD_LOGIC; -- Global clock and negative reset
signal ROS_IN       : STD_LOGIC_VECTOR(2 downto 0); -- ROS-sensor input
signal POS_X, POS_Y : REAL; -- Rover center position (cartesian X,Y)
signal POS_PHI      : REAL; -- Rover angle

begin

-- Generates a 100MHz clk
CLK_GEN:  process is
          begin
            CLK <= '1';
            wait for (5 ns * CLK_SCALE);
            CLK <= '0';
            wait for (5 ns * CLK_SCALE);
          end process;
  
-- Negative reset generator
RST_GEN:  process is
          begin
            NRST <= '0';
            wait for 2 ms;
            NRST <= '1';
            wait;
          end process;

ROS_IN <= "101" after 0 ns;

-- Design Under Test
DUT:  entity work.simulink_toplevel
      generic map(
        CLK_SCALE => CLK_SCALE
      )
      port map(
        CLK      => CLK,
        NRST     => NRST,
        ROS_IN   => ROS_IN,
        POS_X    => POS_X,
        POS_Y    => POS_Y,
        POS_PHI  => POS_PHI
        );

end structural;