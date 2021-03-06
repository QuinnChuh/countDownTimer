library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
entity press_time is
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
end;

architecture bhv of press_time is
  signal num: std_logic_vector (3 downto 0);
begin
 
 process (clk,key_in,num) 
  --
  variable temp: std_logic_vector(1 downto 0);
  variable flag: std_logic;
  begin
  
  if clk'event and clk = '1' then    
	if (key_in = '1') then num <= num+1;
	else num <= "0000";	
	end if;
	--not pressed
	if (num = "0000") then temp := "00";
	--short pressed  
        elsif(num >= "0001" and num<= "0010")  then temp := "01"; 	--0011 
	--long pressed	  
	elsif (num >= "0010" and num<= "1111") then temp := "10";
        --press time overflow
        elsif (num > "1111" )                  then temp := "10";
    end if;
    
    if (key_in = '0') then flag := '0';
    else flag := '1';
    end if;
    
    if (temp = "01" and flag = '0') then key_state <= "01";
    elsif (temp = "10" and flag = '0') then key_state <= "10";
    else key_state <= "00";
    end if;	
    
   end if;
 end process;
end;