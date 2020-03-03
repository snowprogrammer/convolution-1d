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

Architecture rtl of fsm is
  
type state_type IS (un,deux,trois,quatre);  
signal state : state_Type:=un;     					      
BEGIN 
  PROCESS (clock)
  BEGIN 
    if clock='1' then
       if (reset = '1') THEN          
	  state <= un;
          etat<=1;
       else    
	          case state IS
 
		  WHEN un => if start= '1' then
		                state <= deux;
                                etat<=2;
                             end if;

		  WHEN deux => if ibuffer_full='1' and ibuffer_empty= '0'  then
                                  state <= trois; 
                                  etat<=3;
                               end if;

		  WHEN trois => if final='1' then
				   state <= quatre; 
                                   etat<=4;
                                end if; 
		  WHEN quatre =>

		  WHEN others =>
			        state <= un;
			        etat<=1;
	          END CASE; 
	 
       end if; 
    end if;
  END PROCESS;
 
END rtl;