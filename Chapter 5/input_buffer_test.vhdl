library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity input_buffer_tb is
end input_buffer_tb;

architecture mixed of input_buffer_tb is
component input_buffer is
	port (	clk		: in	std_logic;

		sensor_l_in	: in	std_logic;
		sensor_m_in	: in	std_logic;
		sensor_r_in	: in	std_logic;

		sensor_l_out	: out	std_logic;
		sensor_m_out	: out	std_logic;
		sensor_r_out	: out	std_logic
	);
end component input_buffer;

signal CLK_100MHZ : STD_LOGIC;
signal sensor_l_test, sensor_m_test, sensor_r_test : STD_LOGIC;
signal res1, res2, res3 : STD_LOGIC;

begin
clk_process_100: process
			begin
				CLK_100MHZ <= '0';
				wait for 5 ns;
				CLK_100MHZ <= '1';
				wait for 5 ns;
		end process;

sensor_test_l : process
			begin
				sensor_l_test <= '0';
				wait for 12 ns;
				sensor_l_test <= '1';
				wait for 9 ns;
				sensor_l_test <= '0';
				wait for 3 ns;
				sensor_l_test <= '1';
				wait for 15 ns;
				sensor_l_test <= '0';
				wait for 10 ns;
				sensor_l_test <= '1';
		end process;

sensor_test_m : process
			begin
				sensor_m_test <= '1';
				wait for 18 ns;
				sensor_m_test <= '0';
				wait for 13 ns;
				sensor_m_test <= '1';
				wait for 8 ns;
				sensor_m_test <= '0';
				wait for 14 ns;
				sensor_m_test <= '1';
				wait for 5 ns;
				sensor_m_test <= '0';
				wait for 13 ns;
		end process;

sensor_test_r : process
			begin
				sensor_r_test <= '1';
				wait for 10 ns;
				sensor_r_test <= '0';
				wait for 6 ns;
				sensor_r_test <= '1';
				wait for 18 ns;
				sensor_r_test <= '0';
				wait for 16 ns;
				sensor_r_test <= '1';
				wait for 3 ns;
				sensor_r_test <= '0';
				wait for 11 ns;
		end process;

under_test : input_buffer port map ( clk => CLK_100MHZ, sensor_l_in => sensor_l_test, sensor_m_in => sensor_m_test, sensor_r_in => sensor_r_test,
				     sensor_l_out => res1, sensor_m_out => res2, sensor_r_out => res3);

end mixed;

