library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
 
entity sum2 is
port(
	  Clk     : IN STD_LOGIC;	  
	  
	  I0      : IN STD_LOGIC_VECTOR(10 downto 0);
	  I1      : IN STD_LOGIC_VECTOR(10 downto 0);
	  O       : OUT STD_LOGIC_VECTOR(10 downto 0)
	  	  
	  );
end entity;


architecture a_sum2 of sum2 is

begin

		 process (clk)
		 
		 begin
		 --if rising_Edge(clk) then
			O<=std_logic_vector( 
			unsigned("0"&I0)+
			unsigned("0"&I1))(11 downto 1);
		--end if;
		 end process;

end architecture;