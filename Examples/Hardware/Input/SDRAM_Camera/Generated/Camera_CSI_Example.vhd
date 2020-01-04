  
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all; 
use work.sdram_config.all;
use work.sdram_controller_interface.all;

      
ENTITY Camera_CSI_Example IS

PORT (
  CLK : IN STD_LOGIC;
  Camera_CLK_Lane      : IN     STD_LOGIC;
  Camera_Data_Lane     : IN     STD_LOGIC_VECTOR (1 downto 0);
  Camera_Enable        : OUT    STD_LOGIC;
  Camera_SCL           : INOUT  STD_LOGIC;
  Camera_SDA           : INOUT  STD_LOGIC;
  oSDRAM_ADDR          : BUFFER STD_LOGIC_VECTOR(11 downto 0);
  oSDRAM_BA            : OUT    STD_LOGIC_VECTOR(1 downto 0);
  bSDRAM_DQ            : INOUT  STD_LOGIC_VECTOR(15 downto 0);
  oSDRAM_DQM           : OUT    STD_LOGIC_VECTOR(1 downto 0);
  oSDRAM_CASn          : OUT    STD_LOGIC;
  oSDRAM_CKE           : OUT    STD_LOGIC;
  oSDRAM_CSn           : OUT    STD_LOGIC;
  oSDRAM_RASn          : OUT    STD_LOGIC;
  oSDRAM_WEn           : OUT    STD_LOGIC;
  oSDRAM_CLK           : BUFFER STD_LOGIC;
  oHDMI_TX             : OUT    STD_LOGIC_VECTOR(2 downto 0);
  oHDMI_CLK            : OUT    STD_LOGIC;
  iHDMI_HPD            : IN     STD_LOGIC

);
END Camera_CSI_Example;

ARCHITECTURE BEHAVIORAL OF Camera_CSI_Example IS

  SIGNAL Camera_Pixel_R       : STD_LOGIC_VECTOR (7 downto 0);
  SIGNAL Camera_Pixel_G       : STD_LOGIC_VECTOR (7 downto 0);
  SIGNAL Camera_Pixel_B       : STD_LOGIC_VECTOR (7 downto 0);
  SIGNAL Camera_Column        : NATURAL          range 0 to 639;
  SIGNAL Camera_Row           : NATURAL          range 0 to 479;
  SIGNAL Camera_New_Pixel     : STD_LOGIC;
  SIGNAL Camera_Capture_Read_Column : NATURAL          range 0 to 639;
  SIGNAL Camera_Capture_Read_Row    : NATURAL          range 0 to 479;
  SIGNAL Camera_Capture_Read_Data   : STD_LOGIC_VECTOR (23 downto 0);
  SIGNAL Camera_Capture_SDRAM_Read_Ena      : STD_LOGIC;
  SIGNAL HDMI_Out_VS_PCLK   : STD_LOGIC;
  SIGNAL HDMI_Out_VS_SCLK   : STD_LOGIC;
  SIGNAL HDMI_Out_VS_R      : STD_LOGIC_VECTOR (7 downto 0);
  SIGNAL HDMI_Out_VS_G      : STD_LOGIC_VECTOR (7 downto 0);
  SIGNAL HDMI_Out_VS_B      : STD_LOGIC_VECTOR (7 downto 0);
  SIGNAL HDMI_Out_VS_HS     : STD_LOGIC;
  SIGNAL HDMI_Out_VS_VS     : STD_LOGIC;
  SIGNAL HDMI_Out_VS_DE     : STD_LOGIC;
  COMPONENT Test_Image_Generator IS
  GENERIC (
      image_size_div : NATURAL := 1;
    pixel_clk_div  : NATURAL := 1 

  );
  PORT (
    CLK : IN STD_LOGIC;
    oPixel_R   : OUT STD_LOGIC_VECTOR (7 downto 0);
    oPixel_G   : OUT STD_LOGIC_VECTOR (7 downto 0);
    oPixel_B   : OUT STD_LOGIC_VECTOR (7 downto 0);
    oColumn    : OUT NATURAL range 0 to 639 := 0;
    oRow       : OUT NATURAL range 0 to 479 := 0;
    oNew_Pixel : OUT STD_LOGIC

  );
  END COMPONENT;
  COMPONENT Test_Image_Generator2 IS
  GENERIC (
      image_size_div : NATURAL := 1

  );
  PORT (
    CLK : IN STD_LOGIC;
    oPixel_R   : OUT STD_LOGIC_VECTOR (7 downto 0);
    oPixel_G   : OUT STD_LOGIC_VECTOR (7 downto 0);
    oPixel_B   : OUT STD_LOGIC_VECTOR (7 downto 0);
    iColumn    : IN  NATURAL range 0 to 639 := 0;
    iRow       : IN  NATURAL range 0 to 479 := 0;
    iNewPixel  : IN  STD_LOGIC

  );
  END COMPONENT;
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
    Read_Data   : BUFFER STD_LOGIC_VECTOR(23 downto 0) := (others => '0');
    Read_Ena    : IN     STD_LOGIC := '0'

  );
  END COMPONENT;
  COMPONENT CRT_Controller IS
  GENERIC (
      image_size_div : NATURAL := 1

  );
  PORT (
    CLK : IN STD_LOGIC;
    Read_Column : OUT    NATURAL range 0 to 639 := 0;
    Read_Row    : OUT    NATURAL range 0 to 479 := 0;
    Read_Data   : IN     STD_LOGIC_VECTOR(23 downto 0) := (others => '0');
    Read_Ena    : OUT    STD_LOGIC := '0';
    VS_PCLK    : OUT    STD_LOGIC;
    VS_SCLK    : OUT    STD_LOGIC;
    VS_R       : OUT    STD_LOGIC_VECTOR (7 downto 0);
    VS_G       : OUT    STD_LOGIC_VECTOR (7 downto 0);
    VS_B       : OUT    STD_LOGIC_VECTOR (7 downto 0);
    VS_HS      : OUT    STD_LOGIC;
    VS_VS      : OUT    STD_LOGIC;
    VS_DE      : OUT    STD_LOGIC

  );
  END COMPONENT;
  COMPONENT HDMI_Out IS
  
  PORT (
    CLK : IN STD_LOGIC;
    VS_PCLK    : IN  STD_LOGIC;
    VS_SCLK    : IN  STD_LOGIC;
    VS_R       : IN  STD_LOGIC_VECTOR (7 downto 0);
    VS_G       : IN  STD_LOGIC_VECTOR (7 downto 0);
    VS_B       : IN  STD_LOGIC_VECTOR (7 downto 0);
    VS_HS      : IN  STD_LOGIC;
    VS_VS      : IN  STD_LOGIC;
    VS_DE      : IN  STD_LOGIC;
    oHDMI_DATA : OUT STD_LOGIC_VECTOR(2 downto 0);
    oHDMI_CLK  : OUT STD_LOGIC;
    iHDMI_HPD  : IN  STD_LOGIC

  );
  END COMPONENT;
  
BEGIN

  Camera_Enable <= '1';
  Test_Image_Generator1 : Test_Image_Generator
  GENERIC MAP (
      image_size_div => 1,
    pixel_clk_div  => 5

  ) PORT MAP (
    CLK => CLK,
    oColumn        => Camera_Column,
    oRow           => Camera_Row,
    oNew_Pixel     => Camera_New_Pixel

    
  );
  Test_Image_Generator21 : Test_Image_Generator2
  GENERIC MAP (
      image_size_div => 1

  ) PORT MAP (
    CLK => CLK,
    oPixel_R     => Camera_Pixel_R,
    oPixel_G     => Camera_Pixel_G,
    oPixel_B     => Camera_Pixel_B,
    iColumn      => Camera_Column,
    iRow         => Camera_Row,
    iNewPixel    => Camera_New_Pixel

    
  );
  Camera_Capture_SDRAM1 : Camera_Capture_SDRAM
  GENERIC MAP (
      Burst_Length => 8

  ) PORT MAP (
    CLK => CLK,
    New_Pixel   => Camera_New_Pixel,
    Column      => Camera_Column,
    Row         => Camera_Row,
    Pixel_R     => Camera_Pixel_R,
    Pixel_G     => Camera_Pixel_G,
    Pixel_B     => Camera_Pixel_B,
    SDRAM_ADDR  => oSDRAM_ADDR,
    SDRAM_BA    => oSDRAM_BA,
    SDRAM_DQ    => bSDRAM_DQ,
    SDRAM_DQM   => oSDRAM_DQM,
    SDRAM_CASn  => oSDRAM_CASn,
    SDRAM_CKE   => oSDRAM_CKE,
    SDRAM_CSn   => oSDRAM_CSn,
    SDRAM_RASn  => oSDRAM_RASn,
    SDRAM_WEn   => oSDRAM_WEn,
    SDRAM_CLK   => oSDRAM_CLK,
    Read_Column => Camera_Capture_Read_Column,
    Read_Row    => Camera_Capture_Read_Row,
    Read_Data   => Camera_Capture_Read_Data,
    Read_Ena    => Camera_Capture_SDRAM_Read_Ena

    
  );
  CRT_Controller1 : CRT_Controller
  GENERIC MAP (
      image_size_div => 1

  ) PORT MAP (
    CLK => CLK,
    Read_Column => Camera_Capture_Read_Column,
    Read_Row    => Camera_Capture_Read_Row,
    Read_Data   => Camera_Capture_Read_Data,
    Read_Ena    => Camera_Capture_SDRAM_Read_Ena,
    VS_PCLK     => HDMI_Out_VS_PCLK,
    VS_SCLK     => HDMI_Out_VS_SCLK,
    VS_R        => HDMI_Out_VS_R,
    VS_G        => HDMI_Out_VS_G,
    VS_B        => HDMI_Out_VS_B,
    VS_HS       => HDMI_Out_VS_HS,
    VS_VS       => HDMI_Out_VS_VS,
    VS_DE       => HDMI_Out_VS_DE

    
  );
  HDMI_Out1 : HDMI_Out  PORT MAP (
    CLK => CLK,
    VS_PCLK    => HDMI_Out_VS_PCLK,
    VS_SCLK    => HDMI_Out_VS_SCLK,
    VS_R       => HDMI_Out_VS_R,
    VS_G       => HDMI_Out_VS_G,
    VS_B       => HDMI_Out_VS_B,
    VS_HS      => HDMI_Out_VS_HS,
    VS_VS      => HDMI_Out_VS_VS,
    VS_DE      => HDMI_Out_VS_DE,
    oHDMI_DATA => oHDMI_TX,
    oHDMI_CLK  => oHDMI_CLK,
    iHDMI_HPD  => iHDMI_HPD
  );
  
END BEHAVIORAL;