library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity psum is
	Generic (
		DATA_WIDTH2 : positive;
		FIFO_DEPTH	: positive
	);
	Port ( 
		clk		: in  STD_LOGIC;
		rst		: in  STD_LOGIC;
		write_en	: in  STD_LOGIC;
		psum_data_in	: in  SIGNED (DATA_WIDTH2 - 1 downto 0);
		read_en	: in  STD_LOGIC;
		psum_data_out	: out SIGNED (DATA_WIDTH2 - 1 downto 0);
		final: out STD_LOGIC; -- singnifier la dernier round
		empty	: out STD_LOGIC;
		full	: out STD_LOGIC
	);
end psum;

architecture arch_psum of psum is
type FIFO_Memory is array (0 to FIFO_DEPTH - 1) of SIGNED (DATA_WIDTH2 - 1 downto 0);
signal mem : FIFO_Memory;
signal count: integer:=0;
signal f1: STD_LOGIC:='0';
begin
  final<=f1;
	-- Memory Pointer Process
	fifo_proc : process (CLK)
		
		variable psum_head : natural range 0 to FIFO_DEPTH - 1;
		variable psum_tail : natural range 0 to FIFO_DEPTH - 1;
		
		variable looped : boolean;
	begin
		if rising_edge(clk) then
		  if rst = '1' then
				psum_head := 0;
				psum_tail := 0;
				looped := false;
				full  <= '0';
				empty <= '1';
		  else
		   if (read_en = '1') then
			if ((looped = true) or (psum_head /= psum_tail)) then
			-- Update data output
			psum_data_out <= mem(psum_tail);
			
			-- Update Tail pointer as needed
			  if (psum_tail = FIFO_DEPTH - 1) then
			     psum_tail := 0;
			     looped := false;
			  else
			      psum_tail := psum_tail + 1;
			  end if;
			end if;
		   end if;
				
		   if (write_en = '1') then
		     if ((looped = false) or (psum_head /= psum_tail)) then
		      -- Write Data to Memory
		     count<=count+1;
		      mem(psum_head) <= psum_data_in;
		      -- Increment Head pointer as needed
		        if (psum_head = FIFO_DEPTH - 1) then
			psum_head := 0;
			looped := true;
		        else
			psum_head := psum_head + 1;
		        end if;
		     end if;
		   end if;
		   -- Update Empty and Full flags
		   if (psum_head = psum_tail) then
		      if looped then
			full <= '1';
		      else
			empty <= '1';
		      end if;
		   else
		        empty<= '0';
			full<= '0';
		   end if;
		end if;
	     end if;
	end process;
	
  final_flag: process(clk)
   begin
  if 	count=FIFO_DEPTH then
  	f1<='1';
	end if;
	end process;
  	
end arch_psum;