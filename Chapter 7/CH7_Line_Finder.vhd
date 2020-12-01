library IEEE;
-- Libraries I want to use:
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

-- entity controller
entity CH7_Line_Finder is
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
		motor_r_direction	: out	std_logic;
		Line_found		: out	std_logic
	);
end entity CH7_Line_Finder;

-- behavioural architecture of controller
architecture behavioural of CH7_Line_finder is

type CH7_controller_state is (FIND_LINE, PASS_LINE, SHARP_LEFT, SHARP_RIGHT, FOUND_LINE);

signal state, new_state : CH7_controller_state;
signal last_input, new_last_input	: std_logic_vector(2 downto 0);

begin

process(clk, reset, sensor_l, sensor_m, sensor_r)
begin
		if (rising_edge(clk)) then
			if (reset = '1') then
				state <= FIND_LINE;
				last_input	<= "111";
				count_reset <= '1';
			else

				if (unsigned(count_in) >= 2000000) then
					count_reset <= '1';
					state 		<= new_state;
				else
					count_reset <= '0';
					if (sensor_l /= '1' or sensor_m /= '1' or sensor_r /= '1') then
						last_input	<= new_last_input;
					end if;
				end if;
				
				
			end if;
		end if;
end process;

process(state, sensor_l, sensor_m, sensor_r, count_in)
begin 
	line_found <=  '0';
	--count_reset <= '0';
	case state is
--		when RESET_STATE =>
--			motor_l_reset <= '1';
--			motor_r_reset <= '1';
--			motor_l_direction <= '0';
--			motor_r_direction <= '0';
--			new_state <= FIND_LINE;
			
			
		when FIND_LINE =>
			motor_l_reset <= '0';
			motor_r_reset <= '0';
			motor_l_direction <= '1';
			motor_r_direction <= '1';

			new_last_input(0) <= sensor_l;
			new_last_input(1) <= sensor_m;
			new_last_input(2) <= sensor_r;
			
			if (sensor_l = '1' and sensor_m = '1' and sensor_r = '1') then
				new_state <= FIND_LINE;
			elsif (sensor_l = '1' and sensor_m = '0' and sensor_r = '1') then
				new_state <= Found_line;
			else
				new_state <= PASS_LINE;
			end if;

		when PASS_LINE =>
			motor_l_reset <= '0';
			motor_r_reset <= '0';
			motor_l_direction <= '1';
			motor_r_direction <= '1';
			new_last_input(0) <= sensor_l;
			new_last_input(1) <= sensor_m;
			new_last_input(2) <= sensor_r;
			if (sensor_l /= '1' and sensor_m /= '1' and sensor_r /= '1') then
				new_state <= PASS_LINE;
			elsif (unsigned(last_input)= 6 or unsigned(last_input)=4) then
				new_state <= SHARP_RIGHT;
			else
				new_state <= SHARP_LEFT;				
			end if;
	


		when SHARP_LEFT =>
			motor_l_reset <= '0';
			motor_r_reset <= '0';
			motor_l_direction <= '0';
			motor_r_direction <= '1';

			new_last_input(0) <= sensor_l;
			new_last_input(1) <= sensor_m;
			new_last_input(2) <= sensor_r;

			if (sensor_l = '1' and sensor_m = '1' and sensor_r = '1') then
				new_state <= SHARP_LEFT;
			else 
				new_state <= Found_line;
			end if;
	
	
		when SHARP_RIGHT =>
			motor_l_reset <= '0';
			motor_r_reset <= '0';
			motor_l_direction <= '1';
			motor_r_direction <= '0';
			new_last_input(0) <= sensor_l;
			new_last_input(1) <= sensor_m;
			new_last_input(2) <= sensor_r;

			if (sensor_l = '1' and sensor_m = '1' and sensor_r = '1') then
				new_state <= SHARP_RIGHT;
			else 
				new_state <= Find_line;
			end if;

		when FOUND_LINE =>
			motor_l_reset <= '1';
			motor_r_reset <= '1';
			motor_l_direction <= '0';
			motor_r_direction <= '0';
			line_found	<= '1';
			if (sensor_l = '1' and sensor_m = '1' and sensor_r = '1') then
				new_state	<= FIND_LINE;
			else
				new_state	<= FOUND_LINE;
			end if;
	end case;




end process;

end architecture behavioural;
