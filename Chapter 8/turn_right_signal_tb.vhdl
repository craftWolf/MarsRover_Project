-- ################################################
--
--        TESTBENCH FOR TURN RIGHT SIGNAL
--         EE3130TU (Mars Rover Project)
--
-- ################################################


library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity turn_right_signal_tb is
end entity turn_right_signal_tb;

architecture testbench of turn_right_signal_tb is

	-- Controller component
	component controller_wrapper is
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
	end component controller_wrapper;

	-- Clock and reset signals
	signal clk, reset : std_logic := '0';
	-- Clock period
	constant period : time := 10 ns;

	-- Sensor signals (l, m, r)
	signal sensor_data : std_logic_vector(2 downto 0);
	-- Type and signal for encoding the sensor signals
	type sensors_type is (bbb, bbw, bwb, wbb, bww, wbw, wwb, www);
	signal sensors : sensors_type;

	-- Signals from counter
	signal count_in : std_logic_vector(20 downto 0) := (others => '0');
	signal count_reset : std_logic;
	-- Counter constants (reset to zero and large value to trigger transition to reset state)
	-- Assumption: PWM period has been tested and state transitions are triggered on counter value >= 2000000 (at least, should strictly speaking be earlier)
	constant count_zero : std_logic_vector(20 downto 0) := (others => '0');
	constant count_trig : std_logic_vector(20 downto 0) := std_logic_vector(to_unsigned(2000000, count_in'LENGTH));

	-- Motor signals (res_l, dir_l, res_r, dir_r)
	signal motor_data : std_logic_vector(3 downto 0);
	-- Type and signal for decoding the motor signals
	type motors_type is (idle, forward, turn_left, turn_right, turn_left_sharp, turn_right_sharp, backward, turn_left_backward, turn_right_backward); 
	signal motors : motors_type;
	-- Correction for motor control: direction (and maybe reset) can have opposite values
	signal motor_correction : std_logic_vector(3 downto 0) := (others => '0');
	signal motor_corrected : std_logic_vector(3 downto 0);
	
	-- Procedure that clocks the controller until signal_a = constant_b
	-- Will result in failure if condition is not met within max_delay clock cycles
	procedure CLOCK_UNTIL (
		signal signal_a : in std_logic;
		constant constant_b : in std_logic) is
		
		variable delay : integer := 0;
		constant max_delay : integer := 10;
	begin
		while signal_a /= constant_b loop
			wait for period;
			delay := delay + 1;
			assert delay <= max_delay report "ERROR: CLOCK_UNTIL delay limit reached" severity failure;
		end loop;
	end CLOCK_UNTIL;
	
	-- Procedure to simulate counter reaching value which should cause a 'reset' (back to a central state)
	procedure COUNTER_TRIGGER (
		signal count_val : out std_logic_vector(20 downto 0);
		signal count_rst : in std_logic) is
	begin
		-- Trigger state transition to reset state with counter value
		count_val <= count_trig;
		-- Clock the controller until reset
		CLOCK_UNTIL(count_rst, '1');
		-- Restore counter input since there is a reset signal (NOTE: this would normally happen one cycle later if the counter's reset is synchronous!)
		count_val <= count_zero;
	end COUNTER_TRIGGER;

begin

-- Device under test
DUT: controller_wrapper port map(
	clk => clk,
	reset => reset,
	sensor_l => sensor_data(2),
	sensor_m => sensor_data(1),
	sensor_r => sensor_data(0),
	count_in => count_in,
	count_reset => count_reset,
	motor_l_reset => motor_data(3),
	motor_l_direction => motor_data(2),
	motor_r_reset => motor_data(1),
	motor_r_direction => motor_data(0)
);

-- Motor decoder
motor_corrected <= motor_data xor motor_correction;
with motor_corrected select motors <=
	forward when "0101",
	turn_left when "1001" | "1101",
	turn_right when "0110" | "0111",
	turn_left_sharp when "0001",
	turn_right_sharp when "0100",
	backward when "0000",
	turn_left_backward when "0010" | "0011",
	turn_right_backward when "1000" | "1100",
	idle when others;

-- Sensor encoder
with sensors select sensor_data <=
	"000" when bbb,
	"001" when bbw,
	"010" when bwb,
	"011" when bww,
	"100" when wbb,
	"101" when wbw,
	"110" when wwb,
	"111" when www;
	
-- Clock signal
clk <= not clk after period/2; -- Rising edge at 5 ns, 15 ns, 25 ns, etc.
-- Doing the clock signal like this allows us to step the time with single period steps and always we end up on the falling edges where we can set/read signals.
-- If we set/read signals on the rising edge of the clock, there is some ambiguity about when signals change (e.g. in case of a counter: has the value increased yet?)
	
-- Testbench process
-- Structure:
	-- Task
	-- Assumption(s)/expectation
		-- Set inputs
		-- Clock controller
		-- Verify outputs
		-- Restore inputs (optional)
		-- (repeat)
tb: process is
	-- Variables to determine controller behaviour
	variable response : motors_type := idle;
	constant max_iterations : integer := 50;
	variable iterations : integer range 0 to max_iterations;
begin
	-- Reset the controller
	-- Assumption: controller goes to reset state where counter and motor drivers are reset (only state where this happens)
		-- Set reset value
		reset <= '1';
		-- Clock the controller
		wait for period;
		-- Verify output signals
		assert count_reset = '1' report "ERROR: Counter not reset in reset state" severity error;
		assert motors = idle report "ERROR: Motors not idle in reset state" severity error;
		-- Reset reset value
		reset <= '0';
		
	-- Apply the beginning WBW pattern and detect forward driving (detect the forward definition of the controller since one of the direction signals should be flipped but this can be done inside or outside the controller...)
	-- Assumption: controller goes to forward driving state
		-- Set sensor value
		sensors <= wbw;
		-- Clock the controller until the counter reset equals 0
		-- (Might take some time since there is also a line finder which must realise that the line has been found, must get from reset state to 'central state' (reference terminology))
		CLOCK_UNTIL(count_reset, '0');
		
		-- Here, we would like to check if the robot is moving forward, but the motor correction has not been applied yet. Therefore, we will set the correction now.
		motor_correction <= "0101" xor motor_data;
		
		-- Trigger state transition to reset state with counter value
		COUNTER_TRIGGER(count_in, count_reset);
	
	-- Apply the WBW pattern and detect forward driving
	-- Assumption: controller goes to forward driving state
		-- Set sensor value
		sensors <= wbw;
		-- Clock the controller until the counter reset equals 0
		-- (Might take some time since there is also a line finder which must realise that the line has been found, must get from reset state to 'central state' (reference terminology))
		CLOCK_UNTIL(count_reset, '0');
		
		-- Check if motor settings are correct
		assert motors = forward report "ERROR: Not driving forward on WBW" severity error;
		
		-- Trigger state transition to reset state with counter value
		COUNTER_TRIGGER(count_in, count_reset);
	
	-- Apply the BWB pattern and detect forward driving
	-- Assumption: the controller stores the information about the BWB pattern, but does not act yet
		-- Set sensor value
		sensors <= bwb;
		-- Clock the controller
		CLOCK_UNTIL(count_reset, '0');
		-- Check if motor settings are correct
		assert motors = forward report "ERROR: Not driving forward on BWB" severity error;
		
		-- Trigger state transition to reset state with counter value
		COUNTER_TRIGGER(count_in, count_reset);
	
	-- Apply WBW pattern again and detect forward driving
	-- Assumption: the controller has stored the previous BWB pattern somewhere and is now waiting for the BBB that indicates the crossing so it should not act on a WBW
		-- Set sensor value
		sensors <= wbw;
		-- Clock the controller
		CLOCK_UNTIL(count_reset, '0');
		-- Check if motor settings are correct
		assert motors = forward report "ERROR: Not driving forward on WBW after BWB" severity error;
		
		-- Trigger state transition to reset state with counter value
		COUNTER_TRIGGER(count_in, count_reset);
	
	-- Apply WBB pattern to see if the line follower still functions
	-- Assumption: the controller still works in the line follower and the WBB pattern will trigger a turn right action to get back on the line (same direction as turn signal)
		-- Set sensor value
		sensors <= wbb;
		-- Clock the controller
		CLOCK_UNTIL(count_reset, '0');
		-- Check if motor settings are correct
		assert motors = turn_right report "ERROR: Not steering right on WBB after BWB" severity error;
		
		-- Trigger state transition to reset state with counter value
		COUNTER_TRIGGER(count_in, count_reset);
	
	-- Apply BBW pattern to see if the line follower still functions
	-- Assumption: the controller still works in the line follower and the BBW pattern will trigger a turn left action to get back on the line (opposite direction of turn signal)
		-- Set sensor value
		sensors <= bbw;
		-- Clock the controller
		CLOCK_UNTIL(count_reset, '0');
		-- Check if motor settings are correct
		assert motors = turn_left report "ERROR: Not steering left on BBW after BWB" severity error;
		
		-- Trigger state transition to reset state with counter value
		COUNTER_TRIGGER(count_in, count_reset);
	
	-- Apply WBW pattern again and detect forward driving
	-- Assumption: the controller has stored the previous BWB pattern somewhere and is now waiting for the BBB that indicates the crossing so it should not act on a WBW
		-- Set sensor value
		sensors <= wbw;
		-- Clock the controller
		CLOCK_UNTIL(count_reset, '0');
		-- Check if motor settings are correct
		assert motors = forward report "ERROR: Not driving forward on WBW after BWB" severity error;
		
		-- Trigger state transition to reset state with counter value
		COUNTER_TRIGGER(count_in, count_reset);
	
	-- Apply BBB pattern to trigger the right turning
	-- Assumption: the controller knows it should turn right now. Since this is possible in many ways, we will not check it here yet.
		-- Set sensor value
		sensors <= bbb;
		-- Clock the controller
		CLOCK_UNTIL(count_reset, '0');
		-- Check if motor settings are correct
		-- Check the response to a BBB pattern, will consider 3 cases: (others possible, but can better be verified using a complete system simulation)
			-- Keep driving forward: intentionally cause a slight overshoot to prevent turning too early and then using one of the strategies below
			-- Turn right: slow turn to overshoot the crossing until WWW and then find it using a (sharp) right turn (reference behaviour)
			-- Turn sharp right: rotate before crossing until WWW and then use line finder
		response := motors;
		
		-- Trigger state transition to reset state with counter value
		COUNTER_TRIGGER(count_in, count_reset);
		
	if (response = forward or response = turn_right or response = turn_right_sharp) then
	
		-- If the implemented behaviour on the crossing includes a short forward driving segment, we can process it here
		-- Assumption: the controller will soon start rotating to the right in no more that max_iterations PWM cycles, otherwise it is not turning -> no turning implemented
			while (iterations < max_iterations and response = forward) loop
				-- Apply WBW to simulate a overshoot
				-- Assumption: the controller will soon start rotating to the right
					-- Set sensor value
					sensors <= wbw;
					-- Clock the controller
					CLOCK_UNTIL(count_reset, '0');
					-- Store motor settings
					response := motors;
					
					-- Trigger state transition to reset state with counter value
					COUNTER_TRIGGER(count_in, count_reset);
				
				iterations := iterations + 1;
			end loop;
			
			if (iterations /= 0) then
				report "NOTE: It took " & integer'image(iterations) & " cycles to start turning" severity note;
			end if;
	
		-- Process the rotating behaviour
			-- Turn right (or turn sharp right with a delay): will have an overshoot, sensors will approach the crossing line from 'above'
			-- Turn sharp right without delay: will not have an overshoot, sensors will approach the crossing line from 'below' (will not consider for now)
		if (response = turn_right or (response = turn_right_sharp and iterations /= 0)) then
			-- Test pattern used (with expected behaviour):
				-- WBW (overshoot, turn right)
				-- BBW (turn right)
				-- BWW (turn right)
				-- WWW (turn right)
				-- WWB (turn right)
				-- WBB (turn right)
				-- WBW (should go back to forward)
			
			-- Apply WBW to simulate a overshoot
			-- Assumption: the controller will keep rotating to the right
				-- Set sensor value
				sensors <= wbw;
				-- Clock the controller
				CLOCK_UNTIL(count_reset, '0');
				-- Check if motor settings are correct
				assert motors = turn_right or motors = turn_right_sharp report "ERROR: Controller stopped turning on WBW when just started" severity error;
				
				-- Trigger state transition to reset state with counter value
				COUNTER_TRIGGER(count_in, count_reset);
			
			-- Apply BBW to see if the controller still rotates right
			-- Assumption: the controller will keep rotating to the right
				-- Set sensor value
				sensors <= bbw;
				-- Clock the controller
				CLOCK_UNTIL(count_reset, '0');
				-- Check if motor settings are correct
				assert motors = turn_right or motors = turn_right_sharp report "ERROR: Controller stopped turning on BBW" severity error;
				
				-- Trigger state transition to reset state with counter value
				COUNTER_TRIGGER(count_in, count_reset);
			
			-- Apply BWW to see if the controller still rotates right
			-- Assumption: the controller will keep rotating to the right
				-- Set sensor value
				sensors <= bww;
				-- Clock the controller
				CLOCK_UNTIL(count_reset, '0');
				-- Check if motor settings are correct
				assert motors = turn_right or motors = turn_right_sharp report "ERROR: Controller stopped turning on BWW" severity error;
				
				-- Trigger state transition to reset state with counter value
				COUNTER_TRIGGER(count_in, count_reset);
			
			-- Apply WWW to see if the controller still rotates right
			-- Assumption: the controller will keep rotating to the right
				-- Set sensor value
				sensors <= www;
				-- Clock the controller
				CLOCK_UNTIL(count_reset, '0');
				-- Check if motor settings are correct
				assert motors = turn_right or motors = turn_right_sharp report "ERROR: Controller stopped turning on WWW" severity error;
				
				-- Trigger state transition to reset state with counter value
				COUNTER_TRIGGER(count_in, count_reset);
			
			-- Apply WWB to see if the controller still rotates right
			-- Assumption: the controller will keep rotating to the right
				-- Set sensor value
				sensors <= wwb;
				-- Clock the controller
				CLOCK_UNTIL(count_reset, '0');
				-- Check if motor settings are correct
				assert motors = turn_right or motors = turn_right_sharp report "ERROR: Controller stopped turning on WWB" severity error;
				
				-- Trigger state transition to reset state with counter value
				COUNTER_TRIGGER(count_in, count_reset);
			
			-- Apply WBB to see if the controller still rotates right
			-- Assumption: the controller will keep rotating to the right
				-- Set sensor value
				sensors <= wbb;
				-- Clock the controller
				CLOCK_UNTIL(count_reset, '0');
				-- Check if motor settings are correct
				assert motors = turn_right or motors = turn_right_sharp report "ERROR: Controller stopped turning on WBB" severity error;
				
				-- Trigger state transition to reset state with counter value
				COUNTER_TRIGGER(count_in, count_reset);
			
			-- Apply WBW to see if the controller stops rotating
			-- Assumption: the controller will stop rotating to the right
				-- Set sensor value
				sensors <= wbw;
				-- Clock the controller
				CLOCK_UNTIL(count_reset, '0');
				-- Check if motor settings are correct
				assert motors = forward report "ERROR: Controller doesn't go forward on WBW" severity error;
				
				-- Trigger state transition to reset state with counter value
				COUNTER_TRIGGER(count_in, count_reset);
				
			-- Apply WBB pattern to see if the line follower still functions
			-- Assumption: the controller still works in the line follower and the WBB pattern will trigger a turn right action to get back on the line (same direction as turn signal)
				-- Set sensor value
				sensors <= wbb;
				-- Clock the controller
				CLOCK_UNTIL(count_reset, '0');
				-- Check if motor settings are correct
				assert motors = turn_right report "ERROR: Not steering right on WBB after BWB" severity error;
				
				-- Trigger state transition to reset state with counter value
				COUNTER_TRIGGER(count_in, count_reset);
			
			-- Apply BBW pattern to see if the line follower still functions
			-- Assumption: the controller still works in the line follower and the BBW pattern will trigger a turn left action to get back on the line (opposite direction of turn signal)
				-- Set sensor value
				sensors <= bbw;
				-- Clock the controller
				CLOCK_UNTIL(count_reset, '0');
				-- Check if motor settings are correct
				assert motors = turn_left report "ERROR: Not steering left on BBW after BWB" severity error;
				
				-- Trigger state transition to reset state with counter value
				COUNTER_TRIGGER(count_in, count_reset);
				
		elsif (response = turn_right_sharp and iterations = 0) then
			-- Test pattern used:
				-- BBW (turn right)					
				-- BWW (turn right)
				-- WWW (start going forward)
				-- BWW (turn right)						BWW (forward)		<- line finder type of behaviour from here, can be implemented in two ways
				-- BBW (turn right)						BBW (forward)
				--										WBW (forward)
				--										WBB (forward)
				--										WWB (forward)
				--										WWW (start turning right)
				-- 'Hope' we hit the line in the middle	Continue like the turn_right case (see above from WWW)
			-- Probably not used and quite complex, better tested using a full system simulator
			-- (Can be expanded upon request)
			report "ERROR: Possible correct implementation of a quick turn, please check manually" severity error;
		else
			report "ERROR: Not turning or turning incorrectly after crossing" severity error;
		end if;		
	else
		report "ERROR: Unexpected behaviour on crossing detection (BBB)" severity error;
	end if;
	
	-- Testing done, stop simulation using a failure report
	report "TESTING DONE" severity failure;
	wait;
end process;
	
end architecture;
