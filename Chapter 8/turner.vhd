library IEEE;
-- Libraries I want to use:
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

-- entity controller
entity turner is
	generic(
  		CLK_SCALE : INTEGER := 10000 -- Lower clock frequency by scale factor
  	);
	port (	clk			: in	std_logic;
		reset			: in	std_logic; -- hard reset
	
		sensor_l		: in	std_logic;
		sensor_m		: in	std_logic;
		sensor_r		: in	std_logic;
		TurnType		: in 	std_logic_vector(1 downto 0);

		count_in		: in	std_logic_vector (20 downto 0);
		count_reset		: out	std_logic;

		motor_l_reset		: out	std_logic;
		motor_l_direction	: out	std_logic;

		motor_r_reset		: out	std_logic;
		motor_r_direction	: out	std_logic;
		
		turner_reset 		: in 	std_logic; -- reset coming from the main controller
		turn_complete		: out   std_logic
	);
end entity turner;

-- behavioural architecture of controller
architecture behavioural of turner is

type turner_controller_state is (RESET_STATE, TURN_COMPLETED, SHARP_RIGHT, SHARP_LEFT);

signal state, new_state : turner_controller_state;

begin
process(clk, reset)
begin
		if (rising_edge(clk)) then
			if (reset = '1' or turner_reset = '1') then
				state <= RESET_STATE;
			else
				state <= new_state;
			end if;
		end if;
end process;

process(state, sensor_l, sensor_m, sensor_r, clk)
begin 
turn_complete <= '0';
	case state is
	

		when RESET_STATE =>
			count_reset <= '1';
			motor_l_reset <= '1';
			motor_r_reset <= '1';
			motor_l_direction <= '1'; --irrelevant
			motor_r_direction <= '0'; --irrelevant
			
			if (sensor_l = '0' and sensor_m = '1' and sensor_r = '1' and TurnType = "01") then
				new_state <= TURN_COMPLETED;
			elsif (sensor_l = '1' and sensor_m = '1' and sensor_r = '0' and TurnType = "10") then
				new_state <= TURN_COMPLETED;
			elsif TurnType = "01" then
				new_state <= SHARP_RIGHT;
			else 
				new_state <= SHARP_LEFT;
			end if;
	
		when SHARP_RIGHT =>
			count_reset <= '0';
			motor_l_reset <= '0';
			motor_r_reset <= '0';
			motor_l_direction <= '1';
			motor_r_direction <= '0';
			
			if (unsigned(count_in) >= 2000000/CLK_SCALE) then
				new_state <= RESET_STATE;
			else
				new_state <= state;
			end if;

		when SHARP_LEFT =>
			count_reset <= '0';
			motor_l_reset <= '0';
			motor_r_reset <= '0';
			motor_l_direction <= '0';
			motor_r_direction <= '1';
			
			if (unsigned(count_in) >= 2000000/CLK_SCALE) then
				new_state <= RESET_STATE;
			else
				new_state <= state;
			end if;

		when TURN_COMPLETED =>
			count_reset <= '0';
			motor_l_reset <= '1';
			motor_r_reset <= '1';
			motor_l_direction <= '0';
			motor_r_direction <= '0';
			turn_complete <= '1';
			
	end case;




end process;

end architecture behavioural;
