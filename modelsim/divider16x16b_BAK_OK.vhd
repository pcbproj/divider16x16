library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;

entity divider16x16b is
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
		rd_valid	: out std_logic
    );
end divider16x16b;


architecture Behavioral of divider16x16b is
	signal up, down, temp, res_temp, result, remain : std_logic_vector(WIDTH - 1 downto 0);
	signal rd_valid_tmp : std_logic;
	signal rd_valid_tmp2 : std_logic;
	signal b : integer range 0 to WIDTH;
	
begin

process(clk, wr_valid)
    begin 
	if wr_valid = '1' then 
	    up 				<= dividend;
	    down 			<= divider;
		result 			<= (others => '0');
	    temp			<= (others => '0');
	    b 				<= 0;
	    res_temp 		<= (others => '0');
		rd_valid 		<= '0';
		rd_valid_tmp 	<= '0';
		rd_valid_tmp2	<= '0';
		
	elsif clk'Event and clk = '1' then
		if b < ( WIDTH ) then
			if temp < down then
				temp <= ( temp( (WIDTH - 2) downto 0) & up(WIDTH - b - 1) ); -- shift in bits MSB first from up into temp register while temp < down
				b <= b + 1;
			else
				result(WIDTH - b - 1) <= '1';							-- set to 1 respective bits in result register
				temp <= temp - down;									-- subtraction down from temp register
			end if;
			rd_valid_tmp <= '0';
		else
			if temp >= down then
				result <= result(WIDTH - 2 downto 0) & '1';
				temp <= temp - down;
			else
				result <= result(WIDTH - 2 downto 0) & '0';
				temp <= temp( (WIDTH - 2) downto 0) & '0';
			end if;
			rd_valid_tmp <= '1';
			rd_valid_tmp2 <= rd_valid_tmp;
		end if;
		
		rd_valid <= rd_valid_tmp and ( not rd_valid_tmp2 );  -- rd_valid pulse one cycle width generation
		quotient <= result;
		remainder <= temp;
	
	end if;
    
	end process;
end Behavioral;
