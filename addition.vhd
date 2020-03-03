library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity addition is
  generic(
    DATA_WIDTH2 : positive
    );
  port(
    operand_1 : in signed (DATA_WIDTH2-1 downto 0);
    operand_2 : in signed (DATA_WIDTH2-1 downto 0);
    add_result : out signed (DATA_WIDTH2-1 downto 0)
    );
end addition;

architecture arch_addition of addition is
begin 
  add_result <= operand_1+operand_2;
end arch_addition;
