library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

-- Combine controller Multiplexer
entity mux3 is
  port (  in_track, in_find, in_turner: in std_logic_vector (4 downto 0);
          s_bit : in std_logic_vector (1 downto 0);
          out_res : out std_logic_vector( 4 downto 0));
end entity;

architecture behave of mux3 is
begin

  process(s_bit, in_track, in_find, in_turner)
  begin
    case s_bit is
      when "10" => out_res <= in_turner;
      when "01" => out_res <= in_track;
      when others => out_res <= in_find;
    end case;
  end process;

end architecture;
