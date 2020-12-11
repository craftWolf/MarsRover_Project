library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

-- entity track+find
entity controller is
	generic(
  		CLK_SCALE : INTEGER := 10000 -- Lower clock frequency by scale factor
  	);
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
end entity controller;


-- architecture of the combine line tracker and founder
architecture mixed of controller is

  -- extra signal needed for the CH7_Line_Finder
  signal int_Line_found	: std_logic;
  signal int_tracker_vector : std_logic_vector (4 downto 0); -- count_reset, motor_left/right_reset/direction
  signal int_finder_vector : std_logic_vector (4 downto 0); -- count_reset, motor_left/right_reset/direction
  signal int_mux_out_vector : std_logic_vector (4 downto 0); -- count_reset, motor_left/right_reset/direction
  signal int_line_finder_reset : std_logic;
  signal int_line_tracker_reset : std_logic;
  signal int_sel : std_logic;
  -- Multiplexer
  component mux2 is
    port (  in_track, in_find: in std_logic_vector (4 downto 0);
            s_bit : in std_logic;
            out_res : out std_logic_vector( 4 downto 0));
  end component mux2;

  -- entity controller Line Finder
  component line_finder is
  	port (	clk			: in	std_logic;
  		reset			: in	std_logic;
		line_finder_reset	: in 	std_logic;

  		sensor_l		: in	std_logic;
  		sensor_m		: in	std_logic;
  		sensor_r		: in	std_logic;

  		count_in		: in	std_logic_vector (20 downto 0);
  		count_reset		: out	std_logic;

  		motor_l_reset		: out	std_logic;
  		motor_l_direction	: out	std_logic;

  		motor_r_reset		: out	std_logic;
  		motor_r_direction	: out	std_logic;
  		Line_found		: out	std_logic
  	);
  end component line_finder;

  -- entity controller Line Tracker
  component line_tracker is
  	port (	clk			: in	std_logic;
  		reset			: in	std_logic;
		line_tracker_reset	: in 	std_logic;

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
  end component line_tracker;

  component Main_Controller is
	port (	clk			: in	std_logic;
		reset			: in	std_logic;
		line_found		: in	std_logic;
		line_finder_reset 	: out 	std_logic;	-- Used to reset the line finder
		line_tracker_reset 	: out   std_logic;      -- Used to reset the line tracker, 
								-- also used when switching from finding to tracking
		sel			: out std_logic
	);
  end component Main_Controller;

begin

lbl1: line_tracker port map (	clk => clk,
  					reset => reset,
					line_tracker_reset => int_line_tracker_reset,
  					sensor_l => sensor_l,
  					sensor_m => sensor_m,
  					sensor_r => sensor_r,
  					count_in => count_in,

  					count_reset => int_tracker_vector(0),
  					motor_l_reset => int_tracker_vector(1),
  					motor_l_direction => int_tracker_vector(2),
  					motor_r_reset => int_tracker_vector(3),
  					motor_r_direction => int_tracker_vector(4)
            );

lbl2: line_finder port map (	clk => clk,
  					reset => reset,
					line_finder_reset => int_line_finder_reset,
  					sensor_l => sensor_l,
  					sensor_m => sensor_m,
  					sensor_r => sensor_r,
            				count_in => count_in,

           				count_reset => int_finder_vector(0),
          				motor_l_reset => int_finder_vector(1),
           				motor_l_direction => int_finder_vector(2),
        				motor_r_reset => int_finder_vector(3),
         				motor_r_direction => int_finder_vector(4),
        				line_found => int_Line_found
            );

lbl3 : Main_Controller port map (	clk			=> clk,
					reset			=> reset,
					line_found		=> int_Line_found,
					line_finder_reset 	=> int_line_finder_reset,	
					line_tracker_reset 	=> int_line_tracker_reset,
					sel			=> int_sel
	);

lbl4: mux2 port map (in_track=>int_tracker_vector,
                      in_find=>int_finder_vector,
                      s_bit=>int_sel,
                      out_res=>int_mux_out_vector
                      );

count_reset <= int_mux_out_vector(0);
motor_l_reset <= int_mux_out_vector(1);
motor_l_direction <= int_mux_out_vector(2);
motor_r_reset <= int_mux_out_vector(3);
motor_r_direction <= int_mux_out_vector(4);

end architecture;
