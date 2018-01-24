library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;

entity short_or_long is
	port
	(
		-- Standard ports
		clk		: in std_logic;
		key_in	: in std_logic;
		
        -- Output ports
        key_state  : out std_logic_vector(1 downto 0) 
	);
end entity short_or_long ;

architecture inner of short_or_long is
	-- import components
	-- 1. frequencyDivider
	component frequencyDivider is
	port
	(
		clkIn:in std_logic;
		clkOut:out std_logic
	);
	end component frequencyDivider;

	-- 1. press_time	
	component press_time is
		port
		(
			-- Standard ports
			clk		: in std_logic;
			
			-- Input ports
			key_in	: in std_logic;

			-- Output ports
			-- key_state: lasting 1 clk cycle
			--   00 - not pressed
			--   01 - short pressed
			--   10 - long pressed
			key_state  : out std_logic_vector(1 downto 0)
		);
	end component press_time;
	-- links
	signal clkNet: std_logic ;
begin
	-- inners
	inner1 : frequencyDivider port map(clkIn => clk, clkOut => clkNet);
	inner2 : press_time port map(clk => clkNet, key_in => key_in, key_state => key_state);
		
end architecture inner ;