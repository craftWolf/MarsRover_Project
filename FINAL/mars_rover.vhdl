-- libraries for the commonly used datatypes and functions
library IEEE;
use IEEE.std_logic_1164.all;


entity Mars_Rover is
    port( input_clk: in std_logic;
          input_reset: in std_logic;
          input_sensor: in std_logic_vector (2 downto 0);
          output_pwm_left: out std_logic;
          output_pwm_right: out std_logic);
end entity Mars_Rover;

-- Top level Architecture
architecture structural of Mars_rover is
    -- Declaration of the rover_entity components

    -- Input Buffer
    component input_buffer is
      port (	clk		: in	std_logic;

    		sensor_l_in	: in	std_logic;
    		sensor_m_in	: in	std_logic;
    		sensor_r_in	: in	std_logic;

    		sensor_l_out	: out	std_logic;
    		sensor_m_out	: out	std_logic;
    		sensor_r_out	: out	std_logic
    	);
    end component input_buffer;

    -- Controller
    component controller is
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
    end component controller;

    -- Counter
    component counter is
      port (	clk		: in	std_logic;
    		reset		: in	std_logic;

    		count_out	: out	std_logic_vector (20 downto 0)
    	);
    end component counter;

    -- PWM Generator
    component pwm_generator is
      port (	clk		: in	std_logic;
    		reset		: in	std_logic;
    		direction	: in	std_logic;
    		count_in	: in	std_logic_vector (20 downto 0);
    		pwm		: out	std_logic
    	);
    end component pwm_generator;

    -- Intermediate Signals: internal_from_to*_size
    signal internal_sensor_controller_3: std_logic_vector(2 downto 0);

    signal internal_controller_pwm_l_2: std_logic_vector(1 downto 0);
    signal internal_controller_pwm_r_2: std_logic_vector(1 downto 0);
    signal internal_controller_counter: std_logic;

    signal internal_counter_x_x: std_logic_vector(20 downto 0);



begin

    lbl1: input_buffer port map ( clk => input_clk,

                                  sensor_l_in => input_sensor(2),
                                  sensor_m_in => input_sensor(1),
                                  sensor_r_in => input_sensor(0),

                                  sensor_l_out => internal_sensor_controller_3(2),
                                  sensor_m_out => internal_sensor_controller_3(1),
                                  sensor_r_out => internal_sensor_controller_3(0)
);

    lbl2: controller port map ( clk => input_clk,
                                reset => input_reset,

                                sensor_l => internal_sensor_controller_3(2),
                                sensor_m => internal_sensor_controller_3(1),
                                sensor_r => internal_sensor_controller_3(0),

                                count_in => internal_counter_x_x,
                                count_reset => internal_controller_counter,

                                motor_l_reset => internal_controller_pwm_l_2(0),
                                motor_l_direction => internal_controller_pwm_l_2(1),

                                motor_r_reset => internal_controller_pwm_r_2(0),
                                motor_r_direction => internal_controller_pwm_r_2(1)
);

  lbl3: counter port map (  clk => input_clk,
                            reset => internal_controller_counter,
                            count_out => internal_counter_x_x
);

  -- Left PWM
  lbl4: pwm_generator port map (  clk => input_clk,
                                  reset => internal_controller_pwm_l_2(0),
                                  direction => internal_controller_pwm_l_2(1),
                                  count_in => internal_counter_x_x,
                                  pwm => output_pwm_left
);

  -- Right PWM
  lbl5: pwm_generator port map (  clk => input_clk,
                                  reset => internal_controller_pwm_r_2(0),
				  --- invert the direction since the motors are mirrored
                                  direction => not internal_controller_pwm_r_2(1), 
                                  count_in => internal_counter_x_x,
                                  pwm => output_pwm_right
);

end architecture structural;
