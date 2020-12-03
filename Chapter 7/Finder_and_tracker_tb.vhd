-- ################################################
--
--           TESTBENCH FOR Line finder and line tracker
--				(student version)
--         EE3130TU (Mars Rover Project)
--		
-- Attention: Forward is being coded as '1' both for the left and right motors, 
--            if your controller uses a different configuration you can change this in the controller_wrapper.
-- ################################################


library IEEE;
use IEEE.std_logic_1164.all;

entity Finder_and_tracker_tb is
end entity Finder_and_tracker_tb;

architecture testbench of Finder_and_tracker_tb is

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
	-- Counter constants
	constant count_zero : std_logic_vector(20 downto 0) := (others => '0');
	constant count_trig : std_logic_vector(20 downto 0) := (others => '1');

	-- Motor signals (res_l, dir_l, res_r, dir_r)
	signal motor_data : std_logic_vector(3 downto 0);
	-- Type and signal for decoding the motor signals
	type motors_type is (idle, forward, turn_left, turn_right, turn_left_sharp, turn_right_sharp, backward, turn_left_backward, turn_right_backward); 
	signal motors : motors_type;
	-- Correction for motor control
	signal motor_correction : std_logic_vector(3 downto 0) := (others => '0');
	signal motor_corrected : std_logic_vector(3 downto 0);
	
	-- PWM reset signal
	signal pwm_reset : std_logic;
		
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
	
-- PWM reset conditions: clock and generators should be reset
pwm_reset <= count_reset and motor_data(3) and motor_data(1);
	
-- Clock signal
clk <= not clk after period/2; -- Rising edge at 5 ns, 15 ns, 25 ns, etc.
	
-- Testbench process
tb: process is
	-- Variables to determine controller behaviour
	variable response : motors_type := forward;
	constant min_iterations : integer := 40;
	constant max_iterations : integer := 60;
	variable iterations : integer range 0 to max_iterations+1;
	variable delay : integer := 0;
	constant max_delay : integer := 10;
	
	-- Procedure that clocks the controller until signal_a = constant_b
	-- Will result in failure if condition is not met within max_delay clock cycles
	procedure CLOCK_UNTIL (
		signal signal_a : in std_logic;
		constant constant_b : in std_logic;
		constant msg : in string) is
		
		variable delay : integer := 0;
		constant max_delay : integer := 10;
	begin
		while signal_a /= constant_b loop
			wait for period;
			delay := delay + 1;
			assert delay <= max_delay report "ERROR: CLOCK_UNTIL: " & msg severity failure;
		end loop;
	end CLOCK_UNTIL;
	
	-- Procedure to simulate counter reaching very large value
	procedure COUNTER_TRIGGER is
	begin
		-- Trigger state transition to reset state with counter value
		count_in <= count_trig;
		-- Clock the controller until pwm generators and counter are reset
		CLOCK_UNTIL(pwm_reset, '1', "COUNTER_TRIGGER: PWM generators and/or counter not reset");
		-- Restore counter input since there is a reset signal 
		-- NOTE: this would normally happen one cycle later if the counter's reset is synchronous!
		count_in <= count_zero;
	end COUNTER_TRIGGER;
	
	-- Procedure to see if the motor response to a certain sensor pattern is correct
	procedure CHECK_RESPONSE(
		-- Sensor excitation and motor expected response
		constant sensor_input : in sensors_type;
		constant motor_response : in motors_type;
		constant msg : in string) is
	begin
		-- Set sensor value
		sensors <= sensor_input;
		-- Clock the controller until the counter reset equals 0
		CLOCK_UNTIL(count_reset, '0', "counter reset not to '0': " & msg);
		-- Check if motor settings are correct
		assert motors = motor_response report "ERROR: CHECK_RESPONSE: unexpected motor response to excitation: " & msg severity error;
		-- Trigger state transition to reset state with counter value
		COUNTER_TRIGGER;
	end CHECK_RESPONSE;
		
	-- Procedure to see if the motor response to a certain sensor pattern is correct
	-- Similar as above, but now two responses are allowed
	procedure CHECK_RESPONSES(
		-- Sensor excitation and motor expected response
		constant sensor_input : in sensors_type;
		constant motor_response1 : in motors_type;
		constant motor_response2 : in motors_type;
		constant msg : in string) is
	begin
		-- Set sensor value
		sensors <= sensor_input;
		-- Clock the controller until the counter reset equals 0
		CLOCK_UNTIL(count_reset, '0', "counter reset not to '0': " & msg);
		-- Check if motor settings are correct
		assert motors = motor_response1 or motors = motor_response2 report "ERROR: CHECK_RESPONSES: unexpected motor response to excitation: " & msg severity error;
		-- Trigger state transition to reset state with counter value
		COUNTER_TRIGGER;
	end CHECK_RESPONSES;

begin
	-- Reset the controller
		reset <= '1';
		wait for period;
		assert count_reset = '1' report "ERROR: Counter not reset in reset state" severity error;
		assert motors = idle report "ERROR: Motors not idle in reset state" severity error;
		reset <= '0';
		
	-- Detect driving signal convention
		sensors <= www;
		CLOCK_UNTIL(count_reset, '0', "counter reset not '0' when starting");
		motor_correction <= "0101" xor motor_data;
		COUNTER_TRIGGER;


-- Below are five line finder test scenarios and a line tracker test, 
-- choose one line finder, comment the other four and simulate the test bench.
-- To test only the line tracker, comment all five of the line finders.

	-- Test one of the line finder
		CHECK_RESPONSE(www, forward, "Line finder: WWW");
		CHECK_RESPONSE(www, forward, "Line finder: WWW");
		CHECK_RESPONSE(www, forward, "Line finder: WWW");
		CHECK_RESPONSE(www, forward, "Line finder: WWW");
		CHECK_RESPONSE(bww, forward, "Line finder: BWW");
		CHECK_RESPONSE(bbw, forward, "Line finder: BBW");
		CHECK_RESPONSE(wbb, forward, "Line finder: WBB");
		CHECK_RESPONSE(wwb, forward, "Line finder: WWB");
		CHECK_RESPONSES(www, turn_right_sharp, turn_right, "Line finder: WWW");
		CHECK_RESPONSES(wwb, turn_right_sharp, turn_right, "Line finder: WWB");
		CHECK_RESPONSES(wbb, turn_right_sharp, turn_right, "Line finder: WBB");
		CHECK_RESPONSE(wbw, forward, "Line tracker: WBW");

	-- Test two of the line finder
-- Note: here the choice was made to make a right turn at bbb, if you chose a left turn it is normal that you get errors here
		CHECK_RESPONSE(www, forward, "Line finder: WWW");
		CHECK_RESPONSE(www, forward, "Line finder: WWW");
		CHECK_RESPONSE(bbb, forward, "Line finder: BBB");
		CHECK_RESPONSES(www, turn_right_sharp, turn_right, "Line finder: WWW");
		CHECK_RESPONSES(wwb, turn_right_sharp, turn_right, "Line finder: WWB");
		CHECK_RESPONSES(wbb, turn_right_sharp, turn_right, "Line finder: WBB");
		CHECK_RESPONSE(wbw, forward, "Line tracker: WBW");

	-- Test three of the line tracker
		CHECK_RESPONSE(wbw, forward, "Line finder: WBW");
		CHECK_RESPONSE(wbw, forward, "Line finder: WBW");
		CHECK_RESPONSE(wbw, forward, "Line tracker: WBW");

	-- Test four of the line tracker
		CHECK_RESPONSE(www, forward, "Line finder: WWW");
		CHECK_RESPONSE(www, forward, "Line finder: WWW");
		CHECK_RESPONSE(www, forward, "Line finder: WWW");
		CHECK_RESPONSE(www, forward, "Line finder: WWW");
		CHECK_RESPONSE(wwb, forward, "Line finder: WWB");
		CHECK_RESPONSE(wbb, forward, "Line finder: WBB");
		CHECK_RESPONSE(bbw, forward, "Line finder: BBW");
		CHECK_RESPONSE(bww, forward, "Line finder: BWW");
		CHECK_RESPONSES(www, turn_left_sharp, turn_left, "Line finder: WWW");
		CHECK_RESPONSES(bww, turn_left_sharp, turn_left, "Line finder: BWW");
		CHECK_RESPONSES(bbw, turn_left_sharp, turn_left, "Line finder: BBW");
		CHECK_RESPONSE(wbw, forward, "Line tracker: WBW");


	-- Test five of the line finder
		CHECK_RESPONSE(www, forward, "Line finder: WWW");
		CHECK_RESPONSE(bww, forward, "Line finder: BWW");
		CHECK_RESPONSE(bww, forward, "Line finder: BWW");
		CHECK_RESPONSES(www, turn_left_sharp, turn_left, "Line finder: WWW");
		CHECK_RESPONSES(bww, turn_left_sharp, turn_left, "Line finder: BWW");
		CHECK_RESPONSE(wbw, forward, "Line tracker: WBW");


	-- Test the line follower
		CHECK_RESPONSE(wbw, forward, "Line tracker: WBW");
		CHECK_RESPONSE(wbb, turn_right, "Line tracker: WBB");
		CHECK_RESPONSE(wbw, forward, "Line tracker: WBW");
		CHECK_RESPONSE(bww, turn_left_sharp, "Line tracker: BWW");
		CHECK_RESPONSE(bbw, turn_left, "Line tracker: BBW");
		CHECK_RESPONSE(wbw, forward, "Line tracker: WBW");
		CHECK_RESPONSE(www, forward, "Line tracker: WWW");
		CHECK_RESPONSE(wbw, forward, "Line tracker: WBW");
		CHECK_RESPONSE(bbb, forward, "Line tracker: BBB");
		CHECK_RESPONSE(bwb, forward, "Line tracker: BWB");
		CHECK_RESPONSE(wbw, forward, "Line tracker: WBW");
		CHECK_RESPONSE(www, forward, "Line tracker: WWW");
		CHECK_RESPONSE(www, forward, "Line tracker: WWW");
		CHECK_RESPONSE(www, forward, "Line tracker: WWW");
	
--	
	-- Testing done, stop simulation using a failure report
	report "TESTING DONE" severity failure;
	wait;
end process;
	
end architecture;
