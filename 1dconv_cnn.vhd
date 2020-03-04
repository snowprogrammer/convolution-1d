library ieee;
use ieee.std_logic_1164.all;
use work.package_cnn.all;
use ieee.numeric_std.all;
ENTITY ldconv_cnn is 
generic (
		DATA_WIDTH  : positive:=8;
		KERNEL_SIZE : positive:=4;
		Nombre_entree : positive:=1003;
		Nombre_sortie : positive:=1000;   --Nombre_entree=Nombre_sortie+KERNEL_SIZE-1
		DATA_WIDTH2 : positive:=16
	);
port (input: in  signed (DATA_WIDTH - 1 downto 0);
      start: in std_logic;
   reset: in std_logic;
   clock: in std_logic;
   data_in_mux: in  signed (DATA_WIDTH2 - 1 downto 0):="0000000010000000";
   mode: in STD_LOGIC:='0';
   weight: in int_array (1 to KERNEL_SIZE):=(2,4,2,2);
   output: out signed (DATA_WIDTH2-1 downto 0));
END ldconv_cnn;

Architecture rtl of ldconv_cnn is
  
  component ibuffer is
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
  end component;
  
  component ipconv1d is 
  generic (
    DATA_WIDTH : positive;
    KERNEL_SIZE : positive;
    DATA_WIDTH2 : positive
    );
  port (
    im_data_in : in signed(DATA_WIDTH-1 downto 0);
    weights : in int_array (1 to KERNEL_SIZE);
    clk,rst : in std_logic;
    write_ready : out std_logic; 
    read_ready : out std_logic;
    psum : out signed(DATA_WIDTH2-1 downto 0)
    );
  end component;   
	
  component psum is
  generic (
		DATA_WIDTH2  : positive;
		FIFO_DEPTH	: positive
  );
  Port ( 
		clk		: in  STD_LOGIC;
		rst		: in  STD_LOGIC;
		write_en	: in  STD_LOGIC;
		psum_data_in	: in  SIGNED (DATA_WIDTH2 - 1 downto 0);
		read_en	: in  STD_LOGIC;
		psum_data_out	: out SIGNED (DATA_WIDTH2 - 1 downto 0);
		final: out STD_LOGIC;
		empty	: out STD_LOGIC;
		full	: out STD_LOGIC
	);
  end component;
	
  component mux is
  generic(
    DATA_WIDTH2 : positive
    );
  port(
    ni_psum : in SIGNED (DATA_WIDTH2-1 downto 0);
    mode : in STD_LOGIC;
    mux_out : out SIGNED (DATA_WIDTH2-1 downto 0)
    );
  end component;
	
  component addition is
  generic(
    DATA_WIDTH2 : positive
    );
  port(
    operand_1 : in signed (DATA_WIDTH2-1 downto 0);
    operand_2 : in signed (DATA_WIDTH2-1 downto 0);
    add_result : out signed (DATA_WIDTH2-1 downto 0)
    );
  end component;
	
  component fsm is 
  port (clock:IN STD_LOGIC;
        start:IN STD_LOGIC;
        reset:IN STD_LOGIC;
        ibuffer_full :IN STD_LOGIC;
        ibuffer_empty :IN STD_LOGIC;
        final:IN STD_LOGIC;
        etat:OUT integer);
  end component;
			      
signal  rst_ibuffer,write_en_ibuffer,read_en_ibuffer,empty_ibuffer,full_ibuffer,rst_ipconv,rst_psum,write_en_psum,read_en_psum,psum_empty,psum_full,final,psum_read_enable,write_ready,read_ready: STD_LOGIC; 
signal  data_out_ibuffer: signed(DATA_WIDTH-1 downto 0);
signal  psum_data_in,psum_data_out,data_out_mux:signed(DATA_WIDTH2-1 downto 0);
signal  etat:integer;
signal  tour1:integer:=0; 
BEGIN 
  ibf: entity work.ibuffer generic map (DATA_WIDTH,Nombre_entree) port map (clock, rst_ibuffer, write_en_ibuffer, input, read_en_ibuffer, data_out_ibuffer, empty_ibuffer, full_ibuffer);
  ipconv: entity work.ipconv1d generic map (DATA_WIDTH,KERNEL_SIZE,DATA_WIDTH2) port map (data_out_ibuffer, weight, clock, rst_ipconv, write_ready, read_ready, psum_data_in);
  psu: entity work.psum generic map (DATA_WIDTH2,Nombre_sortie) port map (clock, rst_psum, write_en_psum, psum_data_in, read_en_psum, psum_data_out, final, psum_empty, psum_full); 
  
  mu:  entity work.mux generic map (DATA_WIDTH2) port map (data_in_mux, mode, data_out_mux);
  add: entity work.addition generic map (DATA_WIDTH2) port map (psum_data_out, data_out_mux, output);
  etat_machine: entity work.fsm port map (clock,start,reset,full_ibuffer,empty_ibuffer,final,etat); 

--  state_machine:process(clock)
--        
--        begin
--        if clock='1' then
--         if reset='1' then
--            rst_ibuffer<='1';
--            rst_ipconv<='1';
--            rst_psum<='1';
--            
--          elsif etat=2 then -- preserver les entree en ibuffer
--            rst_ibuffer<='0';
--            write_en_ibuffer<='1';
--            read_en_ibuffer<='0';
--            
--          elsif etat=3 then 
--            read_en_psum<='0';
--            rst_ipconv<='0';
--            rst_psum<='0';
--            write_en_ibuffer<='0';
--            
--            if empty_ibuffer='1' or read_ready='1'  then  -- si il y a plus de data oubien write flag de 1dconv equale a '1', on arrete a lire dans ibuffer
--               read_en_ibuffer<='0';
--            elsif read_ready/='1' then  -- write flag de 1dconv equale a '0' ,lire
--               read_en_ibuffer<='1';
--            end if;  
--           
--           if write_ready='1' then  --  , si write flag ='1', on arrete a ecrire dans psum.
--              write_en_psum<='1';
--           elsif write_ready='0' then
--               write_en_psum<='0';
--            end if;
--
--          elsif etat=4 then -- dernier round, si nombre de sortie equale qu'on veut, on arrete a mettre en output.
-- 	       if tour1/=Nombre_sortie then
--               write_en_psum<='0';
--               read_en_psum<='1';
--	       tour1<=tour1+1;
--               else 
--	       read_en_psum<='0';
--               end if;
--        end if; 
--      end if;    
--   end process;
--
state_machine:process(clock)
        
        begin
        if clock='1' then
          if reset='1' then
             rst_ibuffer<='1';
             rst_ipconv<='1';
             rst_psum<='1';
          else

          case etat IS
                  WHEN 1 =>
		  WHEN 2 => rst_ibuffer<='0';
                            write_en_ibuffer<='1';
                            read_en_ibuffer<='0';

		  WHEN 3 => read_en_psum<='0';
                            rst_ipconv<='0';
                            rst_psum<='0';
                            write_en_ibuffer<='0';
            
                            if empty_ibuffer='1' or read_ready='1'  then  -- si il y a plus de data oubien write flag de 1dconv equale a '1', on arrete a lire dans ibuffer
                               read_en_ibuffer<='0';
                            elsif read_ready/='1' then  -- write flag de 1dconv equale a '0' ,lire
                               read_en_ibuffer<='1';
                            end if;  
           
                            if write_ready='1' then  --  , si write flag ='1', on arrete a ecrire dans psum.
                               write_en_psum<='1';
                            elsif write_ready='0' then
                               write_en_psum<='0';
                            end if;

		  WHEN 4 => if tour1/=Nombre_sortie then
                               write_en_psum<='0';
                               read_en_psum<='1';
	                       tour1<=tour1+1;
                            else 
	                       read_en_psum<='0';
                            end if;
		  WHEN others =>
	          END CASE; 
           end if; 
         end if;
end process;
end rtl;
