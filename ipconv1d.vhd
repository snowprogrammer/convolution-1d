library ieee;
library std;
library work;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.package_cnn.all;
use std.textio.all;
use ieee.std_logic_textio.all;


entity ipconv1d is 
  generic (
    DATA_WIDTH : positive;
    KERNEL_SIZE : positive;
    DATA_WIDTH2 : positive
    );
  port (
    im_data_in : in signed(DATA_WIDTH-1 downto 0);
	  weights : in int_array (1 to KERNEL_SIZE);
    clk : in std_logic:='1';
    rst : in std_logic;
    write_ready : out std_logic; -- psum write enable
    read_ready : out std_logic; -- ibuffer read enable
    psum : out signed(DATA_WIDTH2-1 downto 0)
    );
end ipconv1d;

architecture arch_ipconv1d of ipconv1d is
signal data_in : integer;
signal delay_line : int_array (1 to KERNEL_SIZE) := (others => 0);
signal acc_mult : int_array (1 to KERNEL_SIZE) := (others => 0);
signal acc_add : int_array (1 to KERNEL_SIZE) := (others => 0);
--signal first_not_zero : boolean := false;
begin
  
  data_in <= to_integer(im_data_in);
  conv1_process : process(clk,rst)
  variable weight_pt : natural := 1;
  variable input_set : natural := 0;
  variable start : boolean := false;
  variable stk : boolean := true;
  variable first_not_zero : boolean := false;  
  begin
    if clk='1' then 
    if data_in/=0  then
      first_not_zero:=true; -- signal pour detecter si le premier entree est 0, il permet de forcer le programme commerce a une valeur different que 0.
    end if;
    if(rst='1' or (data_in=0 and first_not_zero=false) ) then 
      acc_mult <= (others => 0);
      acc_add <= (others => 0);  
      delay_line <= (others => 0);
      start := false;
      input_set := 0;
      weight_pt := 1;
    else
      if(not(start)) then
        if(input_set < KERNEL_SIZE) then
          delay_line <= data_in & delay_line(1 to KERNEL_SIZE-1);
          input_set := input_set + 1;
        else
          arithmetic_process_init : for k in 1 to KERNEL_SIZE loop
          acc_mult(k) <= delay_line(k)*weights(weight_pt);
          acc_add(k) <= acc_add(k) + acc_mult(k);
        end loop arithmetic_process_init;
          delay_line <= data_in & delay_line(1 to KERNEL_SIZE-1);
          weight_pt := weight_pt + 1;
          start := true;
          stk := false;
          input_set := 0; 
        end if;
      elsif (not(stk)) then
        if (weight_pt = KERNEL_SIZE) then --deux periode avant output
           read_ready <= '1'; --deux periode avant output
        end if; --deux periode avant output

        if (weight_pt = KERNEL_SIZE+1) then
          weight_pt := 1;
          arithmetic_process_last : for k in 1 to KERNEL_SIZE loop
          acc_mult(k) <= delay_line(k)*weights(weight_pt);
          acc_add(k) <= acc_add(k) + acc_mult(k);
        end loop arithmetic_process_last;

        delay_line <= data_in & delay_line(1 to KERNEL_SIZE-1);
        write_ready <= '1';--un periode avant output
        input_set := 0;
        stk := true;
        else
          arithmetic_process : for k in 1 to KERNEL_SIZE loop
          acc_mult(k) <= delay_line(k)*weights(weight_pt);
          acc_add(k) <= acc_add(k) + acc_mult(k);
        end loop arithmetic_process;
        delay_line <= data_in & delay_line(1 to KERNEL_SIZE-1);
        weight_pt := weight_pt + 1;
        end if;
      else
        if(input_set < KERNEL_SIZE) then 
          psum <= to_signed(acc_add(KERNEL_SIZE-input_set),2*DATA_WIDTH);
          input_set := input_set + 1;

          if(input_set = KERNEL_SIZE-1) then -- deux periode avant fin de output
             read_ready <= '0'; -- deux periode avant fin de output
             --write_ready <= '0';
          end if;   -- deux periode avant fin de output
          
          if(input_set = KERNEL_SIZE) then -- une periode avant fin de output
             write_ready <= '0';
             --read_ready <= '0'; 
          end if;   -- une periode avant fin de output

          --stack <= '1'; -- meme periode de debut de output
        else
          delay_line <= data_in & delay_line(1 to KERNEL_SIZE-1);
          stk := false;
          weight_pt := weight_pt + 1;

          a_process : for k in 1 to KERNEL_SIZE loop
          acc_mult(k) <= delay_line(k)*weights(weight_pt);
          acc_add(k) <= acc_mult(k);
          end loop a_process;

          --write_ready <= '0'; -- meme periode de fin de output
          input_set := 0;
          weight_pt := weight_pt + 1;
          psum<= (others=>'0');
        end if;
      end if; 
    end if;
  end if;
  end process conv1_process;
end arch_ipconv1d;
--library ieee;
--library std;
--library work;
--use ieee.std_logic_1164.all;
--use ieee.numeric_std.all;
--use work.package_cnn.all;
--use std.textio.all;
--use ieee.std_logic_textio.all;
--
--
--entity ipconv1d is 
--  generic (
--    DATA_WIDTH : positive;
--    KERNEL_SIZE : positive;
--    DATA_WIDTH2 : positive
--    );
--  port (
--    im_data_in : in signed(DATA_WIDTH-1 downto 0);
--	  weights : in int_array (1 to KERNEL_SIZE);
--    clk : in std_logic:='1';
--    rst : in std_logic;
--    stack : out std_logic; -- psum write enable
--    psum : out signed(DATA_WIDTH2-1 downto 0)
--    );
--end ipconv1d;
--
--architecture arch_ipconv1d of ipconv1d is
--signal data_in : integer;
--signal delay_line : int_array (1 to KERNEL_SIZE) := (others => 0);
--signal acc_mult : int_array (1 to KERNEL_SIZE) := (others => 0);
--signal acc_add : int_array (1 to KERNEL_SIZE) := (others => 0);
----signal first_not_zero : boolean := false;
--begin
--  
--  data_in <= to_integer(im_data_in);
--  conv1_process : process(clk,rst)
--  variable weight_pt : natural := 1;
--  variable input_set : natural := 0;
--  variable start : boolean := false;
--  variable stk : boolean := true;
--  variable first_not_zero : boolean := false;  
--  begin
--    if clk='1' then 
--    if data_in/=0  then
--      first_not_zero:=true; -- signal pour detecter si le premier entree est 0, il permet de forcer le programme commerce a une valeur different que 0.
--    end if;
--    if(rst='1' or (data_in=0 and first_not_zero=false) ) then 
--      acc_mult <= (others => 0);
--      acc_add <= (others => 0);  
--      delay_line <= (others => 0);
--      start := false;
--      input_set := 0;
--      weight_pt := 1;
--    else
--      if(not(start)) then
--        if(input_set < KERNEL_SIZE) then
--          delay_line <= data_in & delay_line(1 to KERNEL_SIZE-1);
--          input_set := input_set + 1;
--        else
--          arithmetic_process_init : for k in 1 to KERNEL_SIZE loop
--          acc_mult(k) <= delay_line(k)*weights(weight_pt);
--          acc_add(k) <= acc_add(k) + acc_mult(k);
--        end loop arithmetic_process_init;
--          delay_line <= data_in & delay_line(1 to KERNEL_SIZE-1);
--          weight_pt := weight_pt + 1;
--          start := true;
--          stk := false;
--          input_set := 0; 
--        end if;
--      elsif (not(stk)) then
--        if (weight_pt = KERNEL_SIZE) then --deux periode avant output
--           stack <= '1'; --deux periode avant output
--        end if; --deux periode avant output
--
--        if (weight_pt = KERNEL_SIZE+1) then
--          weight_pt := 1;
--          arithmetic_process_last : for k in 1 to KERNEL_SIZE loop
--          acc_mult(k) <= delay_line(k)*weights(weight_pt);
--          acc_add(k) <= acc_add(k) + acc_mult(k);
--        end loop arithmetic_process_last;
--        delay_line <= data_in & delay_line(1 to KERNEL_SIZE-1);
--        --stack <= '1';--un periode avant output
--        input_set := 0;
--        stk := true;
--        else
--          arithmetic_process : for k in 1 to KERNEL_SIZE loop
--          acc_mult(k) <= delay_line(k)*weights(weight_pt);
--          acc_add(k) <= acc_add(k) + acc_mult(k);
--        end loop arithmetic_process;
--        delay_line <= data_in & delay_line(1 to KERNEL_SIZE-1);
--        weight_pt := weight_pt + 1;
--        end if;
--      else
--        if(input_set < KERNEL_SIZE) then 
--          psum <= to_signed(acc_add(KERNEL_SIZE-input_set),2*DATA_WIDTH);
--          input_set := input_set + 1;
--
--          --if(input_set = KERNEL_SIZE-1) then -- une periode avant fin de output
--             --stack <= '0'; -- une periode avant fin de output
--          --end if;   -- une periode avant fin de output
--
--          --stack <= '1'; -- meme periode de debut de output
--        else
--          --delay_line <= data_in & delay_line(1 to KERNEL_SIZE-1);
--          stk := false;
--          stack <= '0'; -- meme periode de fin de output
--          acc_add <= (others=>0);
--          input_set := 0;
--          weight_pt := weight_pt + 1;
--          psum<= (others=>'0');
--        end if;
--      end if; 
--    end if;
--  end if;
--  end process conv1_process;
--end arch_ipconv1d;