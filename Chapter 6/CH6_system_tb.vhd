library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.math_real.all;

entity ch6_system_tb is
end ch6_system_tb;

architecture mixed of ch6_system_tb is
component CH6_system is
	port (	clk			: in  std_logic;
		reset			: in  std_logic;

		sensor_l		: in  std_logic;
		sensor_m		: in  std_logic;
		sensor_r		: in  std_logic;
		pwm_l			: out std_logic; -- the PWM signals, for the left motor,
		pwm_r			: out std_logic  -- and the right motor.
	);
end component CH6_system;

signal clk		: std_logic;
signal reset		: std_logic;
signal sensor_l		: std_logic;
signal sensor_m		: std_logic;
signal sensor_r		: std_logic;

signal pwm_l_out 	: std_logic;
signal pwm_r_out 	: std_logic;
begin 
	-- 100 MHZ clock same used in actual robot
	clk 	<= 	'1' after 0 ns,
			'0' after 5 ns when clk /= '0'else '1' after 5 ns;
	-- Reset until 1 ms to make wave diagram easier to look at
	reset 	<= 	'0' after 0 ns,
			'1' after 40 ns,
			'0' after 1 ms,
			'1' after 150 ms;
	-- Change sensor values such that drive states are cycle in the following order
	-- FORWARD, TURN_RIGHT, SHARP_RIGHT, SHARP_LEFT, TURN_LEFT, FORWARD
	-- With two drive cycles of turn_left
	sensor_l <= 	'1' after 0 ns,
			'0' after 15 ms,
			'1' after 35 ms, 
			'0' after 55 ms;
	sensor_m <=	'1' after 0 ms,
			'0' after 35 ms, 
			'1' after 85 ms,
			'0' after 105 ms;
	sensor_r <= 	'1' after 0 ms,
			'0' after 35 ms, 
			'1' after 55 ms,
			'0' after 105 ms;

system : CH6_system port map  (	clk => clk, 			
				reset => reset,		
				sensor_l => sensor_l,		
				sensor_m => sensor_m,		
				sensor_r => sensor_r,	
	
				pwm_l => pwm_l_out,
				pwm_r => pwm_r_out			
	);

SIM_STOP: process
					begin
						wait for 180 ms;
						assert false report "Simulation Finished Succesfully" severity failure;
					end process;
end mixed;
