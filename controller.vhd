library ieee;
use ieee.std_logic_1164.ALL;
use ieee.std_logic_unsigned.all;
use ieee.NUMERIC_STD.ALL;
 
 
entity controller is
port(
	  Clk     	: IN   STD_LOGIC;	
	  Reset   	: IN   STD_LOGIC;	  
	  shft	 	: OUT  STD_LOGIC;
	  Ram_En	 	: OUT  STD_LOGIC;
	  Ram_addr 	: OUT  STD_LOGIC_VECTOR(9 downto 0)	  
	  );
end entity;


architecture a_controller of controller is
signal counter  : unsigned(10 downto 0) := (others => '0');
signal addr		 : unsigned(9  downto 0) := (others => '0');

constant End_count  	: natural := 1056;--hsync of vga
constant Pixel_Count : natural := 192;-- 281;	--shift rest of pixels 176-71 /176 -39
constant index_delay : natural := 0;	--wait
constant number_Disp : natural := 80;-- 39;	--first shift 64+7 / 32+7

begin
		Ram_addr		<=std_logic_vector(addr);
		 process(clk,reset)
		 begin
		 
		 
		 
		 if reset='1' then	
					shft		<= '0';
					Ram_en	<= '0';
					counter	<= (others => '0');
					addr		<= (others => '0');		
		 elsif rising_edge(clk) then
			
				
				if counter = 0  
				then
					counter  <= counter + 1;
					addr		<= (others => '0');
				elsif counter > 0  and
						counter < number_Disp  
				then --GET 64 PIXELS 
					shft		<= '0';
					Ram_en	<= '0';
					addr		<= addr + 1;
					counter  <= counter + 1;
				elsif counter >= number_Disp and 
						counter < Pixel_Count + number_Disp
				then --SHIFT 
					shft		<= '1';
					Ram_en	<= '1';
					addr		<= addr + 1;
					counter  <= counter + 1;
				elsif counter >= Pixel_Count + number_Disp and 
						counter < end_count
				then --STOP SHIFT
					shft		<= '0';
					Ram_en	<= '0';
					counter  <= counter + 1;
					
				elsif counter >= end_count 
				then
					counter	<= (others => '0');
					addr		<= (others => '0');					
				end if;

				
			end if;
			
		 end process;
		 
		 
		 	

end architecture;