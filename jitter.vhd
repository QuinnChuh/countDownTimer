library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
entity jitter is
	port(clk,key_in : in std_logic;
		 key_out    : out std_logic);
end;

architecture bhv of jitter is
	signal key_h : std_logic_vector(3 downto 0);
	signal key_l : std_logic_vector(3 downto 0);
begin
 process (clk,key_in,key_h,key_l) begin
  if clk'event and clk = '1' then 
    --key_out <= '1';   
	if (key_in = '0') then key_l <= key_l+1;
	else key_l <= "0000";	
	end if;
	
	if (key_in = '1') then key_h <= key_h+1;
	else key_h <= "0000";	
	end if;
	
	if (key_l > "0111") then key_out <= '0';
	elsif (key_h > "0111") then key_out <= '1';	
	end if;
	
  end if;
 end process;
end;