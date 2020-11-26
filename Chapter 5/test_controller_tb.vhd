library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;


entity test_controller_tb is
end test_controller_tb;

architecture mixed of test_controller_tb is
	component test_controller 
		port (	clk      : in  std_logic;
			reset    : in  std_logic;
			count_in : in  std_logic_vector(20 downto 0);
			pwm_reset: out std_logic
		);
	end component;

signal clk		: std_logic;
signal reset		: std_logic;
signal count_in		: std_logic_vector(20 downto 0);
signal pwm_reset	: std_logic;

begin

	clk		<= 	'1' after 0 ns,
				'0' after 10 ns when clk /= '0' else '1' after 10 ns; -- generate the 100MHZ clock
	reset		<= 	'0' after 0 ns, --test reset at different values
				'1' after 17 ns,
				'0' after 30 ns;
	count_in	<=	std_logic_vector(to_unsigned(0, count_in'length))		after 0 ns,
				std_logic_vector(to_unsigned(1000001, count_in'length))		after 50 ns,
				std_logic_vector(to_unsigned(1500000, count_in'length))		after 100 ns,
				std_logic_vector(to_unsigned(2000001, count_in'length))		after 150 ns,
				std_logic_vector(to_unsigned(0, count_in'length))		after 160 ns,
				std_logic_vector(to_unsigned(1000001, count_in'length))		after 250 ns,
				std_logic_vector(to_unsigned(1500000, count_in'length))		after 300 ns,
				std_logic_vector(to_unsigned(2000001, count_in'length))		after 400 ns,
				std_logic_vector(to_unsigned(0, count_in'length))		after 420 ns;

lbl: test_controller port map (clk => clk, reset => reset, count_in => count_in, pwm_reset => pwm_reset);

end architecture mixed;
