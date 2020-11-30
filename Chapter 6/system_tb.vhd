library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.math_real.all;

entity system_tb is
end system_tb;

architecture struct of system_tb is

-- entity test controller
component system is
	port (	clk			: in	std_logic;
		reset			: in	std_logic;

		sensor_l		: in	std_logic;
		sensor_m		: in	std_logic;
		sensor_r		: in	std_logic;
		pwm_l			: out STD_LOGIC;
		pwm_r			: out std_logic -- the PWM signal
	);
end component system;


signal CLK_100MHZ : std_logic:='0';
signal reset : std_logic;
signal sensor_l , sensor_m, sensor_r : std_logic;
signal pwm_l, pwm_r : std_logic;

begin

  CLK_100MHZ <= not CLK_100MHZ after 5 ns;

  reset <= '1' after 0 ns, '0' after 10 ns;
  sensor_l <= '1' after 0 ns, '0' after 30 ms;
  sensor_m <= '0' after 0 ns, '1' after 30 ms;
  sensor_r <= '1' after 0 ns, '0' after 30 ms;

  lbl1: system port map (clk => CLK_100MHZ, 
				reset => reset, 
				sensor_l => sensor_l, 
				sensor_m => sensor_m, 
				sensor_r =>sensor_r, 
				pwm_l =>pwm_l, 
				pwm_r=>pwm_r);

end struct;