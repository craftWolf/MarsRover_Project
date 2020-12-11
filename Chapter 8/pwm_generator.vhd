library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity pwm_generator is
	generic(
  		CLK_SCALE : INTEGER := 10000 -- Lower clock frequency by scale factor
  	);
	port ( 	clk 		: in STD_LOGIC;  -- clock signal
		reset 		: in STD_LOGIC;  -- reset signal
		direction 	: in STD_LOGIC;  -- '0' == left, '1' == right
		-- value of the counter
		count_in 	: in STD_LOGIC_VECTOR(20 downto 0);
		pwm 		: out STD_LOGIC); -- the PWM signal
end entity pwm_generator;

architecture behavioural of pwm_generator is
-- all existing states
type motor_controller_state is (PWM_LOW, PWM_HIGH, PWM_RESET);

-- Current and next state
signal state, new_state: motor_controller_state;

begin
	-- Each clock cycle update the state
	upd_state: process (clk, reset)
		begin
		if(rising_edge(clk)) then
			-- 
			if (reset = '0') then
				state <= new_state;
			else
				state <= PWM_RESET;
			end if;
		end if;
	end process;
	
	process(state, reset, direction, count_in) 
	begin
		case state is
			when PWM_HIGH=>
				-- The pwm signal should be 1 in this state
				pwm <= '1';

				-- Transition to PWM_LOW whenever the counter 
				-- reaches 1ms if direction is left (0)
				-- reaches 2ms if direction is right (1)
				if (direction = '0' and (unsigned(count_in)/CLK_SCALE > 100000/CLK_SCALE)) then
					new_state <= PWM_LOW;
				else 
					if (direction = '1' and (unsigned(count_in)/CLK_SCALE > 200000/CLK_SCALE)) then
						new_state <= PWM_LOW;
					else
						new_state <= PWM_HIGH;
				     	end if;
				end if;
				
			when PWM_LOW =>
				-- Stay in the low state
				pwm <= '0';
				new_state <= PWM_LOW;
			when PWM_RESET =>
				pwm <= '0';
				new_state <= PWM_HIGH;
			
		end case;
	end process;
end architecture behavioural;