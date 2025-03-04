-- Hexadimal to decimal code converter for
-- 7 segment indicator
-- simbol shows by zero and hide by '1'
-- also include whole process of indication 
-- wr_valid_n - is short low pulse for input data latching




library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;

entity segment_7 is
    port(
		clk       : in  std_logic;
		en        : in  std_logic;
		dec_in    : in  std_logic_vector(15 downto 0);-- all 4 digits to show
		dp_in     : IN  STD_LOGIC_VECTOR(3 DOWNTO 0);
		wr_valid_n: IN  STD_LOGIC;
		c_sel     : out std_logic_vector(3 downto 0); -- anod selection
		code7_dp  : out std_logic_vector(7 downto 0)
    );
end segment_7;

architecture Behavioral of segment_7 is

COMPONENT divider16x16b is
    generic(
		WIDTH 		: INTEGER RANGE 0 TO 32 := 8
	);
    port (
		clk         : in std_logic;
		dividend    : in std_logic_vector(WIDTH - 1 downto 0);
		divider     : in std_logic_vector(WIDTH - 1 downto 0);
		quotient    : out std_logic_vector(WIDTH - 1 downto 0); -- quotient of division
		remainder   : out std_logic_vector(WIDTH - 1 downto 0); -- remainder of division
		wr_valid    : in std_logic;
		rd_valid		: out std_logic
    );
END COMPONENT;




SIGNAL dec      : std_logic_vector(7 downto 0);
SIGNAL dots     : STD_LOGIC_VECTOR(3 DOWNTO 0);
SIGNAL div_cnt  : INTEGER RANGE 0 TO 25000;  --511;
SIGNAL clk_1kHz : STD_LOGIC;
SIGNAL seg_sel  : INTEGER RANGE 0 TO 3;
SIGNAL seg_num  : INTEGER RANGE 0 TO 3;

CONSTANT DIG_DIV : STD_LOGIC_VECTOR(15 DOWNTO 0) := x"000A";  -- divide for 10
SIGNAL dec1_in  : STD_LOGIC_VECTOR(15 DOWNTO 0);
SIGNAL dec2_in  : STD_LOGIC_VECTOR(15 DOWNTO 0);
SIGNAL d0,d1,d2,d3 : STD_LOGIC_VECTOR(15 DOWNTO 0);
SIGNAL rd0, rd1, rd2 : STD_LOGIC;
--SIGNAL valid1, valid2 : STD_LOGIC;


begin

code7_dp <= dec;

div_d0: divider16x16b
	generic map(
		WIDTH => 16
	)
    PORT map (
		clk         => clk,
		dividend    => dec_in,
		divider     => DIG_DIV,
		quotient    => dec1_in,
		remainder   => d0,
		wr_valid    => wr_valid_n,
		rd_valid		=> rd0
    );

div_d1: divider16x16b
	generic map(
		WIDTH => 16
	)
    PORT map (
		clk         => clk,
		dividend    => dec1_in,
		divider     => DIG_DIV,
		quotient    => dec2_in,
		remainder   => d1,
		wr_valid    => rd0,
		rd_valid		=> rd1
    );
	
div_d23: divider16x16b
	generic map(
		WIDTH => 16
	)
    PORT map (
		clk         => clk,
		dividend    => dec2_in,
		divider     => DIG_DIV,
		quotient    => d3,
		remainder   => d2,
		wr_valid    => rd1,
		rd_valid		=> rd2
    );

----------- OK! ------------------------
--	 div_d0: divider16x16b_out_valid
--    PORT map (
--		clk         => clk,
--		dividend    => dec_in,
--		divider     => DIG_DIV,
--		quotient    => dec1_in,
--		remainder   => d0,
--		rd_valid		=> rd0,
--		wr_valid      => wr_valid_n
--    );
--
--div_d1: divider16x16b_out_valid
--    PORT map (
--		clk         => clk,
--		dividend    => dec1_in,
--		divider     => DIG_DIV,
--		quotient    => dec2_in,
--		remainder   => d1,
--		rd_valid		=> rd1,
--		wr_valid      => rd0
--    );
--	
--div_d23: divider16x16b_out_valid
--    PORT map (
--		clk         => clk,
--		dividend    => dec2_in,
--		divider     => DIG_DIV,
--		quotient    => d3,
--		remainder   => d2,
--		rd_valid		=> rd2,
--		wr_valid      => rd1
--    );

	 

divider_1kHz: PROCESS(clk)
BEGIN
	IF en = '0' THEN
		clk_1kHz <= '0';
		div_cnt  <= 0;
	ELSIF en = '1' AND RISING_EDGE(clk) THEN
--		valid1 <= wr_valid_n;
--		valid2 <= valid1;
		
		IF div_cnt < 25000 THEN
			div_cnt <= div_cnt + 1;
		ELSE
			div_cnt <= 0;
			clk_1kHz <= NOT clk_1kHz;
		END IF;
	END IF;
END PROCESS;

seg_num <= 0 WHEN dec_in < x"000A" ELSE -- less 10
		1 WHEN dec_in < x"0064" ELSE -- less 100
		2 WHEN dec_in < x"03E8" ELSE -- less 1000
		3;



seg_sel_cnt: PROCESS(clk_1kHz)
BEGIN
	IF en = '0' THEN
		seg_sel <= 0;
	ELSIF RISING_EDGE(clk_1kHz) THEN
		IF seg_sel < seg_num THEN
			seg_sel <= seg_sel + 1;
		ELSE
			seg_sel <= 0;
		END IF;
	END IF;
END PROCESS;



process (clk)
	variable hex : STD_LOGIC_VECTOR(3 DOWNTO 0);
begin
	IF en = '0' THEN
		c_sel<= "1111";
    ELSIF RISING_EDGE(clk) then --rising edge 
		CASE seg_sel IS
		WHEN 0 => 
			hex := d0(3 DOWNTO 0);
			c_sel <= "1110";
			dec(7) <= NOT dp_in(0);
		WHEN 1 =>
			hex := d1(3 DOWNTO 0);
			c_sel <= "1101";
			dec(7) <= NOT dp_in(1);
		WHEN 2 =>
			hex := d2(3 DOWNTO 0);
			c_sel <= "1011";
			dec(7) <= NOT dp_in(2);
		WHEN 3 =>
			hex := d3(3 DOWNTO 0);
			c_sel <= "0111";
			dec(7) <= NOT dp_in(3);
		WHEN OTHERS => NULL;
		END CASE;
		
		case hex is
			when "0000" => dec(6 downto 0) <= "1000000"; -- 0
			when "0001" => dec(6 downto 0) <= "1111001"; -- 1
			when "0010" => dec(6 downto 0) <= "0100100"; -- 2
			when "0011" => dec(6 downto 0) <= "0110000"; -- 3
			when "0100" => dec(6 downto 0) <= "0011001"; -- 4
			when "0101" => dec(6 downto 0) <= "0010010"; -- 5
			when "0110" => dec(6 downto 0) <= "0000010"; -- 6
			when "0111" => dec(6 downto 0) <= "1111000"; -- 7
			when "1000" => dec(6 downto 0) <= "0000000"; -- 8
			when "1001" => dec(6 downto 0) <= "0010000"; -- 9
			when "1010" => dec(6 downto 0) <= "0001000"; -- A
			when "1011" => dec(6 downto 0) <= "0000011"; -- b
			when "1100" => dec(6 downto 0) <= "1000110"; -- C
			when "1101" => dec(6 downto 0) <= "0100001"; -- d
			when "1110" => dec(6 downto 0) <= "0000110"; -- E
			when "1111" => dec(6 downto 0) <= "0001110"; -- F
		when others => null;
		end case;
    end if;
end process;



end Behavioral;