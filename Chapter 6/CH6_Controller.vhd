library IEEE;
-- Libraries I want to use:
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

-- entity controller
entity CH5_controller is
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
		motor_r_direction	: out	std_logic
	);
end entity CH5_controller;

-- behavioural architecture of controller
architecture behavioural of CH5_controller is

type CH5_controller_state is (RESET_STATE, FORWARD, TURN_LEFT, SHARP_LEFT, TURN_RIGHT, SHARP_RIGHT);

signal state, new_state : Ch5_controller_state;

begin
process(clk, reset)
begin
		if (rising_edge(clk)) then
			if (reset = '1') then
				state <= RESET_STATE;
			else
				state <= new_state;
			end if;
		end if;
end process;

process(state, sensor_l, sensor_m, sensor_r, count_in)
begin 
	case state is
		when RESET_STATE => 
			count_reset <= '1';
			motor_l_reset <= '1';
			motor_r_reset <= '1';
			motor_l_direction <= '1';
			motor_r_direction <= '1';
			if (sensor_l = '0' and sensor_m = '1' and sensor_r = '1') then
				new_state <= TURN_LEFT;
				elsif (sensor_l = '0' and sensor_m = '0' and sensor_r = '1') then
						new_state <= SHARP_LEFT;
				elsif (sensor_l = '1' and sensor_m = '1' and sensor_r = '0') then
						new_state <= TURN_RIGHT;
				elsif (sensor_l = '1' and sensor_m = '0' and sensor_r = '0') then
						new_state <= SHARP_RIGHT;
				else
						new_state <= FORWARD;
				
				
				
			end if;
			
		
	
			
		when FORWARD =>
			count_reset <= '0';
			motor_l_reset <= '0';
			motor_r_reset <= '0';
			motor_l_direction <= '1';
			motor_r_direction <= '1';
			if (unsigned(count_in) >= 2000000) then
				new_state <= RESET_STATE;
			else
				new_state <= FORWARD;
			end if;
	

		when TURN_LEFT =>
			count_reset <= '0';
			motor_l_reset <= '1';
			motor_r_reset <= '0';
			motor_l_direction <= '1';
			motor_r_direction <= '1';
			if (unsigned(count_in) >= 2000000) then
				new_state <= RESET_STATE;
			else
				new_state <= TURN_LEFT;
			end if;
	
		when SHARP_LEFT =>
			count_reset <= '0';
			motor_l_reset <= '0';
			motor_r_reset <= '0';
			motor_l_direction <= '0';
			motor_r_direction <= '1';
			if (unsigned(count_in) >= 2000000) then
				new_state <= RESET_STATE;
			else
				new_state <= SHARP_LEFT;
			end if;
	
		when TURN_RIGHT =>
			count_reset <= '0';
			motor_l_reset <= '0';
			motor_r_reset <= '1';
			motor_l_direction <= '1';
			motor_r_direction <= '1';
			if (unsigned(count_in) >= 2000000) then
				new_state <= RESET_STATE;
			else
				new_state <= TURN_RIGHT;
			end if;
	
		when SHARP_RIGHT =>
			count_reset <= '0';
			motor_l_reset <= '0';
			motor_r_reset <= '0';
			motor_l_direction <= '1';
			motor_r_direction <= '0';
			if (unsigned(count_in) >= 2000000) then
				new_state <= RESET_STATE;
			else
				new_state <= TURN_RIGHT;
			end if;
	end case;




end process;

end architecture behavioural;
