library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;

entity counter is
	port
	(
		-- Standard ports
		clk		: in std_logic;
        en      : in std_logic;     -- '1' to enable countdown
        rst     : in std_logic;     -- '1' to reset to 0.01
		
		-- Input ports
		-- inc: lasting 1 clk cycle
		--   00 - do nothing
		--   01 - increase by 1 min
		--   10 - increase by 10 min
		inc	: in std_logic_vector(1 downto 0);
        
		-- Output ports
        hour    : out std_logic_vector(3 downto 0); -- 1 digit in BCD
        min     : out std_logic_vector(7 downto 0); -- 2 digits in BCD
        cout    : out std_logic     -- '1' when count to 0.00, lasting 1 clk cycle
	);
end entity counter ;

architecture inner of counter is
	-- store inputs

	-- import components
	-- 1. frequencyDivider
	component frequencyDivider is
		port
		(
			clkIn:in std_logic;
			clkOut:out std_logic
		);
	end component frequencyDivider;

	-- 2. setInit
	component setInit is
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
	end component setInit;

	-- 3. minuteCountDown
	component minuteCountDown is
		port(
				-- Standard ports
				clk		: in std_logic;		-- period is 1 s
				en      : in std_logic;     -- '1' to enable countdown
				rst     : in std_logic;     -- '1' to reset to 0.01
				
				-- initial value
				-- hour_start    : in integer range 0 to 6; -- 1 digit in BCD
				minute_start     : in std_logic_vector (7 downto 0); -- 2 digits in BCD
				setFlag : in std_logic;	--initial value's flag,'1' means yes
				--setFlag : in std_logic;	--initial value's flag,'1' means yes
				--hourBecomeZero : in std_logic; 	-- '1' means that hour is zero
							
				-- Output ports
				minute : buffer std_logic_vector(7 downto 0);	-- 2 digit in BCD for minute
				hour_CountDown : buffer std_logic 	-- '1' means hour will decrease 1
			);
	end component minuteCountDown;
	
	-- 4. hourCountDown
	component hourCountDown is
		port(
				-- Standard ports
				clk		: in std_logic;		-- period is 1 s
				en 		: in std_logic;		-- enable to countDown
				rst     : in std_logic;     			-- '1' to reset to 0.01
				
				-- Input ports
				hour_CountDown      : in std_logic;     -- '1' to enable hourCountdown
				hour_start     : in std_logic_vector (3 downto 0); -- 2 digits in BCD
				setFlag : in std_logic;	--initial value's flag,'1' means yes
				--setFlag : in std_logic;	--initial value's flag,'1' means yes
							
				-- Output ports
				hour : buffer std_logic_vector(3 downto 0)	-- 2 digit in BCD for hour
				--hourBecomeZero : out std_logic 	-- '1' means that hour is zero
			);
	end component hourCountDown;
	
	-- 5.testCout
	component testCout is
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
	end component testCout;
	
	-- 6.jitter	
	component jitter is
		port(clk,key_in : in std_logic;
			 key_out    : out std_logic);
	end component jitter;
	
	-- links
	signal clkNet, setFlagNet, hour_CountDownNet: std_logic;
	signal hour_startNet, hourNet : std_logic_vector (3 downto 0);
	signal minute_startNet,minuteNet : std_logic_vector (7 downto 0);
	signal rstNet, enNet: std_logic;
	
begin
	-- inners
	inner1 : frequencyDivider port map(clkIn => clk,clkOut => clkNet);

	inner2 : jitter port map(clk => clk,key_in => rst, key_out => rstNet);
	
	inner3 : jitter port map(clk => clk,key_in => en, key_out => enNet);
			
	inner4 : setInit port map(clk => clkNet,rst => rstNet, inc => inc, hour_start => hour_startNet, minute_start => minute_startNet,setFlag => setFlagNet);
	
	inner5 : minuteCountDown port map(clk => clkNet, en => enNet, rst => rstNet, minute_start => minute_startNet, setFlag => setFlagNet, minute => minuteNet, hour_CountDown => hour_CountDownNet);
	
	inner6 : hourCountDown port map(clk => clkNet, en => enNet, rst => rstNet, hour_CountDown => hour_CountDownNet, hour_start => hour_startNet, hour => hourNet, setFlag => setFlagNet);
	
	inner7 : testCout port map(clk => clkNet,hourInput => hourNet, minuteInput => minuteNet, hour => hour, min => min,cout => cout);

	
end architecture inner ;