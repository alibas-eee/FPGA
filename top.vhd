library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
 
entity top is
port(
	   clk50       : in    STD_LOGIC;
		
		DRAM_CLK   	: out  STD_LOGIC;
		DRAM_CKE   	: out  STD_LOGIC;
		DRAM_CS_N   : out  STD_LOGIC;
		DRAM_RAS_N  : out  STD_LOGIC;
		DRAM_CAS_N 	: out  STD_LOGIC;
		DRAM_WE_N   : out  STD_LOGIC;
		DRAM_DQM   	: out  STD_LOGIC_VECTOR( 1 downto 0);
		DRAM_ADDR  	: out  STD_LOGIC_VECTOR (12 downto 0);
		DRAM_BA    	: out   STD_LOGIC_VECTOR( 1 downto 0);
		DRAM_DQ    	: inout STD_LOGIC_VECTOR (15 downto 0);
		
		
      OV7670_SIOC  : out   STD_LOGIC;
      OV7670_SIOD  : inout STD_LOGIC;
      OV7670_RESET : out   STD_LOGIC;
      OV7670_PWDN  : out   STD_LOGIC;
      OV7670_VSYNC : in    STD_LOGIC;
      OV7670_HREF  : in    STD_LOGIC;
      OV7670_PCLK  : in    STD_LOGIC;
      OV7670_XCLK  : out   STD_LOGIC;
      OV7670_D     : in    STD_LOGIC_VECTOR(7 downto 0);

		
		OV7670_SIOC_1  : out   STD_LOGIC;
      OV7670_SIOD_1  : inout STD_LOGIC;
      OV7670_RESET_1 : out   STD_LOGIC;
      OV7670_PWDN_1  : out   STD_LOGIC;
      OV7670_VSYNC_1 : in    STD_LOGIC;
      OV7670_HREF_1  : in    STD_LOGIC;
      OV7670_PCLK_1  : in    STD_LOGIC;
      OV7670_XCLK_1  : out   STD_LOGIC;
      OV7670_D_1     : in    STD_LOGIC_VECTOR(7 downto 0);
	  
	  
	  
	   vga_red      	: out   STD_LOGIC_VECTOR(2 downto 1);
	   vga_green    	: out   STD_LOGIC_VECTOR(2 downto 1);
	   vga_blue     	: out   STD_LOGIC_VECTOR(2 downto 1);
	   vga_hsync    	: out   STD_LOGIC;
	   vga_vsync    	: out   STD_LOGIC;
		
 	   DIP			 	: in	  STD_LOGIC_VECTOR( 3 downto 0);		
		TX_LINE			: out   STD_LOGIC
	  
	  );
end entity;


architecture a_top of top is

signal L_row		: std_logic_vector(15 downto 0);
signal R_row		: std_logic_vector(15 downto 0);
signal L_rowi		: std_logic_vector(15 downto 0);
signal R_rowi		: std_logic_vector(15 downto 0);

signal frame		: std_logic_vector(14 downto 0):=(others=>'0');
signal reset	   : STD_LOGIC;
signal shift		: std_logic:='0';
signal Dis_En		: std_logic:='1';
signal Dis_Rst		: STD_LOGIC;
signal address 	: std_logic_vector(9 downto 0);
signal data			: std_logic_vector(7 downto 0);
signal fifo_out	: std_logic_vector(7 downto 0);

signal sRow	    	: STD_LOGIC;
signal sClk      	: STD_LOGIC;
signal Ram_En    	: STD_LOGIC;


type array_16bit is array (31 downto 0) of STD_LOGIC_VECTOR(15 downto 0);
signal R_reg:array_16bit;--memory
signal L_reg:array_16bit;--memory

type array_8bit is array (350 downto 0) of STD_LOGIC_VECTOR(7 downto 0);
signal D:array_8bit;--disparity
signal T:array_8bit;--temp
signal A:array_8bit;--ad
signal M:array_8bit;--memory

signal uRam_E   	: STD_LOGIC;
signal uRam_Waddr	: STD_LOGIC_VECTOR (8 DOWNTO 0);
signal uRam_Wdata	: STD_LOGIC_VECTOR (4 DOWNTO 0);
signal uRam_Raddr	: STD_LOGIC_VECTOR (8 DOWNTO 0);
signal uRam_Rdata	: STD_LOGIC_VECTOR (4 DOWNTO 0);

signal tx_busy		: STD_LOGIC;
signal tx_start	: STD_LOGIC;
signal tx_data		: STD_LOGIC_VECTOR (7 DOWNTO 0);

signal frame_addr	: STD_LOGIC_VECTOR (9 DOWNTO 0);
signal frame_pixel: STD_LOGIC_VECTOR (7 DOWNTO 0);
signal frame_row	: STD_LOGIC_VECTOR (8 DOWNTO 0);
signal frame_row_sd	: STD_LOGIC_VECTOR (8 DOWNTO 0);
signal clk:std_logic;
----------------------------------------------------
-- signal frame_addr  : std_logic_vector(15 downto 0);
-- signal frame_pixel : std_logic_vector(7 downto 0);

   signal capture_addr_0  : std_logic_vector(14 downto 0);
   signal capture_data_0  : std_logic_vector(7 downto 0);
	
	signal capture_addr_1  : std_logic_vector(14 downto 0);
   signal capture_data_1  : std_logic_vector(7 downto 0);
	
   signal capture_we_0    : std_logic;
	signal capture_we_1    : std_logic;
	signal capture_we    : std_logic;

   signal resend : std_logic;
   signal config_finished : std_logic;
	signal index  : std_logic_vector(5 downto 0);
	
----------------------SDRAM---------------------------------	
	
signal wr_data :std_logic_vector(31 downto 0):=(others =>'0');
signal rd_data:std_logic_vector(31 downto 0):=(others =>'0');
signal wr_addr 	:std_logic_vector(24 downto 0):=(others =>'0');
signal rd_addr 	:std_logic_vector(24 downto 0):=(others =>'0');
signal sd_address		:STD_LOGIC_VECTOR(24 DOWNTO 0);

signal wr_enable	:std_logic:='0';
signal rd_enable	:std_logic:='0';
signal rst_n		:std_logic:='0';
signal busy			:std_logic:='0';
signal clk_100		:std_logic:='0';
signal clk_50		:std_logic:='0';
signal rd_rdy		:std_logic:='0';
signal rd_ack		:std_logic:='0';
signal rd_ready 	:std_logic:='0';
signal wr_ready 	:std_logic:='0';	
	
	------------------------camL--------------------------
signal sd_col_l		   :	STD_LOGIC_VECTOR(9  downto 0);
signal pixel_col_l		:	STD_LOGIC_VECTOR(9  downto 0);
signal cam_pixel_l		:  STD_LOGIC_VECTOR(15 downto 0);
signal cam_req_l 			:  STD_LOGIC;
signal pixel_row_l		:	STD_LOGIC_VECTOR(8  downto 0);	
signal sd_pixel_l			:  STD_LOGIC_VECTOR(15 downto 0);
signal sd_req_l 			:  STD_LOGIC;
signal row_rdy_l 			:  STD_LOGIC;
signal cam_clr_l			: 	STD_LOGIC;
------------------------camR--------------------------
signal sd_col_r		   :	STD_LOGIC_VECTOR(9  downto 0);
signal pixel_col_r		:	STD_LOGIC_VECTOR(9  downto 0);
signal cam_pixel_r		:  STD_LOGIC_VECTOR(15 downto 0);
signal cam_req_r 			:  STD_LOGIC;
signal pixel_row_r		:	STD_LOGIC_VECTOR(8  downto 0);	
signal sd_pixel_r			:  STD_LOGIC_VECTOR(15 downto 0);
signal sd_req_r 			:  STD_LOGIC;
signal row_rdy_r 			:  STD_LOGIC;
signal cam_clr_r			: 	STD_LOGIC;

------------------------frame_ram_L-------------------------
signal frame_col_l		:	STD_LOGIC_VECTOR(9  downto 0);
signal frame_data_l		:  STD_LOGIC_VECTOR(15 downto 0);
signal frame_we_l			:  STD_LOGIC;

------------------------frame_ram_R-------------------------
signal frame_col_r		:	STD_LOGIC_VECTOR(9  downto 0);
signal frame_data_r		:  STD_LOGIC_VECTOR(15 downto 0);
signal frame_we_r			:  STD_LOGIC;
	
	
signal pixel				: std_logic_vector(3 downto 0);
signal tx_l					: 	STD_LOGIC;
	
begin
clk		<= clk50;
R_reg(0)	<= R_row;--(7 downto 5)&"00"&R_row(4 downto 2)&"000"&R_row(1 downto 0)&"000";
L_reg(0)	<= L_row;--(7 downto 5)&"00"&L_row(4 downto 2)&"000"&L_row(1 downto 0)&"000";

clk_50	<= clk50;

pixel		<= R_ROW(15 downto 12) AND L_ROW(15 downto 12);
tx_line	<= tx_l;
----------------------CAM-------------------------
ram_L: entity work.cam_ram
	port map
	(
		data				=> cam_pixel_l,
		rdaddress		=> sd_col_l,
		rdclock			=> clk_100,
		rden				=> sd_req_l,
		wraddress		=> pixel_col_l,
		wrclock			=> OV7670_PCLK,
		wren				=> cam_req_l,
		q					=> sd_pixel_l	
	);
	
ram_R: entity work.cam_ram
	port map
	(
		data				=> cam_pixel_r,
		rdaddress		=> sd_col_r,
		rdclock			=> clk_100,
		rden				=> sd_req_r,
		wraddress		=> pixel_col_r,
		wrclock			=> OV7670_PCLK_1,
		wren				=> cam_req_r,
		q					=> sd_pixel_r
		);	
		
----------------CAPTURE---------------------
captureR: entity work.ov7670_capture3 
PORT MAP(
      pclk  => OV7670_PCLK_1,
      vsync => OV7670_VSYNC_1,
      href  => OV7670_HREF_1,
      d     => OV7670_D_1,
      rows	=> pixel_row_r,
		cols	=> pixel_col_r,
		dout  => cam_pixel_r,
      we    => cam_req_r,
		row_rdy=> row_rdy_r,
		cam_clr=> cam_clr_r
   );
	
captureL: entity work.ov7670_capture3
PORT MAP(
      pclk  => OV7670_PCLK,
      vsync => OV7670_VSYNC,
      href  => OV7670_HREF,		
      d     => OV7670_D,
      rows	=> pixel_row_l,
		cols	=> pixel_col_l,
		dout  => cam_pixel_l,
      we    => cam_req_l,
		row_rdy=> row_rdy_l,
		cam_clr=> cam_clr_l
   );	
	
----------------CAM CONTROL----------------------		
controllerL: entity work.ov7670_controller 
generic map(sel  =>'1')--0 L
PORT MAP(
      clk   => clk_50,
      sioc  => ov7670_sioc,
      resend => '0',
     -- config_finished => config_finished,
      siod  => ov7670_siod,
      pwdn  => OV7670_PWDN,
      reset => OV7670_RESET,
      xclk  => OV7670_XCLK
   );

controllerR: entity work.ov7670_controller 
generic map(sel  =>'0')
PORT MAP(
      clk   => clk_50,
      sioc  => ov7670_sioc_1,
      resend => '0',
     -- config_finished => config_finished,
      siod  => ov7670_siod_1,
      pwdn  => OV7670_PWDN_1,
      reset => OV7670_RESET_1,
      xclk  => OV7670_XCLK_1
   );			

-----------------------MEMORY-----------------------------

u1: entity work.ui
port map
(
		CLK	      => clk_100,
		address		=> sd_address,
		wr_data		=> wr_data,
		wr_enable	=> wr_enable,
		
		rd_data		=> rd_data,
		rd_ready		=> rd_ready,
		wr_ready		=> wr_ready,
		rd_enable	=> rd_enable,
		busy			=> busy,
		
		PIXEL_READ_L	=> sd_req_l,
		PIXEL_DATA_L	=> sd_pixel_l,
		PIXEL_ROW_L		=> pixel_row_l,
		PIXEL_RDY_L		=> row_rdy_l,
		PIXEL_COL_L		=> sd_col_l,
		
		PIXEL_READ_R 	=> sd_req_r,
		PIXEL_DATA_R	=> sd_pixel_r,
		PIXEL_ROW_R		=> pixel_row_r,
		PIXEL_RDY_R		=> row_rdy_r,
		PIXEL_COL_R		=> sd_col_r,
		
		FRAME_ROW		=> frame_row_sd,
			
		FRAME_DATA_L	=> frame_data_l,
		FRAME_COL_L	   => frame_col_l,
		FRAME_WE_L		=> frame_we_l,
			
		FRAME_DATA_R	=> frame_data_r,
		FRAME_COL_R	   => frame_col_r,
		FRAME_WE_R		=> frame_we_r

);

----------------------CAM-------------------------
frame_L: entity work.cam_ram
	port map
	(	
		rdaddress		=> address,-- frame(9 downto 0),
		rdclock			=> clk_50,
		rden				=> '1',
		q					=> L_row,	
		
		data				=> frame_data_l,
		wraddress		=> frame_col_l,
		wrclock			=> clk_100,
		wren				=> frame_we_l				
	);
	
frame_R: entity work.cam_ram
	port map
	(	
		rdaddress		=> address,-- frame(9 downto 0),
		rdclock			=> clk_50,
		rden				=> '1',
		q					=> R_row,	
		
		data				=> frame_data_r,
		wraddress		=> frame_col_r,
		wrclock			=> clk_100,
		wren				=> frame_we_r				
	);
	
	
row_block: entity work.row_block
	port map
	(	
		data				=> frame_row,
		rdaddress		=> "0000",-- frame(9 downto 0),
		rdclock			=> clk_100,
		
		wraddress		=> "0000",
		wrclock			=> clk_50,
		wren				=> '1',
		q					=> frame_row_sd		
	);	
		
------------------------------------------------------------
sd: entity work.sdram_controller
port map(

		address				=>sd_address,
		data_in				=>wr_data,
		req_write	 		=>wr_enable,
		req_read				=>rd_enable,
		data_out				=>rd_data,
		data_out_valid		=>rd_ready,
		data_in_valid		=>wr_ready,
		busy					=>busy,
		CLOCK_50			 	=>CLK_50,
		
	
		DRAM_ADDR			=>DRAM_ADDR,
		DRAM_BA				=>DRAM_BA,
		DRAM_DQ				=>DRAM_DQ ,
		DRAM_CKE				=>DRAM_CKE,
		DRAM_CS_N			=>DRAM_CS_N,
		DRAM_RAS_N			=>DRAM_RAS_N,
		DRAM_CAS_N			=>DRAM_CAS_N,
		DRAM_WE_N			=>DRAM_WE_N,
		DRAM_DQM				=>DRAM_DQM,
	   DRAM_CLK				=>DRAM_CLK
);

p0: entity work.pll
port map(
		inclk0		=>clk_50,
		c0				=>clk_100 

);



--------------------------------------------------------
I_vga: entity work.vga2 
PORT MAP(
      clk         => clk,
      vga_red     => vga_red ,
      vga_green   => vga_green,
      vga_blue    => vga_blue,
      vga_hsync   => vga_hsync,
      vga_vsync   => vga_vsync,
		f_row			=> frame_row,
      frame_addr  => frame_addr,
      frame_pixel (5 downto 0) => index,--R_ROW(15 downto 13)&L_ROW(10 downto 8)&L_ROW(5 downto 4),--frame_pixel,-- index,--frame_pixel,  L_row(15 downto 10),
		frame_L		=> R_ROW,
		frame_R		=> L_ROW,
		rst			=> reset
   );


Ctrl:entity work.controller
port map(
	  Clk     	=>clk,	
	  Reset   	=>reset,	
-----------------------------------------------	  
	  shft  		=>sClk,
	  Ram_En	 	=>Ram_EN,
	  Ram_addr	=>address
);
	


ad : entity work.AD2
port map(
	clk	=>clk,
	Shift_Clk=>sClk,
	R_in	=>R_reg(0),
	L_in	=>L_reg(0),
	O		=>index
);


S: entity work.shrink
port map(
	Clk    => clk,	  
	E	    => Ram_en,
	--Rst	 => reset,
	f_row	 => frame_row(7 downto 0),
	I      => index (4 downto 0),
	D      => uRam_Wdata,
	A      => uRam_Waddr,
	R      => uRam_E 	  	  
);
 
Ram:entity work.ram
port map(
	clock		=> clk,
	data 		=> uRam_Wdata,
	rdaddress=> uRam_Raddr,
	wraddress=> uRam_Waddr,
	wren		=> uRam_E,
	q			=> uRam_Rdata
); 

Uart: entity work.uart
port map(
	CLK      => clk,
	TX_BUSY 	=> tx_busy,
	TX_START	=> tx_start,
	TX_DATA	=> tx_data,
	RAM_ADDR	=> uRam_Raddr,
	RAM_DATA	=> uRam_Rdata
);

TX : entity work.TX
generic map
( sel      =>   "111")
port map( 
	Clk      => clk,
	Start    => tx_start,
	TX_BUSY  => tx_busy,
	TX_DATA  => tx_data,
	TX_LINE  => tx_l 
);

	
end Architecture;