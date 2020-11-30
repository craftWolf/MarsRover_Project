library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;


entity simple_controller_tb is
end simple_controller_tb;

architecture mixed of simple_controller_tb is
	component simple_controller 
	port (	clk			: in	std_logic;
		reset			: in	std_logic;

		sensor_l		: in	std_logic;
		sensor_m		: in	std_logic;
		sensor_r		: in	std_logic;

		count_in		: in	std_logic_vector (20 downto 0);
		count_reset		: out	std_logic;

		motor_l_reset		: out	std_logic;
		motor_l_direction	: out	std_logic;

		motor_r_reset		: out	std_logic;
		motor_r_direction	: out	std_logic
	);
	end component;

signal clk		: std_logic;
signal reset		: std_logic;
signal sensor_l		: std_logic;
signal sensor_m		: std_logic;
signal sensor_r		: std_logic;
signal count_in		: std_logic_vector(20 downto 0);
signal count_reset	: std_logic;
signal motor_l_reset	: std_logic;
signal motor_l_direction: std_logic;
signal motor_r_reset	: std_logic;
signal motor_r_direction: std_logic;

begin

	clk		<= 	'1' after 0 ns,
				'0' after 10 ns when clk /= '0' else '1' after 10 ns; -- generate the 100MHZ clock
	reset		<= 	'0' after 0 ns, --test reset at different values
				'1' after 17 ns,
				'0' after 30 ns;

	sensor_l	<=	'1' after 0 ns,
				'0' after 500 ns;
	sensor_m	<=	'0' after 0 ns,
				'1' after 550 ns;
	sensor_r	<=	sensor_l;

	count_in	<=	std_logic_vector(to_unsigned(0, count_in'length))		after 0 ns,
				std_logic_vector(to_unsigned(1000001, count_in'length))		after 50 ns,
				std_logic_vector(to_unsigned(1500000, count_in'length))		after 100 ns,
				std_logic_vector(to_unsigned(2000001, count_in'length))		after 150 ns,
				std_logic_vector(to_unsigned(0, count_in'length))		after 160 ns,
				std_logic_vector(to_unsigned(1000001, count_in'length))		after 250 ns,
				std_logic_vector(to_unsigned(1500000, count_in'length))		after 300 ns,
				std_logic_vector(to_unsigned(2000001, count_in'length))		after 400 ns,
				std_logic_vector(to_unsigned(0, count_in'length))		after 420 ns,
				std_logic_vector(to_unsigned(1000001, count_in'length))		after 450 ns,
				std_logic_vector(to_unsigned(1500000, count_in'length))		after 500 ns,
				std_logic_vector(to_unsigned(2000001, count_in'length))		after 550 ns,
				std_logic_vector(to_unsigned(0, count_in'length))		after 600 ns;

lbl: simple_controller port map (	clk => clk, 
					reset => reset, 
					sensor_l => sensor_l, 
					sensor_m => sensor_m, 
					sensor_r => sensor_r,
					count_in => count_in,
					count_reset => count_reset,
					motor_l_reset => motor_l_reset,
					motor_l_direction => motor_l_direction,
					motor_r_reset => motor_r_reset,
					motor_r_direction => motor_r_direction);

end architecture mixed;
