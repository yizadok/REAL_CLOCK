library IEEE;
  use IEEE.std_logic_1164.all;
  use IEEE.std_logic_unsigned.all;

entity TB_CNTR is
end TB_CNTR;

architecture TB_CNTR_ARC of TB_CNTR is

component REAL_CLOCK
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
  SWITCH: out std_logic

);
end component;

signal tbCLK:    std_logic := '1';
signal tbRESET:  std_logic;
signal TESTMODE: std_logic;

signal SECONDS: std_logic_vector(7 downto 0);
signal MINUTES: std_logic_vector(7 downto 0);
signal HOURS: std_logic_vector(7 downto 0);

signal LED_activating_counter: std_logic_vector(1 downto 0);
signal TBAddrs: std_logic_vector(1 downto 0);
signal TBdata: std_logic_vector(5 downto 0);
signal TBload: std_logic;

begin

DUT: REAL_CLOCK
port map
(
  CLK   => tbCLK,
  RESET => tbRESET,
  TESTMODE => TESTMODE,
  ADDRS => TBAddrs,
  DATA   => TBdata,
  LOAD   => TBload
  
);
TBAddrs <= "00";
TBdata <= "000000";
TBload <= '0';

TESTMODE <= '1',
             '0' after 113 ns;
L1: tbRESET <= '1',
               '0' after 113 ns;

L2:process
begin
  wait for 5 ns;
  tbCLK <= not(tbCLK);
end process;

end TB_CNTR_ARC;