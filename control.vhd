library ieee;
use ieee.std_logic_1164.all;

entity control is
	port
	(
		clk                        :in std_logic;
		reset,start_pause,zero     :in bit;
		cnt_en,cnt_rst,alarm_en    :out bit
	);
end entity control;

architecture cont of control is
	type FSM_ST is (start,stay,count,warning);                          --start是初态，stay是暂停，count是计数，warning是报警
	signal current_state,next_state:FSM_ST;
	--signal c_input,c_output:std_logic_vector(2 downto 0);
begin
	--c_input<=reset&start_pause&zero;
	--c_output<=cnt_en&cnt_rst&alarm_en;
	
	REG:process(reset,clk)            --主控时序进程
    begin
		--if reset='1' then
			--current_state<=start;
			--cnt_rst='1';              --高电平有效
		if clk='1' and clk'event then
			current_state<=next_state;
		end if;
	end process REG;
	
	COM:process(current_state,reset,start_pause,zero)  --主控组合进程
	begin
		case current_state is 
		when start =>                      --start
		    if reset='0'and start_pause='1' and zero='0'
			then next_state<=count;cnt_en<='1';cnt_rst<='0'; alarm_en<='0';
			else next_state<=start; cnt_en<='0';cnt_rst<='0'; alarm_en<='0';
			end if;
			
		when stay =>                      --stay
			if (reset='0'and start_pause='0' and zero='0')
			or (reset='0' and start_pause='0' and zero='1') 
			then next_state<=stay;cnt_en<='0';cnt_rst<='0'; alarm_en<='0';
			elsif reset='0' and start_pause='1' and zero='0' 
			then next_state<=count;cnt_en<='1';cnt_rst<='0'; alarm_en<='0';
			else next_state<=start;cnt_en<='0';cnt_rst<='1'; alarm_en<='0';
			end if;

		when count =>                     --count
			if reset='0'and start_pause='0' and zero='0' 
			then next_state<=count;cnt_en<='1';cnt_rst<='0'; alarm_en<='0';
			elsif reset='0' and start_pause='0' and zero='1'
			then next_state<=warning;cnt_en<='0';cnt_rst<='0'; alarm_en<='1';
			elsif reset='0' and start_pause='1' and zero='0' 
			then next_state<=stay;cnt_en<='0';cnt_rst<='0'; alarm_en<='0';
			else next_state<=start;cnt_en<='0';cnt_rst<='1'; alarm_en<='0';
			end if;
		
		when warning =>                     --warning
		    if (reset='0'and start_pause='0' and zero='0')
		       or(reset='0' and start_pause='0' and zero='1')
			then next_state<=warning;cnt_en<='0';cnt_rst<='0'; alarm_en<='1';
			else next_state<=start;cnt_en<='0';cnt_rst<='1'; alarm_en<='0';
			end if;
			
		--when others => next_state<=start;cnt_en<='0';cnt_rst<='1'; alarm_en<='1';

		end case;
     end process COM;
end architecture cont;