
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.math_real.all;


entity system is
	port (	clk			: in	std_logic;
		reset			: in	std_logic;

		sensor_l		: in	std_logic;
		sensor_m		: in	std_logic;
		sensor_r		: in	std_logic;
		pwm_l			: out STD_LOGIC;
		pwm_r			: out std_logic -- the PWM signal
	);
end system;



architecture struct of system is

-- entity test controller
component simple_controller is
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
end component simple_controller;

component counter 
	port (	clk 		: in STD_LOGIC;
		reset		: in STD_LOGIC;
		count_out	: out STD_LOGIC_VECTOR(20 downto 0));
end component counter;	 

component pwm_generator 
	port ( 	clk 		: in STD_LOGIC;  -- clock signal
		reset 		: in STD_LOGIC;  -- reset signal
		direction 	: in STD_LOGIC;  -- '0' == left, '1' == right
		-- value of the counter
		count_in 	: in STD_LOGIC_VECTOR(20 downto 0);
		pwm 		: out STD_LOGIC); -- the PWM signal
end component pwm_generator;

signal int_count_in : std_logic_vector (20 downto 0);
signal int_count_reset : std_logic;
signal int_motor_l_reset , int_motor_l_direction : std_logic;
signal  int_motor_r_reset, int_motor_r_direction : std_logic;

begin


lbl1: simple_controller port map (	clk => clk, 
					reset => reset, 
					sensor_l => sensor_l, 
					sensor_m => sensor_m, 
					sensor_r => sensor_r,

					count_in => int_count_in,
					count_reset => int_count_reset,

					motor_l_reset => int_motor_l_reset,
					motor_l_direction => int_motor_l_direction,

					motor_r_reset => int_motor_r_reset,
					motor_r_direction => int_motor_r_direction);


lbl2: counter port map ( 	clk => clk,
				reset => int_count_reset,
				count_out => int_count_in);

lbl3: pwm_generator port map (	clk=>clk,
				reset=>int_motor_l_reset ,
				direction=>int_motor_l_direction,
				count_in=>int_count_in,
				pwm=>pwm_l);

lbl4: pwm_generator port map (	clk=>clk,
				reset=>int_motor_r_reset ,
				direction=>int_motor_r_direction,
				count_in=>int_count_in,
				pwm=>pwm_r);

end struct;