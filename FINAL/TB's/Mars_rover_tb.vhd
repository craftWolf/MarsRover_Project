library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.math_real.all;

entity Mars_rover_tb is
end Mars_rover_tb;

architecture mixed of mars_rover_tb is
component Mars_rover is
	 port( 	input_clk		: in std_logic;
          	input_reset		: in std_logic;
         	input_sensor		: in std_logic_vector (2 downto 0);
      	    	output_pwm_left		: out std_logic;
        	output_pwm_right	: out std_logic
	);
end component Mars_rover;

signal clk		: std_logic;
signal reset		: std_logic;

signal input_sensor	: std_logic_vector (2 downto 0);
signal output_pwm_left	: std_logic;
signal output_pwm_right : std_logic;
signal sensor_l		: std_logic;
signal sensor_m		: std_logic;
signal sensor_r		: std_logic;

begin 
	-- 100 MHZ clock same used in actual robot
	clk 	<= 	'1' after 0 ns,
			'0' after 5 ns when clk /= '0'else '1' after 5 ns;
	-- Reset until 1 ms to make wave diagram easier to look at
	reset 	<= 	'0' after 0 ns,
			'1' after 40 ns,
			'0' after 1 ms;

	-- Change sensor values such that drive states are cycle in the following order
	-- FORWARD, TURN_RIGHT, SHARP_RIGHT, SHARP_LEFT, TURN_LEFT, FORWARD
	-- With two drive cycles of turn_left
	sensor_l <= 	'1' after 0 ns,
			'0' after 15 ms,
			'1' after 55 ms,
			'0' after 155 ms;
			

	sensor_m <=	'1' after 0 ms,
			'0' after 35 ms, 
			'1' after 55 ms,
			'0' after 115 ms,
			'1' after 155 ms,
			'0' after 175 ms;

	sensor_r <= 	'1' after 0 ms,
			'0' after 55 ms, 
			'1' after 75 ms,
			'0' after 95 ms,
			'1' after 135 ms;

input_sensor(0) <= sensor_r;
input_sensor(1) <= sensor_m;
input_sensor(2) <= sensor_l;


system : Mars_rover port map (		input_clk => clk, 
					input_reset => reset, 
					input_sensor => input_sensor,
					output_pwm_left => output_pwm_left,
					output_pwm_right => output_pwm_right
					

				);

SIM_STOP: process
					begin
						wait for 200 ms;
						assert false report "Simulation Finished Succesfully" severity failure;
					end process;
end mixed;

