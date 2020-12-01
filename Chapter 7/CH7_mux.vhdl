-- Combine controller Multiplexer
entity mux2 is
  port (  in_track, in_find: in std_logic_vector (x downto 0);
          s_bit : in std_logic;
          out_res : out std_logic_vector( x downto 0));
end entity;

architecture behave of mux2 is
begin

  process(s_bit)
  begin
    case s_bit is
      when '1' => out_res <= in_track;
      when others => out_res < in_find;
    end case;
  end process;

end architecture;
