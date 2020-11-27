library IEEE;
-- Libraries I want to use:
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

-- entity test controller
entity test_controller is
	port (	clk      : in  std_logic;
		reset    : in  std_logic;
		count_in : in  std_logic_vector(20 downto 0);
		pwm_reset: out std_logic
	);
end entity test_controller;

-- behavioural architecture of test controller
architecture behavioural of test_controller is

type test_controller_state is (reset_state, wait_state);

signal state, new_state : test_controller_state;

begin
process(clk, reset)
begin
		if (rising_edge(clk)) then
			if (reset = '1') then
				state <= reset_state;
			else
				state <= new_state;
			end if;
		end if;
end process;

process(state, count_in)
begin 
	case state is
		when reset_state => 
			PWM_RESET <= '1';
			new_state <= wait_state;
		when wait_state =>
			PWM_RESET <= '0';
			if (unsigned(count_in) >= 2000000) then
				new_state <= reset_state;
			else
				new_state <= wait_state;
			end if;
	end case;
end process;

end architecture behavioural;
