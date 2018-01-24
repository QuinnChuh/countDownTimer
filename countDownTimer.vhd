library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;

entity countDownTimer is
	port(clk              : in  std_logic;
	     key_reset        : in  std_logic;
		 key_start_pause  : in  std_logic;
		 key_inc          : in  std_logic;
		 sel              : out std_logic_vector(2 downto 0); 
		 segs             : out std_logic_vector(6 downto 0); 
		 
		--hour    : out std_logic_vector(3 downto 0); -- 1 digit in BCD
		--min     : out std_logic_vector(7 downto 0); -- 2 digits in BCD

		alarm            : out std_logic
		);
end entity countDownTimer;

architecture inner of countDownTimer is
	component  remove_jitter                    
		port(clk,key_in : in std_logic;
		     key_out    : out std_logic);
	end component;
	
	component short_or_long                     
		port(clk		: in std_logic;
		     key_in	: in std_logic;
		     key_state  : out std_logic_vector(1 downto 0)
			 );
	end component;
	
	component control is
		port(clk                        :in std_logic;
			 reset,start_pause,zero     :in std_logic;
		     cnt_en,cnt_rst,alarm_en    :out std_logic);
    end component;
	
	component counter is
	   port(clk		: in std_logic;
            en      : in std_logic;     -- '1' to enable countdown
			rst     : in std_logic;     -- '1' to reset to 0.01
			inc	    : in std_logic_vector(1 downto 0);
    
			hour    : out std_logic_vector(3 downto 0); -- 1 digit in BCD
			min     : out std_logic_vector(7 downto 0); -- 2 digits in BCD
			cout    : out std_logic                  );-- '1' when count to 0.00, lasting 1 clk cycle
	end component;
	
     component lcd_display is
	 port(clk		: in std_logic;
		  digits     : in std_logic_vector(11 downto 0); -- 3 digits in BCD
        
          sel        : out std_logic_vector(2 downto 0); -- digit select
          segs       : out std_logic_vector(6 downto 0)  );
	 end component;
	
	
signal net_key_reset,net_key_out1: std_logic;      --第一个jitter的连线
signal net_key_start_pause,net_key_out2: std_logic;--第二个jitter的连线
signal net_inc:std_logic_vector(1 downto 0);
signal net_key_out3: std_logic;                    --第三个jitter的连线
signal net_key_inc:std_logic_vector(1 downto 0);                
signal net_key_state:std_logic_vector(1 downto 0); --short_or_long
signal net_zero,net_cnt_en,net_cnt_rst:std_logic;  --control
signal net_hour:std_logic_vector(3 downto 0);
signal net_min:std_logic_vector(7 downto 0);

--
--signal trash1,trash2 : 
																   
	begin 
	 u1:remove_jitter port map (clk=>clk,key_in=>key_reset,key_out=>net_key_out1);
	 u2:remove_jitter port map (clk=>clk,key_in=>key_start_pause,key_out=>net_key_out2);
	 u3:remove_jitter port map (clk=>clk,key_in=>key_inc,key_out=>net_key_out3);
	 u4:short_or_long port map (clk=>clk,key_in=>net_key_out3,key_state=>net_key_state);
	 u5:control       port map (clk=>clk,reset=>net_key_out1,start_pause=>net_key_out2,
	                            zero=>net_zero,cnt_en=>net_cnt_en,cnt_rst=>net_cnt_rst,alarm_en=>alarm);
	 u6:counter     port map (clk=>clk,en=>net_cnt_en,rst=>net_cnt_rst,inc=>net_key_state,
	                            hour=>net_hour,min=>net_min,cout=>net_zero);
	 u7:lcd_display   port map (clk=>clk,digits=>net_hour&net_min,sel=>sel,segs=>segs);
end architecture inner;