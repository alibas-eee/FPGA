library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
 
--TESTED 
 
entity sum8 is
port(
	  Clk     : IN  STD_LOGIC;	
-----------------------------------------------	  
	  S0      : IN STD_LOGIC_VECTOR(7 downto 0);
	  S1      : IN STD_LOGIC_VECTOR(7 downto 0);	  
	  S2      : IN STD_LOGIC_VECTOR(7 downto 0);
	  S3      : IN STD_LOGIC_VECTOR(7 downto 0);
-----------------------------------------------	 
	  S4      : IN STD_LOGIC_VECTOR(7 downto 0);
	  S5      : IN STD_LOGIC_VECTOR(7 downto 0);	  
	  S6      : IN STD_LOGIC_VECTOR(7 downto 0);
	  S7      : IN STD_LOGIC_VECTOR(7 downto 0);
-----------------------------------------------	  
	  O       : OUT STD_LOGIC_VECTOR(10 downto 0)	  	  	  
	  );
end entity;


architecture a_sum8 of sum8 is
signal T :  STD_LOGIC_VECTOR(10 downto 0);
begin

o<=T(10 downto 0);
		 process (clk)
		 
		 begin
		 if rising_edge(clk) then
			
			t<=std_logic_vector( 
			unsigned("000"&s0)+
			unsigned("000"&s1)+	
			unsigned("000"&s2)+
			unsigned("000"&s3)+
			unsigned("000"&s4)+
			unsigned("000"&s5)+
			unsigned("000"&s6)+
			unsigned("000"&s7)
);
		 end if;
		 
		 end process;

end architecture;