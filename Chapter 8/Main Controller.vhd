library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;


-- entity controller
entity Main_Controller is
	port (	clk			: in	std_logic;
		reset			: in	std_logic;
		line_found		: in	std_logic;
		line_finder_reset 	: out 	std_logic;	-- Used to reset the line finder
		line_tracker_reset 	: out   std_logic;      -- Used to reset the line tracker, 
								-- also used when switching from finding to tracking
		sel			: out std_logic
	);
end entity Main_Controller;

architecture behavioural of Main_Controller is

type Main_Controller_state is (Line_Finder, Line_Tracker, Reset_state); 	-- Define state type and list all states

signal state, new_state : Main_Controller_state;		-- intermediate signals
begin

process(clk, reset)						-- synchronise state assignment on clk
begin
		if (rising_edge(clk)) then
			if (reset = '1') then
				state <= Reset_state;
			else
				state <= new_state;
			end if;
		end if;
end process;

process(state, line_found)					-- FSM
begin 
	case state is
		when Reset_state =>
			line_finder_reset <= '1';
			line_tracker_reset <= '1';
		 	sel <= '0';
			new_state <= Line_Finder;
	
		when Line_Finder =>
			line_finder_reset <= '0';
			line_tracker_reset <= '1';
			sel <= '0';
			-- Switch state when the line is found and 
			--- reset the line_tracker to make sure they are synced
			if line_found = '1' then
				new_state <= Line_Tracker;
			else 
				new_state <= Line_Finder;
			end if;
		when Line_Tracker =>
			line_finder_reset <= '1';
			line_tracker_reset <= '0';
			sel <= '1';
			new_state <= Line_Tracker;
	end case;

end process;

end architecture behavioural;