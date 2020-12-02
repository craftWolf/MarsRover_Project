library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;


-- entity controller
entity Main_Controller is
	port (	clk			: in	std_logic;
		reset			: inout	std_logic;

		Line_found		: in	std_logic;

		count_in		: in	std_logic_vector (20 downto 0);
		count_reset		: out	std_logic;

		Select_Vector		: out	std_logic_vector (3 downto 0)
	);
end entity Main_Controller;

architecture behavioural of Main_Controller is

type Main_Controller_state is (Line_Finder, Line_Tracker); 	-- Define state type and list all states

signal state, new_state : Main_Controller_state;		-- intermediate signals
begin

process(clk, reset)						-- synchronise state assignment on clk
begin
		if (rising_edge(clk)) then
			if (reset = '1') then
				state <= Line_Finder;
				count_reset <= '1';
			else
				if (unsigned(count_in) >= 2000000) then
					count_reset <= '1';
					state 		<= new_state;
				else
					count_reset <= '0';
				end if;
			end if;
		end if;
end process;

process(state, line_found)					-- FSM
begin 


	case state is
	
		when Line_Finder =>
			Select_Vector <= "0000";
			if line_found = '1' then
				new_state <= Line_tracker;
			else 
				new_state <= Line_Finder;
			end if;

		when Line_Tracker =>
			Select_Vector <= "0001";
			if line_found <= '0' then
				new_state <= Line_Finder;
			else
				new_state <= Line_tracker;
			end if;
		
	end case;

end process;

end architecture behavioural;