library ieee;
use ieee.std_logic_1164.ALL;
use ieee.std_logic_unsigned.all;
use ieee.NUMERIC_STD.ALL;

entity ov7670_capture3 is
    port (
        pclk  		: in   std_logic;
        vsync 		: in   std_logic;
        href  		: in   std_logic;
        d     		: in   std_logic_vector (7 downto 0);
        rows   	: out  std_logic_vector (8 downto 0);
		  cols   	: out  std_logic_vector (9 downto 0);
        dout  		: out  std_logic_vector (15 downto 0);
        we    		: out  std_logic;
		  row_rdy	: out  std_logic;
		  cam_clr	: out	 std_logic
    );
end ov7670_capture3;

architecture behavioral of ov7670_capture3 is
   signal d_latch      : std_logic_vector(15 downto 0) := (others => '0');
   signal address      : std_logic_vector(14  downto 0)  := (others => '0');
   signal wr_hold      : std_logic_vector(1  downto 0) := (others => '0');
	signal number       : unsigned  (7 downto 0) := (others => '0');
	
	signal temp         :unsigned (15 downto 0);
	signal row			  :unsigned (8 downto 0):=(others=>'0');
	signal row_t		  :unsigned (8 downto 0):=(others=>'0');
	
	signal col			  :unsigned (9 downto 0):=(others=>'0');
	
	signal t            :std_logic_vector(3 downto 0):=(others=>'0');
	
	
	signal href_last  : std_logic;
   signal cnt        : std_logic_vector(1 downto 0)  := (others => '0');
 

begin
	rows	<= std_logic_vector(row);
	cols	<= std_logic_vector(col);
	--we      <= wr_hold(1);

   process(pclk)
   begin
	
      if rising_edge(pclk) then
         -- This is a bit tricky href starts a pixel transfer that takes 3 cycles
         --        Input   | state after clock tick
         --         href   | wr_hold    d_latch           d                 we address  address_next
         -- cycle -1  x    |    xx      xxxxxxxxxxxxxxxx  xxxxxxxxxxxxxxxx  x   xxxx     xxxx
         -- cycle 0   1    |    x1      xxxxxxxxRRRRRGGG  xxxxxxxxxxxxxxxx  x   xxxx     addr
         -- cycle 1   0    |    10      RRRRRGGGGGGBBBBB  xxxxxxxxRRRRRGGG  x   addr     addr
         -- cycle 2   x    |    0x      GGGBBBBBxxxxxxxx  RRRRRGGGGGGBBBBB  1   addr     addr+1

			 if vsync = '1' then 
            href_last<= '0';
				row		<= (others => '0');
				col		<= (others => '0');
            cnt 		<= "00";
         else       
            if href_last = '1' then
               if cnt = "11"  then
                  col <= col+1;
               end if;
               if cnt = "01" then
                  we   <= '1';
					else 
						we	  <= '0';
               end if;
               cnt <= std_logic_vector(unsigned(cnt)+1);
            end if;
         end if;
			href_last <= href;
			d_latch <= d_latch( 7 downto  0) & d;
			dout    <= d_latch;
			
			--rising edge of href
				t<=t(2)& t(1)&t(0)&href;				
				
				if t = "1100" then	-- end line										
					row_rdy 	<= '0';
				elsif t="0001" then	-- start line
					cam_clr 	<= '1';
					col 		<= (others => '0');
				elsif t="1000" then
					row_rdy 	<= '1';
				elsif t="0011" then
					cam_clr 	<= '0';					
					row		<= row + 1;
				end if;
							
         
      end if;
   end process;
end behavioral;