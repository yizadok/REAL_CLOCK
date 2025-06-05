library IEEE;
  use IEEE.std_logic_1164.all;
  use IEEE.std_logic_unsigned.all;
  use work.bcd.all;

entity REAL_CLOCK is
port
(
  CLK:    in  std_logic;
  RESET:  in  std_logic;
  TESTMODE:     in std_logic;
  -- 8 INPUT SWITCHES
  ADDRS:       in std_logic_vector(1 downto 0);
  DATA:         in std_logic_vector(5 downto 0);
  -- INPUT BUTTON
  LOAD:        in std_logic;
  
  
  Anode_Activate : out STD_LOGIC_VECTOR (3 downto 0);-- 4 Anode signals
  LED_OUT : out STD_LOGIC_VECTOR (6 downto 0);
  SSD_OUT: out std_logic_vector(6 downto 0);
  SWITCH: out std_logic;
  
  data_up: in std_logic;
  data_down: in std_logic
  
);
end REAL_CLOCK;

architecture CLK_ARC of REAL_CLOCK is
  signal Q: std_logic_vector(26 downto 0);
  signal SEC: std_logic_vector(7 downto 0);
  signal MIN: std_logic_vector(7 downto 0);
  signal HRS: std_logic_vector(7 downto 0);
  signal TC: std_logic;
  signal BCD_SEC: std_logic_vector(11 downto 0);
  signal BCD_MIN: std_logic_vector(11 downto 0);
  signal BCD_HRS: std_logic_vector(11 downto 0);
  signal SSD_SEC1: std_logic_vector(6 downto 0);
  signal SSD_SEC2: std_logic_vector(6 downto 0);
  signal SSD_MIN1: std_logic_vector(6 downto 0);
  signal SSD_MIN2: std_logic_vector(6 downto 0);
  signal SSD_HRS1: std_logic_vector(6 downto 0);
  signal SSD_HRS2: std_logic_vector(6 downto 0);
  signal SSD_1: std_logic_vector(6 downto 0);
  signal SSD_2: std_logic_vector(6 downto 0);
  
  
  signal refresh_counter: STD_LOGIC_VECTOR (19 downto 0);
  signal LED_activating_counter: std_logic_vector(1 downto 0);
  
  signal DATA_IN: std_logic_vector(7 downto 0);
  signal SEL: std_logic_vector(2 downto 0);
  signal SEL_HOURS: std_logic := '0';
  signal SEL_MINS: std_logic  := '0';
  signal SEL_SECS: std_logic  := '0';

  
 
  
begin

  Timebase: process
  begin
    wait until rising_edge(CLK);
    if (RESET = '1') then
      Q <= (others => '0');
    else
		if TESTMODE = '0' then
			if (Q < 99999999) then
				Q <= Q + 1;
			else 
				Q <= (others => '0');
			end if;
		else
			if (Q < 9) then
				Q <= Q + 1;
			else 
				Q <= (others => '0');
			end if;	
		end if;		
    end if;
            end process;

  P2: TC <= '1' when (Q = 0) else
            '0';
			
--data prep

DATA_IN <= "00" & DATA(5 downto 0);

ADDRS_MUX: process(ADDRS)
	begin

	case ADDRS is
	when "00" =>
		SEL <= "100";
	when "01" =>
		SEL <= "001";
	when "10" =>
		SEL <= "010";
	when others => SEL <= "000";
    end case;
end process;

SEL_HOURS <= SEL(2);
SEL_MINS  <= SEL(1);
SEL_SECS  <= SEL(0);		
			
secs: process
  begin
	wait until rising_edge(CLK);
	if (RESET = '1') then
		SEC <= (others => '0');
	else 
		if (LOAD = '1') and (SEL_SECS = '1') then
		SEC <= DATA_IN(7 downto 0);	
	  else
		if TC = '1'
		then
			if (SEC < 59) then
				SEC <= SEC + 1;
			else
				SEC <= (others => '0');
			end if;
		end if;
	  end if;	
	end if;
  end process;


  mins: process
  begin
	wait until rising_edge(CLK);
	if (RESET = '1') then
		MIN <= (others => '0');
	else
		if (SEL_MINS = '1') then
			if data_up  = '1' then
				MIN <= MIN + 1;
			elsif data_down = '1' then
				MIN <= MIN - 1;
			end if;
		end if;
			
		
		if (LOAD = '1') and (SEL_MINS = '1') then
		MIN <= DATA_IN(7 downto 0);	
	  else
		if (SEC = 59) and (TC = '1') then
			if (MIN < 59) then
				MIN <= MIN + 1;
			else
				MIN <= (others => '0');
			end if;
		end if;
	  end if;	
	end if;
  end process;



  hours123: process
  begin
	wait until rising_edge(CLK);
	if (RESET = '1') then
		HRS <= (others => '0');
	else
		if (LOAD = '1') and (SEL_HOURS = '1') then
		HRS <= DATA_IN(7 downto 0);
	  else
		if (MIN = 59) and (TC = '1') and (SEC = 59) then
			if (HRS < 23) then
				HRS <= HRS + 1;
			else
				HRS <= (others => '0');
			end if;
		end if;
	  end if;	
	end if;
  end process;


  

 BCD_SEC <= to_bcd(SEC);
 BCD_MIN <= to_bcd(MIN);
 BCD_HRS <= to_bcd(HRS);
 SSD_1 <= not(to_ssd(BCD_SEC(3 downto 0)));
 SSD_2 <= not(to_ssd(BCD_SEC(7 downto 4)));
 SSD_MIN1 <= to_ssd(BCD_MIN(3 downto 0));
 SSD_MIN2 <= to_ssd(BCD_MIN(7 downto 4));
 SSD_HRS1 <= to_ssd(BCD_HRS(3 downto 0));
 SSD_HRS2 <= to_ssd(BCD_HRS(7 downto 4));
 
process(clk, reset)
begin 
    if(reset='1') then
        refresh_counter <= (others => '0');
    elsif(rising_edge(clk)) then
        refresh_counter <= refresh_counter + 1;
    end if;
end process;
 LED_activating_counter <= refresh_counter(19 downto 18);
-- 4-to-1 MUX to generate anode activating signals for 4 LEDs 
process(LED_activating_counter)
begin
    case LED_activating_counter is
    when "00" =>
        Anode_Activate <= "0111"; 
        -- activate LED1 and Deactivate LED2, LED3, LED4
        LED_OUT <= SSD_HRS2;
        -- the first hex digit of the 16-bit number
    when "01" =>
        Anode_Activate <= "1011"; 
        -- activate LED2 and Deactivate LED1, LED3, LED4
        LED_OUT <= SSD_HRS1;
        -- the second hex digit of the 16-bit number
    when "10" =>
        Anode_Activate <= "1101"; 
        -- activate LED3 and Deactivate LED2, LED1, LED4
        LED_OUT <= SSD_MIN2;
        -- the third hex digit of the 16-bit number
    when "11" =>
        Anode_Activate <= "1110"; 
        -- activate LED4 and Deactivate LED2, LED3, LED1
        LED_OUT <= SSD_MIN1;
        -- the fourth hex digit of the 16-bit number    
	when others => LED_OUT <= "0000000";
    end case;
end process;
process(LED_activating_counter)
begin
    case LED_activating_counter is
    when "00" =>
        SSD_OUT <= SSD_1; 
        SWITCH <= '0';
    when "01" =>
        SSD_OUT <= SSD_2; 
        SWITCH <= '1';  
	when "10" => 
	    SSD_OUT <= SSD_1; 
        SWITCH <= '0';
	when "11" =>
        SSD_OUT <= SSD_2; 
        SWITCH <= '1';	
    end case;
end process;
 
end CLK_ARC;