library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
 
entity reg is
generic(size  : integer range 0 to 320:=0);
port(
	  Clk     : IN STD_LOGIC;	  
	  E       : IN STD_LOGIC;	  
	  I       : IN STD_LOGIC_VECTOR(15 downto 0);
	  O       : OUT STD_LOGIC_VECTOR(15 downto 0)
	  	  
	  );
end entity;
architecture a_reg of reg is


type array_16bit is array (320 downto 0) of STD_LOGIC_VECTOR(15 downto 0);
constant len :integer range 0 to 320:=size;
signal R:array_16bit;
begin

		 process (clk)
		 
		 begin
		 if rising_Edge(clk) then
			if E='1' then	
				R(0)  <=I ;		
				for i in 1 to len loop
					R(i) <= R(i-1);	
		
				end loop;		
				O<=R(len);				
				end if;
			end if;	
		 end process;

end architecture;