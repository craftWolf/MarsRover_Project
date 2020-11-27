library IEEE;
-- Libraries I want to use:
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

-- entity test controller
entity simple_controller is
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
end entity simple_controller;

-- behavioural architecture of simple controller
architecture behavioural of simple_controller is

type simple_controller_state is (MAP_STATE, DRIVE_STATE);

signal state, new_state : simple_controller_state;

begin
process(clk, reset)
begin
		if (rising_edge(clk)) then
			if (reset = '1') then
				state <= MAP_STATE;
			else
				state <= new_state;
			end if;
		end if;
end process;

process(state, sensor_l, sensor_m, sensor_r, count_in)
begin 
	case state is
		when MAP_STATE => 
			count_reset <= '1';
			motor_l_reset <= '1';
			motor_r_reset <= '1';
			motor_l_direction <= '1';
			motor_r_direction <= '1';
			if (sensor_l = '1' and sensor_m = '0' and sensor_r = '1') then
				new_state <= DRIVE_STATE;
			else
				new_state <= MAP_STATE;
			end if;
		when DRIVE_STATE =>
			count_reset <= '0';
			motor_l_reset <= '0';
			motor_r_reset <= '0';
			motor_l_direction <= '1';
			motor_r_direction <= '1';
			if (unsigned(count_in) >= 2000000) then
				new_state <= MAP_STATE;
			else
				new_state <= DRIVE_STATE;
			end if;
	end case;
end process;

end architecture behavioural;
