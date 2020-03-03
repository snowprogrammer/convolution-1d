library ieee;
library work;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_signed.ALL;

package type_pack is
  type int_array is array (integer range <>) of integer;
end type_pack;