library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
USE ieee.numeric_std.ALL; 

Entity chuck is
	Port (
		-- system clock
		CLKIN		 : in std_logic;
		CPU_phi2	 : out std_logic;
		
		-- address bus
		CPU_a			 : in std_logic_vector (15 downto 0);	-- Address bus 
		EXT_a			 : out std_logic_vector(18 downto 14);   -- extended address bus EXT_a14-EXT_a18
		
		-- data bus
		CPU_d			 : inout std_logic_vector (7 downto 0); 
		
		-- control signals
		RESET     : in std_logic;  	-- reset line
		CPU_rw    : in std_logic;  	-- RW pin of 6502
		CPU_rdy	 : out std_logic; 	-- RDY signal for generating wait states
		RD			 : out std_logic; 	-- read access
		WR			 : out std_logic; 	-- write access
		
		
		-- chip select for memory
		CS_ROM    : out std_logic; 	-- CS signal for ROM at $e000-$ffff 
		CS_RAM  	 : out std_logic; 	-- CS for ram 
		
		-- chip select for peripherals
		CS_UART   : out std_logic;  	
		CS_VIA    : out std_logic;  	
		--CSR_VDP   : out std_logic;  -- VDP read
		--CSW_VDP   : out std_logic;  -- VDP write
		CS_VDP   : out std_logic;  -- VDP 
		
		CS_OPL    : out std_logic  -- OPL2			
	);

end;

Architecture chuck_arch of chuck is
	signal clk: std_logic;
	
	type t_banktable is array (0 to 3) of std_logic_vector(5 downto 0);
	signal INT_banktable : t_banktable;
	
	signal rdyclk: std_logic;
	
	signal cs_rom_sig: std_logic;
	signal cs_ram_sig: std_logic;

	signal cs_uart_sig: std_logic;
	signal cs_via_sig: std_logic;
	signal cs_vdp_sig: std_logic;

--	signal csr_vdp_sig: std_logic;
--	signal csw_vdp_sig: std_logic;
	signal cs_opl_sig: std_logic;
--	signal cs_io01_sig: std_logic;
--	signal cs_io02_sig: std_logic;
	
	signal d_out: std_logic_vector(7 downto 0);
	signal d_in:  std_logic_vector(7 downto 0);
	
	signal EXT_a_sig: std_logic_vector(18 downto 14); 
	
	signal reg_select: std_logic;
	signal io_select: std_logic;
	signal reg_addr: std_logic_vector(1 downto 0);
	signal is_read: std_logic;
	signal rdy_sig: std_logic;
begin
	-- inputs
 	clk		<= CLKIN;
	d_in 		<= CPU_d;	

	-- bidirectional
	-- make data bus output tristate when not a qualified read
	CPU_d 	<= d_out when (is_read='1') else (others => 'Z');

	
	-- outputs
	EXT_a(18 downto 14) <= EXT_a_sig;
	CPU_phi2		<= clk;
	
	RD 			<= CPU_rw nand clk;
	WR 			<= not CPU_rw nand clk;
	
	CPU_rdy		<= rdy_sig;
	
	cs_uart 		<= cs_uart_sig;
	cs_via  		<= cs_via_sig;
--	csr_vdp 		<= csr_vdp_sig;
--	csw_vdp 		<= csw_vdp_sig;
	cs_vdp 		<= cs_vdp_sig;
	
	cs_opl  		<= cs_opl_sig;
	CS_ROM  		<= cs_rom_sig;
	cs_ram  		<= cs_ram_sig;
	
	-- helpers
	-- qualified read?
	is_read 		<= reg_select and clk and CPU_rw;
	
	io_select	<= '1' when (CPU_a(15 downto 8)) = "00000010" and CPU_a(7) = '0' else '0';				-- $0200 - $027f
	-- internal register selected ($0230 - $023f)
	reg_select  <= '1' when (CPU_a(15 downto 4) = "000000100011") else '0';						-- $0230
	
	reg_addr 	<= CPU_a(1 downto 0);
	
	-- cpu register section
	-- cpu read
	cpu_read: process (is_read, reg_addr, INT_banktable )
	begin
		if (is_read = '1') then 
			D_out(4 downto 0) <= INT_banktable(conv_integer(reg_addr))(4 downto 0);
			D_out(7) 			<= INT_banktable(conv_integer(reg_addr))(5);
		else
			D_out <= (others => '0');
		end if;
	end process;

	-- cpu write 
	cpu_write: process(reset, reg_select, reg_addr, clk, CPU_rw, D_in)
	begin
		if (reset = '0') then
			INT_banktable(0) <= "000000"; -- Bank $00
			INT_banktable(1) <= "000001"; -- Bank $01
			INT_banktable(2) <= "000010"; -- Bank $02
			INT_banktable(3) <= "100000"; -- Bank $80 (ROM)
			
		elsif (falling_edge(clk) and reg_select='1' and CPU_rw='0') then
			INT_banktable(conv_integer(reg_addr))(4 downto 0) <= D_in(4 downto 0);
			INT_banktable(conv_integer(reg_addr))(5) <= D_in(7);
		end if;
	end process;

 
	-- wait state generator
	
	rdygen: process(RESET, clk, rdyclk)
	begin
		if (RESET = '0') then
			rdyclk <= '0';
		elsif rising_edge(clk) then
			rdyclk <= not rdyclk;
		end if;
	end process;
	
	rdy_sig			<= '0' when (rdyclk = '1' and (CS_ROM_sig = '0' or CS_OPL_sig = '0' or CS_VDP_sig = '0') ) else 'Z';

		
	-- io area decoding
	
	CS_UART_sig    <= '0' when (CPU_a(15 downto 4) = "000000100000") else '1'; 					-- $0200		
	CS_VIA_sig     <= '0' when (CPU_a(15 downto 4) = "000000100001") else '1'; 					-- $0210
	
--	CSR_VDP_sig		<= '0' when (CPU_a(15 downto 4) = "000000100010") and (CPU_rw = '1') else '1'; 	-- $0220	
--	CSW_VDP_sig		<= '0' when (CPU_a(15 downto 4) = "000000100010") and (CPU_rw = '0') else '1'; 	-- $0220	
	CS_VDP_sig		<= '0' when (CPU_a(15 downto 4) = "000000100010") else '1'; 	-- $0220	

	CS_OPL_sig		<= '0' when (CPU_a(15 downto 4) = "000000100100") else '1';  					-- $0240
	
	-- extended address bus
	EXT_a_sig 		<= INT_banktable(conv_integer(CPU_a(15 downto 14)))(4 downto 0);
	cs_rom_sig		<= '0' when io_select = '0' and INT_banktable(conv_integer(CPU_a(15 downto 14)))(5) = '1' else '1';
	cs_ram_sig		<= '0' when io_select = '0' and INT_banktable(conv_integer(CPU_a(15 downto 14)))(5) = '0' else '1';

End chuck_arch;