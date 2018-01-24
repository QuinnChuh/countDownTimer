library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;

entity testCout is
	port(
			-- Standard ports
			clk		: in std_logic;		-- period is 1 s
			
			-- Input ports
			hourInput : in std_logic_vector(3 downto 0);	-- 2 digit in BCD for hourInput
			minuteInput     : in std_logic_vector (7 downto 0); -- 2 digits in BCD for minuteInput
						
			-- Output ports
			hour : out std_logic_vector(3 downto 0);	-- 2 digit in BCD for hour
			min  : out std_logic_vector (7 downto 0); -- 2 digits in BCD for minute
			cout : out std_logic	-- cout 
		);
end entity testCout;

architecture inner of testCout is
begin
	HourMinuteOut:process(hourInput,minuteInput)
	begin
		if (hourInput = "0000" and minuteInput = "00000000")
			then hour <= "0000";
				 min <= "00000000";
				 cout <= '1';
		else
			hour <= hourInput;
			min <= minuteInput;
			cout <= '0';
		end if;
	end process HourMinuteOut;
	
end architecture inner;
