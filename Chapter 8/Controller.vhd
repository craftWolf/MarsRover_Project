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

  -- extra signals needed for the turner ch9/10
  signal int_turn_found : std_logic;
  signal int_turn_type  : std_logic;
  signal int_turn_complete : std_logic;
  signal int_stop_signal	: std_logic;

  -- Output vectors of tracker, finder, turner and mux output
  signal int_tracker_vector 	: std_logic_vector (4 downto 0); -- count_reset, motor_left/right_reset/direction
  signal int_finder_vector 	: std_logic_vector (4 downto 0); 
  signal int_turner_vector 	: std_logic_vector (4 downto 0);
  signal int_mux_out_vector 	: std_logic_vector (4 downto 0); 
  signal int_stop_vector	: std_logic_vector (4 downto 0);
  
  -- Reset signals of controllers
  signal int_line_finder_reset : std_logic;
  signal int_line_tracker_reset : std_logic;
  signal int_turner_reset	: std_logic;

  -- select bit
  signal int_sel : std_logic_vector(1 downto 0);

  -- Multiplexer
  component mux3 is
    port (  in_track, in_find, in_turner, in_stop: in std_logic_vector (4 downto 0);
            s_bit : in std_logic_vector( 1 downto 0);
            out_res : out std_logic_vector( 4 downto 0));
  end component mux3;

  -- entity controller Line Finder
  component line_finder is
	generic(
  		CLK_SCALE : INTEGER := 10000 -- Lower clock frequency by scale factor
  	);
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
  end component line_tracker;

  component Main_Controller is
	port (	clk			: in	std_logic;
		reset			: in	std_logic;
		line_found		: in	std_logic;
		turn_found		: in 	std_logic;
		turn_complete		: in	std_logic;
		stop_signal		: in 	std_logic;
		line_finder_reset 	: out 	std_logic;	-- Used to reset the line finder
		line_tracker_reset 	: out   std_logic;      -- Used to reset the line tracker, 
		turn_signal_reset	: out 	std_logic;	-- Used to reset the turner		
		sel			: out 	std_logic_vector(1 downto 0)	-- also used when switching from finding to tracking
	);
end component Main_Controller;
  component turner is
	generic(
  		CLK_SCALE : INTEGER := 10000 -- Lower clock frequency by scale factor
  	);
	port (	clk			: in	std_logic;
		reset			: in	std_logic; -- hard reset
		turner_reset 		: in	std_logic; -- reset coming from main controller;
	
		sensor_l		: in	std_logic;
		sensor_m		: in	std_logic;
		sensor_r		: in	std_logic;
		
		turn_type		: in 	std_logic;

		count_in		: in	std_logic_vector (20 downto 0);
		count_reset		: out	std_logic;

		motor_l_reset		: out	std_logic;
		motor_l_direction	: out	std_logic;

		motor_r_reset		: out	std_logic;
		motor_r_direction	: out	std_logic;
		
		turn_complete		: out   std_logic
	);
   end component turner;
  
   component stop_controller is
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
   end component stop_controller;

begin

lbl1: line_tracker 
			generic map(	CLK_SCALE => CLK_SCALE)			
			port map (	clk => clk,
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
  					motor_r_direction => int_tracker_vector(4),
					turn_type => int_turn_type,
					turn_found => int_turn_found
            );

lbl2: line_finder 
			generic map(	CLK_SCALE => CLK_SCALE)	
			port map (	clk => clk,
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
					turn_found 		=> int_turn_found,
					turn_complete 		=> int_turn_complete,
                    stop_signal     => int_stop_signal,
					line_finder_reset 	=> int_line_finder_reset,	
					line_tracker_reset 	=> int_line_tracker_reset,
					turn_signal_reset 	=> int_turner_reset,
					sel			=> int_sel
	);

lbl4: turner 
			generic map(	CLK_SCALE => CLK_SCALE)			
			port map (	clk => clk,
  					reset => reset,
					turner_reset => int_turner_reset,
  					sensor_l => sensor_l,
  					sensor_m => sensor_m,
  					sensor_r => sensor_r,
  					count_in => count_in,
					turn_type => int_turn_type,
								
  					count_reset => int_turner_vector(0),
  					motor_l_reset => int_turner_vector(1),
  					motor_l_direction => int_turner_vector(2),
  					motor_r_reset => int_turner_vector(3),
  					motor_r_direction => int_turner_vector(4), 
					turn_complete => int_turn_complete	
	);


lbl5: mux3 port map ( 	in_track=>int_tracker_vector,
                      	in_find=>int_finder_vector,
		      	in_turner=> int_turner_vector,
			in_stop=> int_stop_vector,
                      	s_bit=>int_sel,
                      	out_res=>int_mux_out_vector
		
                      );

lbl6: stop_controller   generic map(	CLK_SCALE => CLK_SCALE)	
			port map (	clk => clk,
  					reset => reset,
					
  					sensor_l => sensor_l,
  					sensor_m => sensor_m,
  					sensor_r => sensor_r,
            				count_in => count_in,

           				count_reset => int_stop_vector(0),
          				motor_l_reset => int_stop_vector(1),
           				motor_l_direction => int_stop_vector(2),
        				motor_r_reset => int_stop_vector(3),
         				motor_r_direction => int_stop_vector(4),
        				stop_signal => int_stop_signal 
            );


count_reset <= int_mux_out_vector(0);
motor_l_reset <= int_mux_out_vector(1);
motor_l_direction <= int_mux_out_vector(2);
motor_r_reset <= int_mux_out_vector(3);
motor_r_direction <= int_mux_out_vector(4);

end architecture;
