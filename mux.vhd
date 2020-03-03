library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity mux is
  generic(
    DATA_WIDTH2 : positive
    );
  port(
    ni_psum : in SIGNED (DATA_WIDTH2-1 downto 0);
    mode : in STD_LOGIC;
    mux_out : out SIGNED (DATA_WIDTH2-1 downto 0)
    );
end mux;

architecture arch_mux of mux is
begin
  mux_out <= (others => '0') when (mode = '0') else
       ni_psum when (mode = '1') else (others => 'Z');
end arch_mux;