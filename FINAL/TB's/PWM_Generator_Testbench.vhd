library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.math_real.all;

library FLOATFIXLIB;
use FLOATFIXLIB.fixed_pkg.to_sfixed;

entity PWM_test is
end PWM_Test;

architecture structural of PWM_test is


		component pwm_generator is
			
			port ( 	clk 		: in STD_LOGIC;  -- clock signal
				reset 		: in STD_LOGIC;  -- reset signal
				direction 	: in STD_LOGIC;  -- '0' == left, '1' == right
						-- value of the counter
				count_in 	: in STD_LOGIC_VECTOR(20 downto 0);
				pwm 		: out STD_LOGIC); -- the PWM signal
		end component pwm_generator;

		signal clk		: std_logic;
		signal reset		: std_logic;	
		signal direction	: std_logic;
		signal count_in		: std_logic_vector(20 downto 0);
		signal pwm		: std_logic;
		


begin



	clk		<= 	'1' after 0 ns,
				'0' after 10 ns when clk /= '0' else '1' after 10 ns; -- generate the 100MHZ clock
	reset		<= 	'0' after 0 ns, --test reset at different values
				'1' after 17 ns,
				'0' after 30 ns,
				'1' after 100 ns,
				'0' after 120 ns;
	direction	<=	'0' after 0 ns,
				'1' after 100 ns,
				'0' after 200 ns;
	count_in	<=	std_logic_vector(to_unsigned(0, count_in'length))		after 0 ns,
				std_logic_vector(to_unsigned(100001, count_in'length))		after 50 ns,
				std_logic_vector(to_unsigned(0, count_in'length))		after 100 ns,
				std_logic_vector(to_unsigned(200001, count_in'length))		after 150 ns;

lbl: pwm_generator port map( clk => clk, reset => reset, direction => direction, count_in => count_in, pwm => pwm);


end architecture structural;
