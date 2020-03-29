library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
--iki rowdan her pixeli çıkarıp |r-r|+ |g-g|+ |b-b| işlemi yaparak out a verir
-- shift clk 1 se ve shit row 0 ise R ve L için rin ve lindeki veriyi sıraylar kaydırarak
--diğerine aktarır
--shift row 1 ise sadece L ler kaydırılır ve girişten 0 alır. 
 
entity ad2 is
port(
	  Clk      : IN  STD_LOGIC;	
	  Shift_Clk: IN  STD_LOGIC;	  
	  R_in		:IN  STD_LOGIC_VECTOR(15 downto 0):=(others=>'0');
	  R_out		:OUT STD_LOGIC_VECTOR(15 downto 0):=(others=>'0');
	  L_in		:IN  STD_LOGIC_VECTOR(15 downto 0):=(others=>'0');
	  L_out		:OUT STD_LOGIC_VECTOR(15 downto 0):=(others=>'0');
-----------------------------------------------		  	  
	 
	  O        : OUT STD_LOGIC_VECTOR(5 downto 0)
	 


	  	  
	  );
end entity;


architecture a_ad2 of ad2 is



type array_16bit is array (70 downto 0) of STD_LOGIC_VECTOR(15 downto 0);
type array_8bit  is array (70 downto 0) of STD_LOGIC_VECTOR(7 downto 0);
type array_11bit  is array (70 downto 0) of STD_LOGIC_VECTOR(10 downto 0);

signal L0i:array_16bit;
signal R0i:array_16bit;
signal S0 :array_8bit;
signal A0 :array_11bit;


signal L1i:array_16bit;
signal R1i:array_16bit;
signal S1 :array_8bit;
signal A1 :array_11bit;


signal L2i:array_16bit;
signal R2i:array_16bit;
signal S2 :array_8bit;
signal A2 :array_11bit;

signal oi:array_8bit;
signal D :array_16bit;

signal index 	:std_logic_vector(5 downto 0);
signal out_val :std_logic_vector(7 downto 0);

constant number :integer range 0 to 70:=39;
constant res	 :integer range 0 to 320:=191;


signal L0 :std_logic_vector(15 downto 0);


begin

		o<=index;
		
	

	reg_L1:entity work.reg
	generic map( size  =>  res -1)
	port map
	(
		Clk   => clk,	  
		E		=> Shift_Clk,      
		I     => L0i(0),
		O     => L1i(0)
	);
	
	
	reg_R1:entity work.reg
	generic map( size  =>  res-number)
	port map
	(
		Clk   => clk,	  
		E		=> Shift_Clk,      
		I     => R0i(number),
		O     => R1i(0)
	);
	
	
	reg_L2:entity work.reg
	generic map( size  =>  res -1)
	port map
	(
		Clk   => clk,	  
		E		=> Shift_Clk,      
		I     => L1i(0),
		O     => L2i(0)
	);
	
	
	reg_R2:entity work.reg
	generic map( size  =>  res-number)
	port map
	(
		Clk   => clk,	  
		E		=> Shift_Clk,      
		I     => R1i(number),
		O     => R2i(0)
	);
	
	
   SAD0: 
   for I in 0 to number generate
      A : entity work.absad
		port map
        (clk=>clk,
			L=>L0i(0),
			R=>R0i(I),
			o=>S0(I)
			);
   end generate SAD0;
	
	SAD1: 
   for I in 0 to number generate
      A : entity work.absad
		port map
        (clk=>clk,
			L=>L1i(0),
			R=>R1i(I),
			o=>S1(I)
			);
   end generate SAD1;	
	
	SAD2: 
   for I in 0 to number generate
      A : entity work.absad
		port map
        (clk=>clk,
			L=>L2i(0),
			R=>R2i(I),
			o=>S2(I)
			);
   end generate SAD2;
 

 sum_8_0: 
   for I in 0 to number-7 generate
      M : entity work.sum8
		port map
        (
			clk=>clk,					
			s0=>S0(I),
			s1=>S0(I+1),
			s2=>S0(I+2),
			s3=>S0(I+3),
			s4=>S0(I+4),
			s5=>S0(I+5),
			s6=>S0(I+6),
			s7=>S0(I+7),
			o =>A0(I)
			);
   end generate sum_8_0;
	
sum_8_1: 
   for I in 0 to number-7 generate
      M : entity work.sum8
		port map
        (
			clk=>clk,					
			s0=>S1(I),
			s1=>S1(I+1),
			s2=>S1(I+2),
			s3=>S1(I+3),
			s4=>S1(I+4),
			s5=>S1(I+5),
			s6=>S1(I+6),
			s7=>S1(I+7),
			o =>A1(I)
			);
   end generate sum_8_1;
	
		
sum_8_2: 
   for I in 0 to number-7 generate
      M : entity work.sum8
		port map
        (
			clk=>clk,					
			s0=>S2(I),
			s1=>S2(I+1),
			s2=>S2(I+2),
			s3=>S2(I+3),
			s4=>S2(I+4),
			s5=>S2(I+5),
			s6=>S2(I+6),
			s7=>S2(I+7),
			o =>A2(I)
			);
   end generate sum_8_2;
	
	
		
sum_3: 
   for I in 0 to number-7 generate
      s3 : entity work.sum3
		port map
        (
			clk=>clk,					
			I0=>A0(I),
			I1=>A1(I),
			I2=>A2(I),
			o =>D(I)
			);
   end generate sum_3;

C0 : entity work.index_32x5
	port map( 
    Clk     => cLK,	  
	  B      =>index(4 downto 0),
	  
	  S0      =>D(0)&D(1)&D(2)&D(3),
	  S1      =>D(4)&D(5)&D(6)&D(7),
	  S2      =>D(8)&D(9)&D(10)&D(11),
	  S3      =>D(12)&D(13)&D(14)&D(15),
	 
	  S4      =>D(16)&D(17)&D(18)&D(19),
	  S5      =>D(20)&D(21)&D(22)&D(23),
	  S6      =>D(24)&D(25)&D(26)&D(27),
	  S7      =>D(28)&D(29)&D(30)&D(31)
	 	  	  
	  );	
	
	
	
 process (clk)
 
 begin
 
-- 	for j in 1 to number-7 
-- loop			
--	D(j)<=A0(j);--+A1(i);
-- end loop;
-- for i in 1 to number 
-- loop			
--	D(i)<=A0(i)+A1(i);
-- end loop;
 
if rising_edge(clk) then
	
	if shift_clk='1' then	
			L0i(0)  <=L_in ;
			R0i(0)  <=R_in ;		
			for i in 1 to number loop
				R0i(i) <= R0i(i-1);
				R1i(i) <= R1i(i-1);	
				R2i(i) <= R2i(i-1);
				--Li(i) <= Li(i-1);	
			end loop;		
			L_out<=L0i(0);
			R_out<=R0i(number);
	end if;
	
end if;
		 
end process;

end architecture;