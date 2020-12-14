library IEEE;
-- Libraries I want to use:
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

-- entity controller
entity right_shortcut is
	generic(
  		CLK_SCALE : INTEGER := 1 -- Lower clock frequency by scale factor
  	);
	port (	clk			: in	std_logic;
		reset			: in	std_logic; -- hard reset

		sensor_l		: in	std_logic;
		sensor_m		: in	std_logic;
		sensor_r		: in	std_logic;

		count_in		: in	std_logic_vector (20 downto 0);
		count_reset		: out	std_logic;

		motor_l_reset		: out	std_logic;
		motor_l_direction	: out	std_logic;

		motor_r_reset		: out	std_logic;
		motor_r_direction	: out	std_logic;
		
		right_shortcut_reset 		: in 	std_logic; -- reset coming from the main controller
		right_shortcut_signal		: out std_logic
	);
end entity right_shortcut;

-- behavioural architecture of controller
architecture behavioural of right_shortcut is

type tracker_controller_state is (IDLE_STATE, PREP_STATE, SHARP_RIGHT);

signal state, new_state : tracker_controller_state;

begin
process(clk, reset)
begin
		if (rising_edge(clk)) then
			if (reset = '1' or right_shortcut_reset = '1') then
				state <= IDLE_STATE;
			else
				state <= new_state;
			end if;
		end if;
end process;

process(state, sensor_l, sensor_m, sensor_r)
begin 
	case state is
		when IDLE_STATE => 
			count_reset <= '1';  -- can be Ignored, invert of sharp_right
			motor_l_reset <= '1'; -- can be Ignored, invert of sharp_right
			motor_r_reset <= '1'; -- can be Ignored, invert of sharp_right
			motor_l_direction <= '0'; -- can be Ignored, invert of sharp_right
			motor_r_direction <= '1'; -- can be Ignored, invert of sharp_right
			right_shortcut_signal <= '0'; -- Important
			if (sensor_l = '0' and sensor_m = '1' and sensor_r = '0') then
				new_state <= PREP_STATE;
			else
				new_state <= state;
			end if;
		
		when PREP_STATE => 
			count_reset <= '1';  -- can be Ignored, invert of sharp_right
			motor_l_reset <= '1'; -- can be Ignored, invert of sharp_right
			motor_r_reset <= '1'; -- can be Ignored, invert of sharp_right
			motor_l_direction <= '0'; -- can be Ignored, invert of sharp_right
			motor_r_direction <= '1'; -- can be Ignored, invert of sharp_right
			right_shortcut_signal <= '0'; -- Important
			if (sensor_l = '0' and sensor_m = '0' and sensor_r = '0') then
				new_state <= SHARP_RIGHT;
			else
				new_state <= state;
			end if;
	
		when SHARP_RIGHT =>
			count_reset <= '0';
			motor_l_reset <= '0';
			motor_r_reset <= '0';
			motor_l_direction <= '1';
			motor_r_direction <= '0';
			right_shortcut_signal <= '1'; -- Important
			if (unsigned(count_in) >= 2000000) then
				new_state <= IDLE_STATE;
			else
				new_state <= state;
			end if;
	end case;




end process;

end architecture behavioural;
