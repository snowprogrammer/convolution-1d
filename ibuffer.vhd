library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity ibuffer is
	generic (
		DATA_WIDTH  : positive;
		FIFO_DEPTH	: positive
	);
	port ( 
		clk		: in  std_logic;
		rst		: in  std_logic;
		write_en	: in  std_logic;
		ib_data_in	: in  signed (DATA_WIDTH - 1 downto 0);
		read_en	: in  std_logic;
		ib_data_out	: out signed (DATA_WIDTH - 1 downto 0);
		empty	: out std_logic;
		full	: out std_logic
	);
end ibuffer;

architecture arch_ibuffer of ibuffer is
type FIFO_Memory is array (0 to FIFO_DEPTH - 1) of SIGNED (DATA_WIDTH - 1 downto 0);
signal mem : FIFO_Memory;
begin

	-- Memory Pointer Process
	fifo_proc : process (CLK,rst)		
		variable ibuffer_head : natural range 0 to FIFO_DEPTH - 1;
		variable ibuffer_tail : natural range 0 to FIFO_DEPTH - 1;
		
		variable looped : boolean;
	begin
		if clk='1' then
			if rst = '1' then
				ibuffer_head := 0;
				ibuffer_tail := 0;
				looped := false;
				full  <= '0';
				empty <= '1';
			else
				if (read_en = '1') then
					if ((looped = true) or (ibuffer_head /= ibuffer_tail)) then
						-- Update data output
						ib_data_out <= mem(ibuffer_tail);
						
						-- Update Tail pointer as needed
						if (ibuffer_tail = FIFO_DEPTH - 1) then
							ibuffer_tail := 0;
							
							looped := false;
						else
							ibuffer_tail := ibuffer_tail + 1;
						end if;
						
						
					end if;
				end if;
				
				if (write_en = '1') then
					if ((looped = false) or (ibuffer_head /= ibuffer_tail)) then
						-- Write Data to Memory
						mem(ibuffer_head) <= ib_data_in;
						
						-- Increment Head pointer as needed
						if (ibuffer_head = FIFO_DEPTH - 1) then
							ibuffer_head := 0;
							
							looped := true;
						else
							ibuffer_head := ibuffer_head + 1;
						end if;
					end if;
				end if;
				
				-- Update Empty and Full flags
				if (ibuffer_head = ibuffer_tail) then
					if looped then
						full <= '1';
					else
						empty <= '1';
					end if;
				else
					empty	<= '0';
					full	<= '0';
				end if;
			end if;
		end if;
	end process; 
end arch_ibuffer;