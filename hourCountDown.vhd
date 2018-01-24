library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;

entity hourCountDown is
	port(
			-- Standard ports
			clk		: in std_logic;		-- period is 1 s
			en 		: in std_logic;		-- enable to countDown
			rst     : in std_logic;     			-- '1' to reset to 0.01
			
			-- Input ports
			hour_CountDown : in std_logic;     -- '1' to enable hourCountdown
			hour_start : in std_logic_vector (3 downto 0); -- 2 digits in BCD
			setFlag : in std_logic;	--initial value's flag,'1' means yes
						
			-- Output ports
			hour : buffer std_logic_vector(3 downto 0)	-- 2 digit in BCD for hour
			--hourBecomeZero : out std_logic 	-- '1' means that hour is zero
		);
end entity hourCountDown;

architecture inner of hourCountDown is
	--signal hour_buffer : std_logic_vector(3 downto 0) := hour_start;
	
begin
	HourCounter : process(clk,hour_CountDown,rst,setFlag)
		variable hour_buffer : std_logic_vector(3 downto 0) := hour_start;
	begin
		if rst = '1'
			then hour <= "0000";
				 --hourBecomeZero <= '1';
		elsif setFlag = '1'
			then hour <= hour_start;
		elsif clk = '1' and clk'event
				then hour_buffer := hour;
					if en = '1'
						then if hour_CountDown = '1'	-- begin countDown,calculate up edge numbers
								then if hour /= "0000"
										then hour <= hour_buffer - 1;
											 --hourBecomeZero <= '0';
									 end if;
							 end if;
					else
						hour <= hour_buffer;
						--hourBecomeZero <= '0';
					end if;
		end if;
		--end if;
	end process HourCounter;
	
end architecture inner;
