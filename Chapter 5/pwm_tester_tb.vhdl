library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.math_real.all;

library FLOATFIXLIB;
use FLOATFIXLIB.fixed_pkg.to_sfixed;

entity pwm_tester_tb is
end pwm_tester_tb;

architecture mixed of pwm_tester_tb is

  component pwm_tester is
  	port (	clk 		: in std_logic;
  		reset 		: in std_logic;
  		direction 	: in std_logic;
  		pwm 		: out std_logic);
  end component pwm_tester;

  signal CLK_100MHZ : std_logic:='0';
  signal reset: std_logic;
  signal switch: std_logic;
  signal pwm_out: std_logic;

begin

  CLK_100MHZ <= not CLK_100MHZ after 5 ns;
  reset <= '1' after 0 ns, '0' after 300 ns;
  switch <= '0' after 0 ns, '1' after 21 ms;
  lbl1: pwm_tester port map (clk => CLK_100MHZ, reset => reset, direction => switch, pwm=>pwm_out);

SIM_STOP: process
					begin
						wait for 50 ms;
						assert false report "Simulation Finished Succesfully" severity failure;
					end process;

end architecture mixed;
