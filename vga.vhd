----------------------------------------------------------------------------------
-- Engineer: Mike Field <hamster@snap.net.nz>
-- 
-- Description: Generate analog 800x600 VGA, double-doublescanned from 19200 bytes of RAM
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity vga is
    Port ( 
      clk         : in  STD_LOGIC;
      vga_red     : out STD_LOGIC_VECTOR(1 downto 0);
      vga_green   : out STD_LOGIC_VECTOR(1 downto 0);
      vga_blue    : out STD_LOGIC_VECTOR(1 downto 0);
      vga_hsync   : out STD_LOGIC;
      vga_vsync   : out STD_LOGIC;
		f_row			: out STD_LOGIC_VECTOR(8 downto 0);
      frame_addr  : out STD_LOGIC_VECTOR(9 downto 0);
      frame_pixel : in  STD_LOGIC_VECTOR(7 downto 0);
		frame_L 		: in  STD_LOGIC_VECTOR(15 downto 0);
		frame_R 		: in  STD_LOGIC_VECTOR(15 downto 0);
		rst		   : out STD_LOGIC
    );
end vga;

architecture Behavioral of vga is
   -- Timing constants
	
	--resolution
   constant hRez       : natural := 720;
   constant vRez       : natural := 480;
	constant Shift_Count: natural := 64;

   constant hMaxCount  : natural := 1056;
   constant hStartSync : natural := 840;
   constant hEndSync   : natural := 968;
   constant vMaxCount  : natural := 628;
   constant vStartSync : natural := 601;
   constant vEndSync   : natural := 605;
   constant hsync_active : std_logic := '1';
   constant vsync_active : std_logic := '1';
	
	signal row		 : unsigned(8 downto 0):=(others=>'0');
	
	signal pixel	 :STD_LOGIC_VECTOR(5 downto 0);
	signal F_pixel  : unsigned(7 downto 0):=(others=>'0');
 
   signal hCounter : unsigned(10 downto 0) := (others => '0');
   signal vCounter : unsigned(9 downto 0)  := (others => '0');
   signal address  : unsigned(9 downto 0)  := (others => '0');
   signal blank : std_logic := '1';
	signal reset : std_logic := '1';

begin
   frame_addr  <= std_logic_vector(address(9 downto 0));
   rst			<= reset;
	f_row			<= std_logic_vector(row);
	F_pixel		<=unsigned(frame_pixel);
   process(clk)
   begin
      if rising_edge(clk) then
         -- Count the lines and rows      
         if hCounter = hMaxCount-1 then
            hCounter <= (others => '0');
			--	row		<= row + 1;
						if vCounter(1) = '1' then
							row		<= row + 2;
							reset		<= not reset;
						end if;
            if vCounter = vMaxCount-1 then
               vCounter <= (others => '0');
            else
               vCounter <= vCounter+1;
            end if;
         else
            hCounter <= hCounter+1;
         end if;
------------------------------------------------
         if blank = '0' then
					
--				if  hCounter<150 then 
					--if reset = '0' then
						vga_red   <= pixel(5 downto 4);
						vga_green <= pixel(3 downto 2);
						vga_blue  <= pixel(1 downto 0); 
--					else
--						vga_red   <= (others => '0');
--						vga_green <= (others => '0');
--						vga_blue  <= (others => '0');
--					end if;
--					--					
--				else
				  
--					vga_red   <= frame_L(15 downto 14) xor frame_R(15 downto 14);
--					vga_green <= frame_L(10 downto 9)  xor frame_R(10 downto 9);
--					vga_blue  <= frame_L(5 downto 4)   xor frame_R(5 downto 4);				
----				end if;
         else
            vga_red   <= (others => '0');
            vga_green <= (others => '0');
            vga_blue  <= (others => '0');
         end if;
 ------------------------------------------------  
         if vCounter  >= vRez then
            address 	<= (others => '0');
				row		<= (others => '0');
            blank 	<= '1';
         else 
            if hCounter  >= 80 and hCounter  < 840 then
              
               if hCounter = 839 then
                  if vCounter(1 downto 0) /= "11" then
                    -- address <= address - 639;
                  else
                    --  address <= address+1;
                  end if;
						
               else  
					
						if hCounter < 80+hRez then
							blank 	<= '0' xor reset;
							

							if hCounter >= 80 and hCounter < 320 + 80 then 
								--reset		<= '0';
								  -- rst			<= reset;
								address 	<= address+1;							
							else
								address 	<= (others => '0');
								blank		<= '1';
							end if;
						else
							address  <= (others => '0');
							blank		<= '1';							
							--reset		<='1';							
                  end if;
               end if;


            else
               blank <= '1';
            end if;
         end if;
------------------------------------------------ 
         -- Are we in the hSync pulse? (one has been added to include frame_buffer_latency)
         if hCounter > hStartSync and hCounter <= hEndSync then
            vga_hSync <= hsync_active;
         else
            vga_hSync <= not hsync_active;
         end if;
------------------------------------------------
         -- Are we in the vSync pulse?
         if vCounter >= vStartSync and vCounter < vEndSync then
            vga_vSync <= vsync_active;
         else
            vga_vSync <= not vsync_active;
         end if;
------------------------------------------------			
      end if;
		
		if F_pixel>0 and F_pixel<4 then
		pixel<="001011";
	elsif F_pixel>=4 and F_pixel<8 then
		pixel<="001111";
	elsif F_pixel>=8 and F_pixel<12 then
		pixel<="001110";
	elsif F_pixel>=12 and F_pixel<16 then
		pixel<="001100";
	elsif F_pixel>=16 and F_pixel<20 then
		pixel<="101100";
	elsif F_pixel>=20 and F_pixel<24 then
		pixel<="111100";
	elsif F_pixel>=24 and F_pixel<28 then
		pixel<="111000";
	elsif F_pixel>=28 and F_pixel<32 then
		pixel<="110000";
	else
		pixel<="000000";
	end if;
	
	
	
	end process;
end Behavioral;