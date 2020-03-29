library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity ui is
    Port ( 
			CLK      : in  STD_LOGIC;

			address			: OUT STD_LOGIC_VECTOR(24 DOWNTO 0);
			wr_data			: OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
			wr_enable		: OUT STD_LOGIC;
			
			rd_data			: in  STD_LOGIC_VECTOR(31 DOWNTO 0);
			rd_ready			: in  STD_LOGIC;
			wr_ready			: in  STD_LOGIC;
			rd_enable		: OUT STD_LOGIC;
			busy				: in  STD_LOGIC;
			
			PIXEL_READ_L 	: out STD_LOGIC;
			PIXEL_DATA_L	: in  std_logic_vector(15 downto 0);
			PIXEL_ROW_L		: in  std_logic_vector(8 downto 0);
			PIXEL_COL_L		: out std_logic_vector(9 downto 0);
			PIXEL_RDY_L		: in  STD_LOGIC;
			
			PIXEL_READ_R 	: out STD_LOGIC;
			PIXEL_DATA_R	: in  std_logic_vector(15 downto 0);
			PIXEL_ROW_R		: in  std_logic_vector(8 downto 0);
			PIXEL_Col_R		: out std_logic_vector(9 downto 0);
			PIXEL_RDY_R		: in  STD_LOGIC;
			
			FRAME_ROW		: in  std_logic_vector(8 downto 0);
			
			FRAME_DATA_L	: out std_logic_vector(15 downto 0);			
			FRAME_COL_L	   : out std_logic_vector(9 downto 0);
			FRAME_WE_L		: out STD_LOGIC;
			
			FRAME_DATA_R	: out std_logic_vector(15 downto 0);			
			FRAME_COL_R	   : out std_logic_vector(9 downto 0);
			FRAME_WE_R		: out STD_LOGIC
         );
end ui;


architecture a_ui of ui is

signal wr_en,rd_en :STD_LOGIC:='0';

signal wr_count_r	:integer range 0 to 4;
signal wr_count_l	:integer range 0 to 4;
signal rd_count_r	:integer range 0 to 4;
signal rd_count_l	:integer range 0 to 4;

signal read_count_r		:integer range 0 to 1023;
signal read_count_l	:integer range 0 to 1023;
signal write_count_l	:integer range 0 to 1023;
signal write_count_r	:integer range 0 to 1023;

signal col_r		:integer range 0 to 1023;
signal col_l		:integer range 0 to 1023;

signal f_col_r		:integer range 0 to 1023;
signal f_col_l		:integer range 0 to 1023;

signal c_row_r		:std_logic_vector(8 downto 0);
signal c_row_l		:std_logic_vector(8 downto 0);
signal v_row		:std_logic_vector(8 downto 0);

signal f_row		:std_logic_vector(8 downto 0);
signal v_row2		:std_logic_vector(8 downto 0);

signal state		:std_logic_vector(1 downto 0);
signal state2		:std_logic_vector(1 downto 0);

signal row_bits	:std_logic_vector(1 downto 0);
signal cam_bits_r	:std_logic_vector(1 downto 0);
signal cam_bits_l	:std_logic_vector(1 downto 0);

signal RD_RDY  	:std_logic_vector(1 downto 0);
signal WR_RDY		:std_logic_vector(1 downto 0);

signal wr_hold_r	:std_logic:='0';
signal wr_hold_l	:std_logic:='0';
signal rd_hold_r		:std_logic:='0';
signal rd_hold_l	:std_logic:='0';

signal wr_flag_r	:std_logic:='0';
signal wr_flag_l	:std_logic:='0';
signal rd_flag_r		:std_logic:='0';
signal rd_flag_l	:std_logic:='0';

signal r_fifo_rdy_r		:std_logic:='0';
signal r_fifo_rdy_l	:std_logic:='0';
signal w_fifo_rdy_l	:std_logic:='0';
signal w_fifo_rdy_r	:std_logic:='0';


begin 


wr_enable	<= wr_en;
rd_enable	<= rd_en;
PIXEL_COL_L	<=	std_logic_vector( to_unsigned(col_l,10));
PIXEL_COL_R	<=	std_logic_vector( to_unsigned(col_r,10));

FRAME_COL_L	<= std_logic_vector( to_unsigned(f_col_l,10));
FRAME_COL_R	<= std_logic_vector( to_unsigned(f_col_r,10));

process (CLK)
begin



	if rising_edge(CLK) then 
	
		cam_bits_l 	<= cam_bits_l(0)	&	PIXEL_RDY_L;
		cam_bits_r 	<= cam_bits_r(0)	&	PIXEL_RDY_R;
		row_bits		<= row_bits(0)		& 	FRAME_ROW(1);
		rd_rdy		<= rd_rdy(0)		&	rd_ready;
		wr_rdy		<= wr_rdy(0)		&	wr_ready;		
		
	-----------------------------------------------		
			if rd_flag_r	= '1' and wr_hold_l 	= '0' and wr_hold_r = '0' and rd_hold_l = '0' then
				rd_hold_r 	<= '1';
		elsif rd_flag_l	= '1' and wr_hold_l 	= '0' and wr_hold_r = '0' and rd_hold_r 	= '0' then
				rd_hold_l	<= '1';	
		elsif wr_flag_l	= '1' and rd_hold_r 	= '0' and wr_hold_r = '0' and rd_hold_l = '0' then
				wr_hold_l 	<= '1';
		elsif wr_flag_r	= '1' and rd_hold_r 	= '0' and wr_hold_l = '0' and rd_hold_l = '0' then
				wr_hold_r 	<= '1';
		end if;	
		

	------------READ------------
		if rd_rdy="01" then	
			if rd_hold_r ='1' then	
				read_count_r  		<= read_count_r + 2;
				if read_count_r 	< 320 then
					r_fifo_rdy_r	<= '1';
					rd_count_r		<=  0 ;
				else
					r_fifo_rdy_r	<= '0';
					rd_flag_r		<= '0';
					rd_hold_r 		<= '0';
				end if;
			elsif rd_hold_l ='1' then	
				read_count_l  		<= read_count_l + 2;
				if read_count_l 	< 320 then
					r_fifo_rdy_l	<= '1';
					rd_count_l		<=  0 ;
				else
					r_fifo_rdy_l	<= '0';
					rd_flag_l		<= '0';
					rd_hold_l 		<= '0';
				end if;
			else
					r_fifo_rdy_l	<= '0';
					rd_flag_l		<= '0';
					rd_hold_l 		<= '0';
					r_fifo_rdy_r	<= '0';
					rd_flag_r		<= '0';
					rd_hold_r 		<= '0';
			end if;
		end if;	
		
-----------WRITE----
		if wr_rdy="01" then	
			if wr_hold_l ='1' then	
				write_count_l  	<= write_count_l + 2;
				if write_count_l < 320 then
					w_fifo_rdy_l	<= '1';
					wr_count_l 		<=  0 ;
				else
					w_fifo_rdy_l	<= '0';
					wr_flag_l		<= '0';
					PIXEL_READ_L 	<= '0';
					wr_hold_l 		<= '0';
				end if;
			elsif wr_hold_r ='1' then
				write_count_r  	<= write_count_r + 2;
				if write_count_r < 320 then
					w_fifo_rdy_r	<= '1';
					wr_count_r 		<=  0 ;
				else
					rd_flag_l		<= '1';--read after rigth image 
				
					w_fifo_rdy_r	<= '0';
					wr_flag_r		<= '0';
					PIXEL_READ_R 	<= '0';
					wr_hold_r 		<= '0';
				end if;			
			else
					w_fifo_rdy_r	<= '0';
					wr_flag_r		<= '0';
					PIXEL_READ_R 	<= '0';
					wr_hold_r 		<= '0';
					w_fifo_rdy_l	<= '0';
					wr_flag_l		<= '0';
					PIXEL_READ_L 	<= '0';
					wr_hold_l 		<= '0';
			
			end if;
		end if;
	

	
--------WRITE FIFO(CAM_L)----------		
		if  w_fifo_rdy_l ='1' then			
				if wr_count_l 	= 0 then
					wr_count_l 		<=  1;
					wr_flag_l 		<= '0';
					col_l				<= col_l + 1;
					PIXEL_READ_L 	<= '1';
					wr_data(15 downto 0)<=PIXEL_DATA_L;	
				elsif wr_count_l	= 1 then
					wr_count_l 		<=  2;
					wr_flag_l 		<= '1';
					col_l				<= col_l + 1;
					PIXEL_READ_L 	<= '1';
					w_fifo_rdy_l	<= '0';
					wr_data(31 downto 16)<=PIXEL_DATA_L;
				else
					PIXEL_READ_l 	<= '0';					
				end if;
		else
			PIXEL_READ_L 	<= '0';
		end if;

--------WRITE FIFO(CAM_R)----------		
		if  w_fifo_rdy_r ='1' then			
				if wr_count_r 	= 0 then
					wr_count_r 		<=  1;
					wr_flag_r 		<= '0';
					col_r				<= col_r + 1;
					PIXEL_READ_r 	<= '1';
					wr_data(15 downto 0)<=PIXEL_DATA_r;	
				elsif wr_count_r	= 1 then
					wr_count_r 		<=  2;
					wr_flag_r 		<= '1';
					col_r				<= col_r + 1;
					PIXEL_READ_r 	<= '1';
					w_fifo_rdy_r	<= '0';
					wr_data(31 downto 16)<=PIXEL_DATA_r;	
				else
					PIXEL_READ_r 	<= '0';
				end if;
		else
			PIXEL_READ_r 	<= '0';
		end if;

		
	--------READ FIFO(CAM_L)----------		
		if  r_fifo_rdy_l ='1' then			
				if rd_count_l 	= 0 then
					rd_count_l 		<=  1;
					rd_flag_l 		<= '0';
					f_col_l			<= f_col_l + 1;
					FRAME_WE_L	 	<= '1';
					frame_data_l	<= rd_data(15 downto 0);	
				elsif rd_count_l	= 1 then
					rd_count_l 		<=  2;
					rd_flag_l 		<= '1';
					f_col_l			<= f_col_l + 1;
					FRAME_WE_L 		<= '1';
					r_fifo_rdy_l	<= '0';
					frame_data_l	<= rd_data(31 downto 16);
				else
					FRAME_WE_L 	<= '0';					
				end if;
		else
			FRAME_WE_L 	<= '0';
		end if;	
--------READ FIFO(CAM_R)----------		
		if  r_fifo_rdy_R ='1' then			
				if rd_count_R 	= 0 then
					rd_count_R 		<=  1;
					rd_flag_R 		<= '0';
					f_col_R			<= f_col_R + 1;
					FRAME_WE_R	 	<= '1';
					frame_data_R	<= rd_data(15 downto 0);	
				elsif rd_count_R	= 1 then
					rd_count_R 		<=  2;
					rd_flag_R 		<= '1';
					f_col_R			<= f_col_R + 1;
					FRAME_WE_R 		<= '1';
					r_fifo_rdy_R	<= '0';
					frame_data_R	<= rd_data(31 downto 16);
				else
					FRAME_WE_R 	<= '0';					
				end if;
		else
			FRAME_WE_R 	<= '0';
		end if;	

	

		if busy='0' then
				if wr_flag_r ='1' AND wr_hold_r='1' then				
					address(19 downto 0)<= '1'&c_row_r&std_logic_vector( to_unsigned(write_count_r,10));
					wr_en			<='1';	
					rd_en			<='0';
					wr_flag_r	<='0';
			elsif wr_flag_l ='1' AND wr_hold_l='1' then				
					address(19 downto 0)<= '0'&c_row_l&std_logic_vector( to_unsigned(write_count_l,10));
					wr_en			<='1';	
					rd_en			<='0';
					wr_flag_l	<='0';
			elsif rd_flag_r  ='1' AND rd_hold_r='1' then
					address(19 downto 0)<= '1'&f_row & std_logic_vector( to_unsigned(read_count_r,10));
					wr_en			<='0';	
					rd_en			<='1';
					rd_flag_r	<='0';
			elsif rd_flag_l ='1' AND rd_hold_l='1' then
					address(19 downto 0)<= '0'&f_row & std_logic_vector( to_unsigned(read_count_l,10));
					wr_en			<='0';	
					rd_en			<='1';
					rd_flag_l	<='0';			
			end if;
		else
					--wr_en		<='0';
					--rd_en		<='0';
		end if;
-----------------------------	cam row changed	
		if cam_bits_r = "01" then
			wr_flag_r		<= '1';
			write_count_r  <=  0 ;
			col_r				<=  0 ;
			c_row_r			<= PIXEL_ROW_R;
		end if;	
	
		if cam_bits_l = "01" then
			wr_flag_l		<= '1';
			write_count_l  <=  0 ;
			col_l				<=  0 ;
			c_row_l			<= PIXEL_ROW_L;
		end if;	
		
		-----------------------	vga row changed	
		if row_bits(1) /= row_bits(0) then
			rd_flag_r		<= '1';			
			f_col_r			<=  0 ;			
			read_count_r 	<=  0 ;
			
			--rd_flag_l		<= '1';
			f_col_l			<=  0 ;			
			read_count_l	<=  0 ;
			
			f_row				<= FRAME_ROW;
		end if;
		
------------------------			
	
	
	
	end if;
	
	
	
	
end process;

end architecture;
