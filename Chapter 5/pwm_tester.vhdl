library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.math_real.all;

entity pwm_tester is
	port (	clk 		: in std_logic;
		reset 		: in std_logic;
		direction 	: in std_logic;
		pwm 		: out std_logic);
end pwm_tester;

architecture structural of pwm_tester is
component pwm_generator is
	port ( 	clk 		: in STD_LOGIC;  -- clock signal
		reset 		: in STD_LOGIC;  -- reset signal
		direction 	: in STD_LOGIC;  -- '0' == left, '1' == right
		-- value of the counter
		count_in 	: in STD_LOGIC_VECTOR(20 downto 0);
		pwm 		: out STD_LOGIC); -- the PWM signal
end component;

component test_controller is
	port (	clk      : in  std_logic;
		reset    : in  std_logic;
		count_in : in  std_logic_vector(20 downto 0);
		pwm_reset: out std_logic
	);
end component;

component counter is
	port (	clk 		: in STD_LOGIC;
		reset		: in STD_LOGIC;
		count_out	: out STD_LOGIC_VECTOR(20 downto 0));
end component;	


signal pwm_reset : std_logic;
signal count_out : STD_LOGIC_VECTOR(20 downto 0);

begin

controller 	: test_controller port map (clk => clk, reset => reset, count_in => count_out, pwm_reset => pwm_reset);

count		: counter port map (clk => clk, reset => pwm_reset, count_out => count_out);

pwm_gen 	: pwm_generator port map( clk => clk, reset => pwm_reset, direction => direction, count_in => count_out, pwm => pwm);


end architecture structural;
		