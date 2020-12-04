library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.math_real.all;

entity line_finder_tb is
end line_finder_tb;

architecture mixed of line_finder_tb is
component line_finder is
	port (	clk			: in	std_logic;
		reset			: in	std_logic; -- hard rest
		line_finder_reset	: in 	std_logic; -- reset coming from the main controller

		sensor_l		: in	std_logic;
		sensor_m		: in	std_logic;
		sensor_r		: in	std_logic;

		count_in		: in	std_logic_vector (20 downto 0);
		count_reset		: out	std_logic;

		motor_l_reset		: out	std_logic;
		motor_l_direction	: out	std_logic;

		motor_r_reset		: out	std_logic;
		motor_r_direction	: out	std_logic;
		Line_found		: out	std_logic
	);
end component line_finder;

signal clk		: std_logic;
signal reset		: std_logic;
signal line_finder_reset : std_logic;
signal sensor_l		: std_logic;
signal sensor_m		: std_logic;
signal sensor_r		: std_logic;
signal count_in		: std_logic_vector(20 downto 0);
signal count_reset	: std_logic;
signal motor_l_reset	: std_logic;
signal motor_l_direction: std_logic;
signal motor_r_reset	: std_logic;
signal motor_r_direction: std_logic;
signal line_found	: std_logic;

begin 
	-- 100 MHZ clock same used in actual robot
	clk 	<= 	'1' after 0 ns,
			'0' after 5 ns when clk /= '0'else '1' after 5 ns;
	-- Reset until 1 ms to make wave diagram easier to look at
	reset 	<= 	'0' after 0 ns,
			'1' after 40 ns,
			'0' after 1 ms;
			
	line_finder_reset <= 	'0' after 0 ns,
				'1' after 22 ms,
				'0' after 23 ms,
				'1' after 85 ms,
				'0' after 87 ms;
			
	-- Change sensor values such that drive states are cycle in the following order
	-- FORWARD, TURN_RIGHT, SHARP_RIGHT, SHARP_LEFT, TURN_LEFT, FORWARD
	-- With two drive cycles of turn_left
	sensor_l <= 	'1' after 0 ns,
			'0' after 22 ms,
			'1' after 41 ms;
			
	sensor_m <=	'1' after 0 ms,
			'0' after 15 ms,
			'1' after 41 ms;

	sensor_r <= 	'1' after 0 ms,
			'0' after 65 ms,	
			'1' after 115 ms,
			'0' after 135 ms;
			


	count_in <=	std_logic_vector(to_unsigned(0, count_in'length))		after 0 ms,
			std_logic_vector(to_unsigned(2000001, count_in'length))		after 20 ms,
			std_logic_vector(to_unsigned(0, count_in'length))		after 20.00001 ms,
			std_logic_vector(to_unsigned(2000001, count_in'length))		after 40 ms,
			std_logic_vector(to_unsigned(0, count_in'length))		after 40.00001 ms,
			std_logic_vector(to_unsigned(2000001, count_in'length))		after 60 ms,
			std_logic_vector(to_unsigned(0, count_in'length))		after 60.00001 ms,
			std_logic_vector(to_unsigned(2000001, count_in'length))		after 80 ms,
			std_logic_vector(to_unsigned(0, count_in'length))		after 80.00001 ms,
			std_logic_vector(to_unsigned(2000001, count_in'length))		after 100 ms,
			std_logic_vector(to_unsigned(0, count_in'length))		after 100.00001 ms,
			std_logic_vector(to_unsigned(2000001, count_in'length))		after 120 ms,
			std_logic_vector(to_unsigned(0, count_in'length))		after 120.00001 ms,
			std_logic_vector(to_unsigned(2000001, count_in'length))		after 140 ms,
			std_logic_vector(to_unsigned(0, count_in'length))		after 140.00001 ms;




system : line_finder port map (	clk => clk, 
					reset => reset, 
					line_finder_reset => line_finder_reset,
					sensor_l => sensor_l, 
					sensor_m => sensor_m, 
					sensor_r => sensor_r,
					count_in => count_in,
					count_reset => count_reset,
					motor_l_reset => motor_l_reset,
					motor_l_direction => motor_l_direction,
					motor_r_reset => motor_r_reset,
					motor_r_direction => motor_r_direction,
					line_found=>line_found
				);

SIM_STOP: process
					begin
						wait for 180 ms;
						assert false report "Simulation Finished Succesfully" severity failure;
					end process;
end mixed;

