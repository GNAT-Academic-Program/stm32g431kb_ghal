--  TODO: patch SVD upstream — fields SP3EN, I2C3 (in APB1ENR1 and
--  APB1RSTR1), SP3SMEN, I2C3SMEN_3 are svd2ada artifacts of ST's broken
--  SVD. Fix once crate stack is stable; will let us drop the inline
--  apology comments in this file.

with Stm32g431_Config;
with STM32G431xx.RCC;

package body Clock_Tree is

   use STM32G431xx;

   --  ----------------------------------------------------------------------
   --  Fixed MCU constants
   --  ----------------------------------------------------------------------

   HSI16_Freq : constant Natural := 16_000_000;
   LSE_Freq   : constant Natural := 32_768;

   --  ----------------------------------------------------------------------
   --  SYSCLK computation from Alire config
   --  ----------------------------------------------------------------------

   function PLL_R_Divisor return Natural is
   begin
      case Stm32g431_Config.PLL_R_Div is
         when Stm32g431_Config.DIV2 => return 2;
         when Stm32g431_Config.DIV4 => return 4;
         when Stm32g431_Config.DIV6 => return 6;
         when Stm32g431_Config.DIV8 => return 8;
      end case;
   end PLL_R_Divisor;

   function PLL_Input_Freq return Natural is
   begin
      case Stm32g431_Config.PLL_Src is
         when Stm32g431_Config.HSI16 => return HSI16_Freq;
         when Stm32g431_Config.HSE   => return Stm32g431_Config.HSE_Hz;
      end case;
   end PLL_Input_Freq;

   function Compute_SYSCLK return Natural is
   begin
      case Stm32g431_Config.SYSCLK_Src is
         when Stm32g431_Config.HSI16   => return HSI16_Freq;
         when Stm32g431_Config.HSE     => return Stm32g431_Config.HSE_Hz;
         when Stm32g431_Config.PLLRCLK =>
            return (PLL_Input_Freq / Stm32g431_Config.PLL_M_Div)
                  * Stm32g431_Config.PLL_N_Mul
                  / PLL_R_Divisor;
      end case;
   end Compute_SYSCLK;

   SYSCLK_Freq : constant Natural := Compute_SYSCLK;

   --  ----------------------------------------------------------------------
   --  Bus clocks (read live from RCC prescalers)
   --  ----------------------------------------------------------------------

   function Get_HCLK return Natural is
   begin
      case RCC.RCC_Periph.CFGR.HPRE is
         when 16#0# .. 16#7# => return SYSCLK_Freq;
         when 16#8#          => return SYSCLK_Freq / 2;
         when 16#9#          => return SYSCLK_Freq / 4;
         when 16#A#          => return SYSCLK_Freq / 8;
         when 16#B#          => return SYSCLK_Freq / 16;
         when 16#C#          => return SYSCLK_Freq / 64;
         when 16#D#          => return SYSCLK_Freq / 128;
         when 16#E#          => return SYSCLK_Freq / 256;
         when 16#F#          => return SYSCLK_Freq / 512;
      end case;
   end Get_HCLK;

   function Get_PCLK1 return Natural is
      HCLK  : constant Natural := Get_HCLK;
      PPRE1 : constant Natural :=
        Natural (RCC.RCC_Periph.CFGR.PPRE.Arr (1));
   begin
      case PPRE1 is
         when 16#0# .. 16#3# => return HCLK;
         when 16#4#          => return HCLK / 2;
         when 16#5#          => return HCLK / 4;
         when 16#6#          => return HCLK / 8;
         when 16#7#          => return HCLK / 16;
         when others         => raise Program_Error;
      end case;
   end Get_PCLK1;

   function Get_PCLK2 return Natural is
      HCLK  : constant Natural := Get_HCLK;
      PPRE2 : constant Natural :=
        Natural (RCC.RCC_Periph.CFGR.PPRE.Arr (2));
   begin
      case PPRE2 is
         when 16#0# .. 16#3# => return HCLK;
         when 16#4#          => return HCLK / 2;
         when 16#5#          => return HCLK / 4;
         when 16#6#          => return HCLK / 8;
         when 16#7#          => return HCLK / 16;
         when others         => raise Program_Error;
      end case;
   end Get_PCLK2;

   --  ----------------------------------------------------------------------
   --  Peripheral kernel clocks
   --
   --  NOTE: SPISEL is a single shared field — all three SPIs use the same
   --  kernel source. The per-function dispatch is only because SPI1 (APB2)
   --  vs SPI2/SPI3 (APB1) take different bus clocks when SPISEL = 0.
   --  ----------------------------------------------------------------------

   function Get_SPI1_Clock return Natural is
   begin
      case RCC.RCC_Periph.CCIPR1.SPISEL is
         when 0      => return Get_PCLK2;
         when 1      => return SYSCLK_Freq;
         when 2      => return HSI16_Freq;
         when others => raise Program_Error;
      end case;
   end Get_SPI1_Clock;

   function Get_SPI2_Clock return Natural is
   begin
      case RCC.RCC_Periph.CCIPR1.SPISEL is
         when 0      => return Get_PCLK1;
         when 1      => return SYSCLK_Freq;
         when 2      => return HSI16_Freq;
         when others => raise Program_Error;
      end case;
   end Get_SPI2_Clock;

   function Get_SPI3_Clock return Natural is
   begin
      case RCC.RCC_Periph.CCIPR1.SPISEL is
         when 0      => return Get_PCLK1;
         when 1      => return SYSCLK_Freq;
         when 2      => return HSI16_Freq;
         when others => raise Program_Error;
      end case;
   end Get_SPI3_Clock;

   function Get_I2C1_Clock return Natural is
   begin
      case RCC.RCC_Periph.CCIPR1.I2C1SEL is
         when 0      => return Get_PCLK1;
         when 1      => return SYSCLK_Freq;
         when 2      => return HSI16_Freq;
         when others => raise Program_Error;
      end case;
   end Get_I2C1_Clock;

   function Get_I2C2_Clock return Natural is
   begin
      case RCC.RCC_Periph.CCIPR1.I2C2SEL is
         when 0      => return Get_PCLK1;
         when 1      => return SYSCLK_Freq;
         when 2      => return HSI16_Freq;
         when others => raise Program_Error;
      end case;
   end Get_I2C2_Clock;

   function Get_I2C3_Clock return Natural is
   begin
      case RCC.RCC_Periph.CCIPR1.I2C3SEL is
         when 0      => return Get_PCLK1;
         when 1      => return SYSCLK_Freq;
         when 2      => return HSI16_Freq;
         when others => raise Program_Error;
      end case;
   end Get_I2C3_Clock;

   function Get_USART1_Clock return Natural is
   begin
      case RCC.RCC_Periph.CCIPR1.USART1SEL is
         when 0 => return Get_PCLK2;
         when 1 => return SYSCLK_Freq;
         when 2 => return HSI16_Freq;
         when 3 => return LSE_Freq;
      end case;
   end Get_USART1_Clock;

   function Get_USART2_Clock return Natural is
   begin
      case RCC.RCC_Periph.CCIPR1.USART2SEL is
         when 0 => return Get_PCLK1;
         when 1 => return SYSCLK_Freq;
         when 2 => return HSI16_Freq;
         when 3 => return LSE_Freq;
      end case;
   end Get_USART2_Clock;

   function Get_USART3_Clock return Natural is
   begin
      case RCC.RCC_Periph.CCIPR1.USART3SEL is
         when 0 => return Get_PCLK1;
         when 1 => return SYSCLK_Freq;
         when 2 => return HSI16_Freq;
         when 3 => return LSE_Freq;
      end case;
   end Get_USART3_Clock;

   function Get_UART4_Clock return Natural is
   begin
      case RCC.RCC_Periph.CCIPR1.UART4SEL is
         when 0 => return Get_PCLK1;
         when 1 => return SYSCLK_Freq;
         when 2 => return HSI16_Freq;
         when 3 => return LSE_Freq;
      end case;
   end Get_UART4_Clock;

   --  ----------------------------------------------------------------------
   --  RCC enable hooks
   --
   --  Field name notes (SVD bugs in stm32g431xx.svd):
   --    APB1ENR1.SPI3EN is named SP3EN in the SVD
   --    APB1ENR1.I2C3EN is named I2C3   in the SVD
   --    APB1RSTR1.I2C3RST is named I2C3 in the SVD
   --  These names should be patched in the SVD upstream, but for now we
   --  use what svd2ada emits.
   --  ----------------------------------------------------------------------

   procedure Enable_SPI1 is
   begin
      RCC.RCC_Periph.APB2ENR.SPI1EN := 1;
   end Enable_SPI1;

   procedure Enable_SPI2 is
   begin
      RCC.RCC_Periph.APB1ENR1.SPI2EN := 1;
   end Enable_SPI2;

   procedure Enable_SPI3 is
   begin
      RCC.RCC_Periph.APB1ENR1.SP3EN := 1;  --  SVD: should be SPI3EN
   end Enable_SPI3;

   procedure Enable_USART1 is
   begin
      RCC.RCC_Periph.APB2ENR.USART1EN := 1;
   end Enable_USART1;

   procedure Enable_USART2 is
   begin
      RCC.RCC_Periph.APB1ENR1.USART2EN := 1;
   end Enable_USART2;

   procedure Enable_USART3 is
   begin
      RCC.RCC_Periph.APB1ENR1.USART3EN := 1;
   end Enable_USART3;

   procedure Enable_UART4 is
   begin
      RCC.RCC_Periph.APB1ENR1.UART4EN := 1;
   end Enable_UART4;

   procedure Enable_I2C1 is
   begin
      RCC.RCC_Periph.APB1ENR1.I2C1EN := 1;
   end Enable_I2C1;

   procedure Enable_I2C2 is
   begin
      RCC.RCC_Periph.APB1ENR1.I2C2EN := 1;
   end Enable_I2C2;

   procedure Enable_I2C3 is
   begin
      RCC.RCC_Periph.APB1ENR1.I2C3 := 1;  --  SVD: should be I2C3EN
   end Enable_I2C3;

   --  ----------------------------------------------------------------------
   --  RCC reset hooks
   --  ----------------------------------------------------------------------

   procedure Brief_Delay is
   begin
      for K in 1 .. 8 loop
         null;
         pragma Inspection_Point (K);
      end loop;
   end Brief_Delay;

   procedure Reset_SPI1 is
   begin
      RCC.RCC_Periph.APB2RSTR.SPI1RST := 1;
      Brief_Delay;
      RCC.RCC_Periph.APB2RSTR.SPI1RST := 0;
   end Reset_SPI1;

   procedure Reset_SPI2 is
   begin
      RCC.RCC_Periph.APB1RSTR1.SPI2RST := 1;
      Brief_Delay;
      RCC.RCC_Periph.APB1RSTR1.SPI2RST := 0;
   end Reset_SPI2;

   procedure Reset_SPI3 is
   begin
      RCC.RCC_Periph.APB1RSTR1.SPI3RST := 1;
      Brief_Delay;
      RCC.RCC_Periph.APB1RSTR1.SPI3RST := 0;
   end Reset_SPI3;

   procedure Reset_USART1 is
   begin
      RCC.RCC_Periph.APB2RSTR.USART1RST := 1;
      Brief_Delay;
      RCC.RCC_Periph.APB2RSTR.USART1RST := 0;
   end Reset_USART1;

   procedure Reset_USART2 is
   begin
      RCC.RCC_Periph.APB1RSTR1.USART2RST := 1;
      Brief_Delay;
      RCC.RCC_Periph.APB1RSTR1.USART2RST := 0;
   end Reset_USART2;

   procedure Reset_USART3 is
   begin
      RCC.RCC_Periph.APB1RSTR1.USART3RST := 1;
      Brief_Delay;
      RCC.RCC_Periph.APB1RSTR1.USART3RST := 0;
   end Reset_USART3;

   procedure Reset_UART4 is
   begin
      RCC.RCC_Periph.APB1RSTR1.UART4RST := 1;
      Brief_Delay;
      RCC.RCC_Periph.APB1RSTR1.UART4RST := 0;
   end Reset_UART4;

   procedure Reset_I2C1 is
   begin
      RCC.RCC_Periph.APB1RSTR1.I2C1RST := 1;
      Brief_Delay;
      RCC.RCC_Periph.APB1RSTR1.I2C1RST := 0;
   end Reset_I2C1;

   procedure Reset_I2C2 is
   begin
      RCC.RCC_Periph.APB1RSTR1.I2C2RST := 1;
      Brief_Delay;
      RCC.RCC_Periph.APB1RSTR1.I2C2RST := 0;
   end Reset_I2C2;

   procedure Reset_I2C3 is
   begin
      RCC.RCC_Periph.APB1RSTR1.I2C3 := 1;  --  SVD: should be I2C3RST
      Brief_Delay;
      RCC.RCC_Periph.APB1RSTR1.I2C3 := 0;
   end Reset_I2C3;

end Clock_Tree;