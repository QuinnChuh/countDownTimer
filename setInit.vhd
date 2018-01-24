library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;

entity setInit is
	port(
			-- Standard ports
			clk		: in std_logic;		-- period is 1 s
			rst     : in std_logic;     -- '1' to reset to 0.01

			-- Input ports
			-- inc: lasting 1 clk cycle
			--   00 - do nothing
			--   01 - increase by 1 min
			--   10 - increase by 10 min
			inc	: in std_logic_vector(1 downto 0);
			
			--output
			-- state_output_hour : buffer integer range 0 to 24;
			-- state_output_minute,state_output_second : buffer integer range 0 to 60
			
			-- Output ports
			hour_start    : out std_logic_vector (3 downto 0); -- initial hour
			minute_start  : out std_logic_vector (7 downto 0); -- initial minuteInput
			setFlag : out std_logic	--initial value's flag,'1' means yes
		);
end entity setInit;

architecture bhv of setInit is
	constant second_start : integer := 0;
begin
	GetSetFlag:process(inc)
	begin
		if inc = "01" or inc = "10"
			then setFlag <= '1';
		else
			setFlag <= '0';
		end if;
	end process GetSetFlag;
	
	-- startTime_latch process : initial time set --	
	startTime_latch:process(clk,rst,inc)
		variable hour_start_buffer : integer range 0 to 6;
		variable minute_start_buffer : integer range 0 to 70;
		variable hour_start_buffer1 : integer range 0 to 6;
		variable minute_start_buffer1 : integer range 0 to 70;
			
		variable minute_TenDigit : integer range 0 to 9;
		variable minute_UnitDigit : integer range 0 to 9;
	begin
		if rst = '1'
			then hour_start <= "0000";
				 minute_start <= "00000001";
		
		elsif clk = '0' and clk'event
			then	if inc = "01"		-- increase by 1 min
						then  if minute_start_buffer1 < 59
								then minute_start_buffer := minute_start_buffer1 + 1;
									 minute_start_buffer1 := minute_start_buffer;
									 
									 -- minute_start <= minute_start_buffer;
									 -- outputs
									 --hour <= conv_std_logic_vector(state_output_hour,4);
									 minute_UnitDigit := minute_start_buffer REM 10;
									 minute_TenDigit := (minute_start_buffer - minute_UnitDigit)/10; 
									 minute_start <= conv_std_logic_vector(minute_TenDigit,4) & conv_std_logic_vector(minute_UnitDigit,4);
									 
							 elsif minute_start_buffer1 >= 59
								then minute_start_buffer := 0;
									 minute_start_buffer1 := 0;
									 minute_start <= "00000000";
									 
									 hour_start_buffer := hour_start_buffer1 + 1;
									 hour_start_buffer1 := hour_start_buffer;
									 -- hour_start <= hour_start_buffer;
									 
									 -- outputs
									 hour_start <= conv_std_logic_vector(hour_start_buffer,4);
							 end if;
							 
					elsif inc = "10"	-- increase by 10 min
						then if minute_start_buffer1 < 50
								then minute_start_buffer := minute_start_buffer1 + 10;
									 minute_start_buffer1 := minute_start_buffer;
									 
									 minute_UnitDigit := minute_start_buffer REM 10;
									 minute_TenDigit := (minute_start_buffer - minute_UnitDigit)/10;
									 --minute_TenDigit := minute_start_buffer MOD 10;
									 minute_start <= conv_std_logic_vector(minute_TenDigit,4) & conv_std_logic_vector(minute_UnitDigit,4);
									 
									 --minute_start <= minute_start_buffer;
									 
							 elsif minute_start_buffer1 >= 50
								then minute_start_buffer := minute_start_buffer1 + 10 - 60;
									 minute_start_buffer1 := minute_start_buffer;
									 --minute_start <= minute_start_buffer;
									 
									 hour_start_buffer := hour_start_buffer1 + 1;
									 hour_start_buffer1 := hour_start_buffer;
									 --hour_start <= hour_start_buffer;

									 -- outputs
									 hour_start <= conv_std_logic_vector(hour_start_buffer,4);
									 minute_UnitDigit := minute_start_buffer REM 10;
									 minute_TenDigit := (minute_start_buffer - minute_UnitDigit)/10; 
									 minute_start <= conv_std_logic_vector(minute_TenDigit,4) & conv_std_logic_vector(minute_UnitDigit,4);
							 end if;
					end if;
		end if;
	end process startTime_latch;
end architecture bhv;