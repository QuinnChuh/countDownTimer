

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity frequencyDivider is
port
(
	clkIn:in std_logic;
	clkOut:out std_logic
);
end frequencyDivider;

architecture  struct of frequencyDivider is
	constant N:integer:=24;		
	signal   clkTemp:std_logic;
	signal count:integer range 0 to N;
	begin
		process(clkIn)
			begin
				if rising_edge(clkIn) then 	
					if count=N then			
						clkTemp<=not clkTemp;
						count<=0;			
					else					
						count<=count+1;
					end if;
				end if;

		end process;
	clkout<=clkTemp;

end;
