library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
--TESTED
-- |Lr-Rr|+|Lg-Rg|+|Lb-Rb| 
entity absad is
port(Clk     : IN  STD_LOGIC;
	  L       : IN STD_LOGIC_VECTOR(15 downto 0);
	  R       : IN STD_LOGIC_VECTOR(15 downto 0);	  
	  O       : OUT STD_LOGIC_VECTOR(7 downto 0)
	  	  
	  );
end entity;


architecture a_absad of absad is
signal T :  STD_LOGIC_VECTOR(15 downto 0);
begin
		 
		 				 
		 process (clk)
		 
		 begin
		 
			--RGB565
		   T(15 downto 11)<=std_logic_vector(abs(signed('0'&L(15 downto 11)) - signed('0'&R(15 downto 11))))(4 downto 0);
			T(10 downto 5) <=std_logic_vector(abs(signed('0'&L(10 downto  5)) - signed('0'&R(10 downto  5))))(5 downto 0);
			T(4  downto 0) <=std_logic_vector(abs(signed('0'&L(4  downto  0)) - signed('0'&R(4  downto  0))))(4 downto 0);
			o<=("00"&T(15 downto 11)&'0')+("00"&T(10 downto 5))+("00"&T(4 downto 0)&'0');
			
			 
		 end process;

end architecture;