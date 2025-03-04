library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;
use ieee.numeric_std.all;



entity seg7_indicator is
    port (
		clk         : IN  STD_LOGIC;
		leds			: OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
		seg_num		: OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
		code_out		: OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
    );
end seg7_indicator;


architecture behave of seg7_indicator is

	COMPONENT segment_7 is
		port(
			clk       : in  std_logic;
			en        : in  std_logic;
			dec_in    : in  std_logic_vector(15 downto 0);-- all 4 digits to show
			dp_in     : IN  STD_LOGIC_VECTOR(3 DOWNTO 0);
			wr_valid_n: IN  STD_LOGIC;
			c_sel     : out std_logic_vector(3 downto 0); -- anod selection
			code7_dp  : out std_logic_vector(7 downto 0)
		);
	END COMPONENT segment_7;
	
	
	COMPONENT pgen IS
		GENERIC(
			Edge : STD_LOGIC
		);
		PORT(
			Enable : IN  STD_LOGIC;
			Clk    : IN  STD_LOGIC;
			Input  : IN  STD_LOGIC;
			Output : OUT STD_LOGIC
		);
	END COMPONENT pgen;

	
	

	SIGNAL cnt_10Hz : INTEGER RANGE 0 TO 25_000_000;
	SIGNAL clk_10Hz : STD_LOGIC;
	SIGNAL counter : INTEGER RANGE 0 TO 9999;
	SIGNAL dec_counter : STD_LOGIC_VECTOR( 15 DOWNTO 0);
	SIGNAL wr_en_pulse : STD_LOGIC;

begin


	pulse_gen: pgen
		GENERIC MAP (
			Edge  => '1'   -- riging edge pulse gen
		)
		PORT MAP(
			Enable => '1',
			Clk    => clk,
			Input  => clk_10Hz,
			Output => wr_en_pulse
		);

	decoder: segment_7 
		PORT MAP(
			clk        => clk,
			en         => '1',
			dec_in     => dec_counter, 
			dp_in      => "0000", 		--all decimal points turned off
			wr_valid_n => wr_en_pulse,
			c_sel      => seg_num,
			code7_dp   => code_out
		);
	

	dec_counter <= STD_LOGIC_VECTOR(TO_UNSIGNED(counter, dec_counter'LENGTH));
	
	gen_10Hz: process(clk) 
	begin
		IF RISING_EDGE(clk) THEN
--		IF FALLING_EDGE(clk) THEN
			IF cnt_10Hz < ( 25_000_000 / 2 ) THEN
				cnt_10Hz <= cnt_10Hz + 1;
			ELSE
				cnt_10Hz <= 0;
				clk_10Hz <= NOT clk_10Hz;
			END IF;
		
		END IF;
	end process;
	
	
	dig_counter: PROCESS(clk_10Hz)
	BEGIN
		IF RISING_EDGE(clk_10Hz) THEN
			IF counter < 9999 THEN
				counter <= counter + 1;
			ELSE
				counter <= 0;
			END IF;
			leds <= STD_LOGIC_VECTOR(TO_UNSIGNED(counter,leds'LENGTH));
		END IF;	
	END PROCESS;
	
	
	
	
	
		
end behave;