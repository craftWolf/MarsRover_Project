library IEEE;
-- Libraries I want to use:
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

-- entity controller
entity line_tracker is
	generic(
  		CLK_SCALE : INTEGER := 10000 -- Lower clock frequency by scale factor
  	);
	port (	clk			: in	std_logic;
		reset			: in	std_logic; -- hard reset
		line_tracker_reset 	: in 	std_logic; -- reset coming from the main controller

		sensor_l		: in	std_logic;
		sensor_m		: in	std_logic;
		sensor_r		: in	std_logic;

		count_in		: in	std_logic_vector (20 downto 0);
		count_reset		: out	std_logic;

		motor_l_reset		: out	std_logic;
		motor_l_direction	: out	std_logic;

		motor_r_reset		: out	std_logic;
		motor_r_direction	: out	std_logic;
		
		turn_type		: out   std_logic;
		turn_found		: out	std_logic
	);
end entity line_tracker;

-- behavioural architecture of controller
architecture behavioural of line_tracker is

type tracker_controller_state is (RESET_STATE, FORWARD, TURN_LEFT, SHARP_LEFT, TURN_RIGHT, SHARP_RIGHT, FOUND_TURN);

signal state, new_state : tracker_controller_state;
signal check: std_logic; --checks whether we have moveded on from the turn signal
signal int_turn_type: std_logic_vector(1 downto 0) := "00"; --keeps track of number of turn signals

begin
process(clk, reset, line_tracker_reset)
begin
		if (rising_edge(clk)) then
			if (reset = '1' or line_tracker_reset = '1') then
				state <= RESET_STATE;
                check <= '0';
			else
				state <= new_state;
			end if;
		end if;
end process;

process(state, sensor_l, sensor_m, sensor_r, count_in)
begin 

    turn_found <= '0';
	case state is
		when RESET_STATE => 
			count_reset <= '1';
			motor_l_reset <= '1';
			motor_r_reset <= '1';
			motor_l_direction <= '1';
			motor_r_direction <= '1';
            if (unsigned(count_in) >= 2000000/CLK_SCALE) then
                new_state <= RESET_STATE;
            else
                if (sensor_l = '0' and sensor_m = '1' and sensor_r = '0') then
                    if (check = '0') then
                        if (int_turn_type = "00") then
                            int_turn_type <= "01";
                            turn_type <= '0';
                        else 
                            int_turn_type <= "10";
                            turn_type <= '1';
                        end if;
                        check <= '1';
                    end if;
                    new_state <= FORWARD;
                else
                    check <= '0';
                    if (sensor_l = '0' and sensor_m = '0' and sensor_r = '1') then
                        new_state <= TURN_LEFT;
                    elsif (sensor_l = '0' and sensor_m = '1' and sensor_r = '1') then
                            new_state <= SHARP_LEFT;
                    elsif (sensor_l = '1' and sensor_m = '0' and sensor_r = '0') then
                            new_state <= TURN_RIGHT;
                    elsif (sensor_l = '1' and sensor_m = '1' and sensor_r = '0') then
                            new_state <= SHARP_RIGHT;
                    elsif (sensor_l = '0' and sensor_m = '0' and sensor_r = '0' and int_turn_type /= "00") then
                            new_state <= Found_Turn;
                    else
                            new_state <= FORWARD;				
                    end if;
                end if;
            end if;
			
		
	
			
		when FORWARD =>
			count_reset <= '0';
			motor_l_reset <= '0';
			motor_r_reset <= '0';
			motor_l_direction <= '1';
			motor_r_direction <= '1';
			if (unsigned(count_in) >= 2000000/CLK_SCALE) then
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
			if (unsigned(count_in) >= 2000000/CLK_SCALE) then
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
			if (unsigned(count_in) >= 2000000/CLK_SCALE) then
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
			if (unsigned(count_in) >= 2000000/CLK_SCALE) then
				new_state <= RESET_STATE;
			else
				new_state <= TURN_RIGHT;
			end if;
	
		when SHARP_RIGHT =>
			count_reset <= '0';
			motor_l_reset <= '0';
			motor_r_reset <= '0';
			motor_l_direction <= '1';	-- mirrored motor is implemented in Mars_rover
			motor_r_direction <= '0';
			if (unsigned(count_in) >= 2000000/CLK_SCALE) then
				new_state <= RESET_STATE;
			else
				new_state <= SHARP_RIGHT;
			end if;

		when FOUND_TURN =>
			motor_l_reset <= '1';
			motor_r_reset <= '1';
			motor_l_direction <= '1';
			motor_r_direction <= '1';
            check <= '0';
            int_turn_type <= "00";
			turn_found <= '1';
			new_state <= FOUND_TURN;
	end case;




end process;

end architecture behavioural;
