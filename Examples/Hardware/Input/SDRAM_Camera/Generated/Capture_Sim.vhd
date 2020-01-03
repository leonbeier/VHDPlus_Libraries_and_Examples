  
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all; 


ENTITY Camera_Capture_SDRAM_tb IS
END Camera_Capture_SDRAM_tb;

ARCHITECTURE BEHAVIORAL OF Camera_Capture_SDRAM_tb IS

  SIGNAL finished : STD_LOGIC:= '0';
  CONSTANT period_time : TIME := 10000 ps;
  SIGNAL New_Pixel : STD_LOGIC  := '0';
  SIGNAL Column : NATURAL range 0 to 639 := 0;
  SIGNAL Row : NATURAL range 0 to 479 := 0;
  SIGNAL Pixel_R : STD_LOGIC_VECTOR (7 downto 0) := (others => '0');
  SIGNAL Pixel_G : STD_LOGIC_VECTOR (7 downto 0) := (others => '0');
  SIGNAL Pixel_B : STD_LOGIC_VECTOR (7 downto 0) := (others => '0');
  SIGNAL SDRAM_ADDR : STD_LOGIC_VECTOR (11 downto 0);
  SIGNAL SDRAM_BA : STD_LOGIC_VECTOR (1 downto 0);
  SIGNAL SDRAM_DQ : STD_LOGIC_VECTOR (15 downto 0) := (others => '0');
  SIGNAL SDRAM_DQM : STD_LOGIC_VECTOR (1 downto 0);
  SIGNAL SDRAM_CASn : STD_LOGIC ;
  SIGNAL SDRAM_CKE : STD_LOGIC ;
  SIGNAL SDRAM_CSn : STD_LOGIC ;
  SIGNAL SDRAM_RASn : STD_LOGIC ;
  SIGNAL SDRAM_WEn : STD_LOGIC ;
  SIGNAL SDRAM_CLK : STD_LOGIC ;
  SIGNAL Read_Column : NATURAL range 0 to 639 := 0;
  SIGNAL Read_Row : NATURAL range 0 to 479 := 0;
  SIGNAL Read_Data : STD_LOGIC_VECTOR (23 downto 0) := (others => '0');
  SIGNAL Read_Ena : STD_LOGIC  := '0';
  SIGNAL CLK : STD_LOGIC := '0';
  COMPONENT Camera_Capture_SDRAM IS
  GENERIC (
      Burst_Length : NATURAL := 8

  );
  PORT (
    CLK : IN STD_LOGIC;
    New_Pixel   : IN    STD_LOGIC := '0';
    Column      : IN    NATURAL range 0 to 639 := 0;
    Row         : IN    NATURAL range 0 to 479 := 0;
    Pixel_R     : IN    STD_LOGIC_VECTOR(7 downto 0) := (others => '0');
    Pixel_G     : IN    STD_LOGIC_VECTOR(7 downto 0) := (others => '0');
    Pixel_B     : IN    STD_LOGIC_VECTOR(7 downto 0) := (others => '0');
    SDRAM_ADDR  : OUT   STD_LOGIC_VECTOR(11 downto 0);
    SDRAM_BA    : OUT   STD_LOGIC_VECTOR(1 downto 0);
    SDRAM_DQ    : INOUT STD_LOGIC_VECTOR(15 downto 0);
    SDRAM_DQM   : OUT   STD_LOGIC_VECTOR(1 downto 0);
    SDRAM_CASn  : OUT   STD_LOGIC;
    SDRAM_CKE   : OUT   STD_LOGIC;
    SDRAM_CSn   : OUT   STD_LOGIC;
    SDRAM_RASn  : OUT   STD_LOGIC;
    SDRAM_WEn   : OUT   STD_LOGIC;
    SDRAM_CLK   : OUT   STD_LOGIC;
    Read_Column : IN     NATURAL range 0 to 639 := 0;
    Read_Row    : IN     NATURAL range 0 to 479 := 0;
    Read_Data   : OUT    STD_LOGIC_VECTOR(23 downto 0) := (others => '0');
    Read_Ena    : IN     STD_LOGIC := '0'

  );
  END COMPONENT;
  COMPONENT SDRAM_sdram_controller_0_test_component IS
  
  PORT (
    clk : IN STD_LOGIC;
                     zs_addr : IN STD_LOGIC_VECTOR (11 DOWNTO 0);
                     zs_ba : IN STD_LOGIC_VECTOR (1 DOWNTO 0);
                     zs_cas_n : IN STD_LOGIC;
                     zs_cke : IN STD_LOGIC;
                     zs_cs_n : IN STD_LOGIC;
                     zs_dqm : IN STD_LOGIC_VECTOR (1 DOWNTO 0);
                     zs_ras_n : IN STD_LOGIC;
                     zs_we_n : IN STD_LOGIC;

              
                     zs_dq : INOUT STD_LOGIC_VECTOR (15 DOWNTO 0)
              
  );
  END COMPONENT;
  
BEGIN
  Sim_finished : PROCESS 
    
  BEGIN
    wait for 500 ms;
    finished <= '1';
    wait;
  END PROCESS;
  Camera_Capture_SDRAM1 : Camera_Capture_SDRAM
  GENERIC MAP (
      Burst_Length => 256

  ) PORT MAP (
    New_Pixel => New_Pixel,
    Column => Column,
    Row => Row,
    Pixel_R => Pixel_R,
    Pixel_G => Pixel_G,
    Pixel_B => Pixel_B,
    SDRAM_ADDR => SDRAM_ADDR,
    SDRAM_BA => SDRAM_BA,
    SDRAM_DQ => SDRAM_DQ,
    SDRAM_DQM => SDRAM_DQM,
    SDRAM_CASn => SDRAM_CASn,
    SDRAM_CKE => SDRAM_CKE,
    SDRAM_CSn => SDRAM_CSn,
    SDRAM_RASn => SDRAM_RASn,
    SDRAM_WEn => SDRAM_WEn,
    SDRAM_CLK => SDRAM_CLK,
    Read_Column => Read_Column,
    Read_Row => Read_Row,
    Read_Data => Read_Data,
    Read_Ena => Read_Ena,
    CLK => CLK

    
  );
  SDRAM_sdram_controller_0_test_component1 : SDRAM_sdram_controller_0_test_component  PORT MAP (
    clk      => SDRAM_CLK,
    zs_addr  => SDRAM_ADDR,
    zs_ba    => SDRAM_BA,
    zs_cas_n => SDRAM_CASn,
    zs_cke   => SDRAM_CKE,
    zs_cs_n  => SDRAM_CSn,
    zs_dqm   => SDRAM_DQM,
    zs_ras_n => SDRAM_RASn,
    zs_we_n  => SDRAM_WEn,
    zs_dq    => SDRAM_DQ
  );
  Sim_New_Pixel : PROCESS 
    
  BEGIN
    WHILE finished /= '1' LOOP
      New_Pixel <= '0';
      wait for 3 * period_time;
      New_Pixel <= '1';
      wait for 1 * period_time;
    END LOOP;
  
    wait;
  END PROCESS;
  Sim_Column : PROCESS 
    
  BEGIN
    WHILE finished /= '1' LOOP
      FOR i IN 0 to 639 LOOP
        Column <= i;
        wait for 4 * period_time;
      END LOOP;
    END LOOP;
  
    wait;
  END PROCESS;
  Sim_Row : PROCESS 
    
  BEGIN
    WHILE finished /= '1' LOOP
      FOR i IN 0 to 479 LOOP
        Row <= i;
        wait for 2560 * period_time;
      END LOOP;
    END LOOP;
  
    wait;
  END PROCESS;
  Sim_Pixel_R : PROCESS 
    
  BEGIN
    WHILE finished /= '1' LOOP
      FOR i IN 0 to 255 LOOP
        Pixel_R <= STD_LOGIC_VECTOR(TO_UNSIGNED(i, 8));
        wait for 4 * period_time;
      END LOOP;
    END LOOP;
  
    wait;
  END PROCESS;
  Sim_Pixel_G : PROCESS 
    
  BEGIN
    WHILE finished /= '1' LOOP
      FOR i IN 255 downto 0 LOOP
        Pixel_G <= STD_LOGIC_VECTOR(TO_UNSIGNED(i, 8));
        wait for 1024 * period_time;
      END LOOP;
    END LOOP;
  
    wait;
  END PROCESS;
  Sim_Pixel_B : PROCESS 
    
  BEGIN
    WHILE finished /= '1' LOOP
      FOR i IN 0 to 255 LOOP
        Pixel_B <= STD_LOGIC_VECTOR(TO_UNSIGNED(i, 8));
        wait for 261120 * period_time;
      END LOOP;
    END LOOP;
  
    wait;
  END PROCESS;
  Sim_Read_Column : PROCESS 
    
  BEGIN
wait for 5000 * period_time;
    WHILE finished /= '1' LOOP
      
      FOR i IN 0 to 639 LOOP
        Read_Column <= i;
        wait for 4 * period_time;
      END LOOP;
    END LOOP;
  
    wait;
  END PROCESS;
  Sim_Read_Row : PROCESS 
    
  BEGIN
wait for 5000 * period_time;
    WHILE finished /= '1' LOOP
      
      FOR i IN 0 to 479 LOOP
        Read_Row <= i;
        wait for 2560 * period_time;
      END LOOP;
    END LOOP;
  
    wait;
  END PROCESS;
  Sim_Read_Ena : PROCESS 
    
  BEGIN
    WHILE finished /= '1' LOOP
      Read_Ena <= '0';
      wait for 2 * period_time;
      Read_Ena <= '1';
      wait for 1  * period_time;
      Read_Ena <= '0';
      wait for 1 * period_time;
    END LOOP;
  
    wait;
  END PROCESS;
  Sim_CLK : PROCESS
  BEGIN
    WHILE finished /= '1' LOOP
      CLK <= '0';
      wait for period_time/2;
      CLK <= '1';
      wait for period_time/2;
    END LOOP;
  
    wait;
  END PROCESS;
  
END BEHAVIORAL;