library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;

entity minuteCountDown is
	port(
			-- Standard ports
			clk		: in std_logic;		-- period is 1 s
			en      : in std_logic;     -- '1' to enable countdown
			rst     : in std_logic;     -- '1' to reset to 0.01
			
			-- initial value
			-- hour_start    : in integer range 0 to 6; -- 1 digit in BCD
			minute_start     : in std_logic_vector (7 downto 0); -- 2 digits in BCD
			setFlag : in std_logic;	--initial value's flag,'1' means yes
			--hourBecomeZero : in std_logic; 	-- '1' means that hour is zero
						
			-- Output ports
			minute : buffer std_logic_vector(7 downto 0);	-- 2 digit in BCD for minute
			hour_CountDown : buffer std_logic 	-- '1' means hour will decrease 1
		);
end entity minuteCountDown;

architecture inner of minuteCountDown is
	signal seconds : integer range 0 to 60;
	--signal minute_buffer : std_logic_vector(7 downto 0) := minute_start;
	
begin
	minuteCounter : process(clk,en,rst,setFlag)
		variable minute_buffer : std_logic_vector(7 downto 0) := minute_start;
	begin
		if rst = '1'
			then minute <= "00000001";
				 hour_CountDown <= '0';
		elsif setFlag = '1'
			then minute <= minute_start;
		elsif clk = '1' and clk'event
			then minute_buffer := minute;
			--minute_buffer <= minute;
			--if hourBecomeZero = '1' and hour_CountDown = '1'
			--	then minute <= "00000000";
				if en = '1'	-- begin countDown,calculate up edge numbers
					then seconds <= seconds + 1;	-- 统计脉冲数，即秒数
						if seconds >= 60
							then seconds <= seconds - 60;
								if minute_buffer = "00000000"
									then minute <= "01011001";
										 hour_CountDown <= '1';
								elsif minute_buffer(3 downto 0) = "0000"	-- 如果当前分值为10，20，30……
									then minute <= ( minute_buffer(7 downto 4) - 1) & "0101";	--置为9，19，29…?
										 hour_CountDown <= '1';
								else	--否则为 19 => 18,23 => 22
									minute <= ( minute_buffer(7 downto 4)) & ( minute_buffer(3 downto 0) - 1);
									hour_CountDown <= '0';
								end if;
						else
							hour_CountDown <= '0';
						end if;
				 else
					 --minute <= minute_start;
					 minute <= minute_buffer;
					 hour_CountDown <= '0';
				 end if;
		end if;
		
	end process minuteCounter;
	
end architecture inner;
