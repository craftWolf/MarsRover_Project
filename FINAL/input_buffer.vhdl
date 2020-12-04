library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

-- Entity of the 3 bit register
entity bitRegister is
 	port ( 	 clk, input1, input2, input3	: in STD_LOGIC;
		output1, output2, output3: out STD_LOGIC);
end bitRegister;

-- Behavioural architecture of 3 bit register
-- Very similar to D-flipflop however without reset signal and instead of 1 input/ output, 3 input/output.
architecture behavioural of bitRegister is
begin
bitreg : process(clk)
		begin
		if (rising_edge(clk)) then
			output1 <= input1;
			output2 <= input2;
			output3 <= input3;
		end if;
	end process;
end architecture behavioural;


library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

-- Entity of input_buffer
entity input_buffer is
	port (	clk		: in	STD_LOGIC;

		sensor_l_in	: in	STD_LOGIC;
		sensor_m_in	: in	STD_LOGIC;
		sensor_r_in	: in	STD_LOGIC;

		sensor_l_out	: out	STD_LOGIC;
		sensor_m_out	: out	STD_LOGIC;
		sensor_r_out	: out	STD_LOGIC
	);
end entity input_buffer;

-- Structural architecture
architecture structural of input_buffer is
component bitRegister is
 	port ( 	clk, input1, input2, input3 	: in STD_LOGIC;
		output1, output2, output3: out STD_LOGIC);
end component bitRegister;

-- Intermediate signals used for output of first bit register
signal inter_sensor_l, inter_sensor_m, inter_sensor_r : STD_LOGIC;

begin
bitreg3_1 : bitRegister port map ( 	clk 	=> clk,
					input1	=> sensor_l_in,
					input2 	=> sensor_m_in,
					input3 	=> sensor_r_in,
					output1 => inter_sensor_l,
					output2 => inter_sensor_m,
					output3 => inter_sensor_r);
bitreg3_2 : bitRegister port map ( 	clk 	=> clk,
					input1	=> inter_sensor_l,
					input2 	=> inter_sensor_m,
					input3 	=> inter_sensor_r,
					output1 => sensor_l_out,
					output2 => sensor_m_out,
					output3 => sensor_r_out);
end architecture structural;
				
					
	
		