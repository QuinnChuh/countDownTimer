--程序的功能：
--		例如时间为4:30.当来一个时钟脉冲时，先选择第一个数码管亮，然后段选上输出0；
--		接着在下一个时钟来时，选择第二个数码管亮，段选输出3.依次类推。

--输入引脚：
--		clk：时钟信号的输入
--		digits：为12位的BCD码，例如：现在的时间为5:40，则
--				digits=“0101 0100 0000”，这是分为三部分，其中“0101”指的是计数器中“时”的BCD码，这里为5，
--				"0100"指的是计数器中“分的十位”，这里是4
--				“0000”指的是计数器中“分的个位”，这里是0

--输出引脚：
--		sel：用三位二进制代表位选输出，这里不用两位二进制的原因是：用两位的话，后面还需要译码电路
--		segs：7位数码管的断码输出，这里运用的是共阴数码管，当断码被置为1时，段LED亮。

--写代码时遇到的问题：
--		我在让位选数据循环程序中（代码是上升沿那个地方），当我不为sell（位选的中间的变量）初始化时，
--		整个代码是可以运行的，但这样并没有用，因为这样的结果让我的输出值一直为000
--		但当我给sell初始化时，程序出现了
--		“Error (10822): HDL error at lcd_display.vhdl(42): couldn't implement registers for assignments on this clock edge”
--		这样的错误
--		那段代码主要是想先初始化sell，然后让它不停的循环移位，对此，我还试过利用rol语句，但同样有上面的错误，
--		不是很懂，看你能不能解决

--上面问题的解决：
--		我没有在上面的基础上去修改，而是想了另一种方法：
--			因为sell的初始值为000，那我在刚开始将它转换为001，然后让它在001,010,100间循环即可。


library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_signed.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;
entity lcd_display is
	port
	(
		-- Standard ports
		clk		: in std_logic;
		
		-- Input ports
        digits  : in std_logic_vector(11 downto 0); -- 3 digits in BCD
        
		-- Output ports
        sel     : out std_logic_vector(2 downto 0); -- digit select
        segs    : out std_logic_vector(6 downto 0)  -- segment code
	);
end lcd_display;

architecture bhv of lcd_display is
--定义时、分十位、分个位中间变量
	signal outp:std_logic_vector(6 downto 0);
	
	signal hour_buffer:std_logic_vector(3 downto 0);
	signal minute_buffer:std_logic_vector(3 downto 0);
	signal second_buffer:std_logic_vector(3 downto 0);
begin
	
	process(clk,digits)
	variable sell:std_logic_vector(2 downto 0);
	variable di_buffer:std_logic_vector(3 downto 0);
	
	
		begin
			--先将digits的值分开来存储起来
			hour_buffer   <= digits(11 downto 8);
			minute_buffer <= digits(7 downto 4);
			second_buffer <= digits(3 downto 0);
			
			--sell:="001";		--初始化sell，这里加上初始化就会报错
			--每来一个扫描频率，位选左移一位
			if rising_edge(clk)  then 
				
				case sell is
					when "000" =>
								sell:="001";
					when "001" =>
								sell:="010";
					when "010" =>
								sell:="100";
					when "100" =>
								sell:="001";
					when others =>
								null;
				end case;	--将位选输出
				sel<=sell;
				--利用循环移位的方式就可以直接确定下哪一位数码管亮
				--sell := TO_STDLOGICVECTOR(TO_BITVECTOR(sell) rol 1);
				
			--控制相应位的计数输出
			case sell is
				when "001" =>
				--输出分的个位
							di_buffer := second_buffer;
				when "010" =>
				--输出分的十位
							di_buffer := minute_buffer;
				when "100" =>
				--输出时
							di_buffer := hour_buffer;
				when others =>
							null;
			end case;
			
			--共阴数码管查询表，当输出为1时，点亮数码管的一段
			case di_buffer is
				when "0000" => outp<="0111111";		--数字0
				when "0001" => outp<="0000110";		--1
				when "0010" => outp<="1011011";		--2
				when "0011" => outp<="1001111";		--3
				when "0100" => outp<="1100110";		--4
				when "0101" => outp<="1101101";		--5
				when "0110" => outp<="1111101";		--6
				when "0111" => outp<="0000111";		--7
				when "1000" => outp<="1111111";		--8
				when "1001" => outp<="1101111";		--9
				
				when others=>null;
			end case;
			end if;
					
	end process;
	
	segs <= outp;		--将段选输出
end bhv;
