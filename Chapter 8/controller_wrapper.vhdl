-- ################################################
--
--      CONTROLLER WRAPPER FOR TESTBENCHES
--         EE3130TU (Mars Rover Project)
--
-- ################################################

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity controller_wrapper is
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
end entity controller_wrapper;

architecture structural of controller_wrapper is

component controller is
	port (
		clk			: in  std_logic;
		reset			: in  std_logic;

		sensor_l		: in  std_logic;
		sensor_m		: in  std_logic;
		sensor_r		: in  std_logic;

		count_in		: in  std_logic_vector (20 downto 0);
		count_reset		: out std_logic;

		motor_l_reset		: out std_logic;
		motor_l_direction	: out std_logic;

		motor_r_reset		: out std_logic;
		motor_r_direction	: out std_logic
	);
end component controller;

begin

CNTRLR: controller port map(
	clk => clk,
	reset => reset,
	sensor_l => sensor_l,
	sensor_m => sensor_m,
	sensor_r => sensor_r,
	count_in => count_in,
	count_reset => count_reset,
	motor_l_reset => motor_l_reset,
	motor_l_direction => motor_l_direction,
	motor_r_reset => motor_r_reset,
	motor_r_direction => motor_r_direction
);

end architecture;