-- entity track+find
entity controller_comb is
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
end entity controller_comb;


-- architecture of the combine line tracker and founder
architecture mixed of controller_comb is

  -- extra signal needed for the CH7_Line_Finder
  signal int_Line_found	: std_logic;
  signal int_tracker_vector : std_logic_vector (4 downto 0); -- count_reset, motor_left/right_reset/direction
  signal int_finder_vector : std_logic_vector (4 downto 0); -- count_reset, motor_left/right_reset/direction
  signal int_mux_out_vector : std_logic_vector (4 downto 0); -- count_reset, motor_left/right_reset/direction

  -- Multiplexer
  component mux2 is
    port (  in_track, in_find: in std_logic_vector (x downto 0);
            s_bit : in std_logic_vector(1 downto 0);
            out_res : out std_logic_vector( x downto 0));
  end component mux2;

  -- entity controller Line Finder
  component CH7_Line_Finder is
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
  		motor_r_direction	: out	std_logic;
  		Line_found		: out	std_logic
  	);
  end component CH7_Line_Finder;

  -- entity controller Line Tracker
  component CH6_controller is
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
  end component CH6_controller;

begin

  lbl1: CH6_controller port map (	clk => clk,
  					reset => reset,
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

lbl2: CH7_Line_Finder port map (	clk => clk,
  					reset => reset,
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

lbl3: mux2 port map (in_track=>int_tracker_vector,
                      in_find=>int_finder_vector,
                      s_bit=>int_Line_found,
                      out_res=>int_mux_out_vector
                      );

count_reset <= int_mux_out_vector(0);
motor_l_reset <= int_mux_out_vector(1);
motor_l_direction <= int_mux_out_vector(2);
motor_r_reset <= int_mux_out_vector(3);
motor_r_direction <= int_mux_out_vector(4);

end architecture;
