library ieee;
use ieee.std_logic_1164.all;

ENTITY fsm is 
port (clock:IN STD_LOGIC;
      start:IN STD_LOGIC;
      reset:IN STD_LOGIC;
      ibuffer_full :IN STD_LOGIC;
      ibuffer_empty :IN STD_LOGIC;
      final:IN STD_LOGIC;-- read_en_psum enable
      etat:OUT integer); -- passer l'etat a 1dconv.cnn
END fsm;

architecture rtl of fsm is
type state_type is (S0, S1, S2, S3);
signal state, next_state : state_type;
begin

SYNC_PROC : process (clock)
  begin
  if rising_edge(clock) then
    if (reset = '1') then
        state <= S0;
    else
        state <= next_state;
    end if;
  end if;
end process;

NEXT_STATE_DECODE : process (state,start,ibuffer_full,ibuffer_empty,final)
  begin
    etat <= 1;
  case (state) is
     when S0 => etat <= 1;
            if (start= '1') then
                
                next_state <= S1;
            else
                next_state <= S0;
            end if;
     when S1 => etat <= 2;
            if (ibuffer_full='1' and ibuffer_empty='0') then
                next_state <= S2;
                
            else
                next_state <= S1;
            end if;
     when S2 => etat <= 3;
            if (final='1') then
                next_state <= S3;
                
            else
                next_state <= S2;
            end if;
     when S3 => etat <= 4;
             if (start= '0') then
                
                next_state <= S0;
            else
                next_state <= S3;
            end if;
     when others =>
                next_state <= S0;
     end case;
end process;
end rtl;
