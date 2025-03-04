library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;
use ieee.numeric_std.all;

entity divider16x16_tb is
end divider16x16_tb;

architecture behavior of divider16x16_tb is 

	component divider16x16b is
		generic(
			WIDTH 		: INTEGER RANGE 0 TO 32 := 8
		);
		port (
			clk         : in std_logic;
		dividend    	: in std_logic_vector(WIDTH - 1 downto 0);
		divider     	: in std_logic_vector(WIDTH - 1 downto 0);
		quotient    	: out std_logic_vector(WIDTH - 1 downto 0); -- quotient of division
		remainder   	: out std_logic_vector(WIDTH - 1 downto 0); -- remainder of division
		wr_valid    	: in std_logic;
		rd_valid		: out std_logic
		);
	end component;
	
	constant width_divider : integer := 16;
	
	signal dividend_random : std_logic_vector(width_divider-1 downto 0) := x"E0D0";
	-- signal dividend_random : integer range 0 to 65535 := 0;
	signal divider_random  : std_logic_vector(width_divider-1 downto 0)  := x"00C0";
	
	
	
	signal tb_clk 			: STD_LOGIC := '0';
	signal tb_dividend    	: std_logic_vector(width_divider - 1 downto 0);
	signal tb_divider     	: std_logic_vector(width_divider - 1 downto 0);
	signal tb_quotient    	: std_logic_vector(width_divider - 1 downto 0);
	signal tb_remainder   	: std_logic_vector(width_divider - 1 downto 0);
	signal tb_wr_valid    	: std_logic := '0';
	signal tb_rd_valid		: std_logic := '0';
	signal cycler			: std_logic_vector( width_divider + 8 -1 downto 0) := X"000001";
	
	signal divident_clk		: std_logic := '0';
begin 

	uut: divider16x16b
		generic map(
			WIDTH => width_divider
		)
		port map(
			clk         => tb_clk 		,
			dividend    => tb_dividend  ,
			divider     => tb_divider   ,
			quotient    => tb_quotient  ,
			remainder   => tb_remainder ,
			wr_valid    => tb_wr_valid  ,
			rd_valid	=> tb_rd_valid	
		);

	
	
	-- tb_wr_valid <= divident_clk;
	
	clk_gen: process
	begin
		tb_clk <= not tb_clk; 
		wait for 5 ns;
	end process;

	
	
	random_gen: process(tb_clk)  -- left shift values
	begin
		if rising_edge(tb_clk) then
			dividend_random <= dividend_random(dividend_random'LEFT - 1 downto 0) & dividend_random(dividend_random'LEFT);
			tb_dividend <= dividend_random;
			
			divider_random  <= divider_random(divider_random'LEFT -1  downto 0) & divider_random(divider_random'LEFT);
			tb_divider 	<= divider_random;
			
			cycler 		<= cycler(cycler'LEFT-1 downto 0) & cycler(cycler'LEFT);
			tb_wr_valid <= cycler(10);
		end if;
	
	end process;
	
	-- divident_clk_gen: process
	-- begin
		-- divident_clk <= '1';
		-- wait for (10 ns);
		
		-- divident_clk <= NOT divident_clk;
		-- wait for 32 * (10 ns);
	-- end process;
	
	

	
	-- divident_gen: process(divident_clk)  -- left shift values
	-- begin
		-- if rising_edge(divident_clk) then
			-- dividend_random <= dividend_random + 1;
			-- tb_dividend <= STD_LOGIC_VECTOR(TO_UNSIGNED(dividend_random, tb_dividend'LENGTH));
			
			-- divider_random  <= X"000A";
			-- tb_divider 	<= divider_random;
			
		-- end if;
	
	-- end process;
	

end;




