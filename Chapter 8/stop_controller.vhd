library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity stop_controller is
	generic(
  		CLK_SCALE : INTEGER := 10000 -- Lower clock frequency by scale factor
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
		
		stop_signal		: out	std_logic
	);
end entity stop_controller;

architecture behavioural of stop_controller is

type stop_controller_state is (IDLE_STATE, STOP_STATE, RESET_STATE);

signal state, new_state : stop_controller_state;
signal int_counter : std_logic_vector(7 downto 0);

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

  motor_l_reset <= '1';
  motor_r_reset <= '1';
  motor_l_direction <= '1';
  motor_r_direction <= '1';
  stop_signal <= '0';
	case state is
		when RESET_STATE =>
			int_counter <= (others => '0');
 			if (sensor_l = '1' and sensor_m = '1' and sensor_r = '1') then
				new_state <= IDLE_STATE;
			else
				new_state <= RESET_STATE;
			end if;

		when STOP_STATE =>
			stop_signal <= '1';
			count_reset <= '1';

		when IDLE_STATE =>
			if (sensor_l /= '1' or sensor_m /= '1' or sensor_r /= '1') then
				new_state <= RESET_STATE;
			else
				if (unsigned(count_in) >= 2000000/CLK_SCALE) then
					int_counter <= std_logic_vector(unsigned(int_counter) +1);
				end if;
				if (unsigned(int_counter) >= 150) then
					new_state <= STOP_STATE;
				else
					new_state <= IDLE_STATE;
				end if;
			end if;
	end case;
end process;
end architecture behavioural;
