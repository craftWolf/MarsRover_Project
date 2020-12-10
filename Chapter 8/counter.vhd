library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;


entity counter is
	port (	clk 		: in STD_LOGIC;
		reset		: in STD_LOGIC;
		count_out	: out STD_LOGIC_VECTOR(20 downto 0));
end counter;	 

architecture behavioural of counter is
signal count, new_count : STD_LOGIC_VECTOR(20 downto 0);
begin
regis : process (clk)
		begin
		-- On rising edge on clock reset the counter or load new value.
		if (rising_edge(clk)) then
			if (reset = '1') then
				count <= (others => '0');
			else
				count <= new_count;
			end if;
			count_out <= count;
		end if;
	end process;
-- Sensitivity list only contains count value. 
adder : process (count)
		begin	
		new_count <= std_logic_vector(unsigned(count) + 1);
	end process;
end behavioural;