package Clock_Tree is

   function Get_HCLK  return Natural;
   function Get_PCLK1 return Natural;
   function Get_PCLK2 return Natural;

   --  Per-peripheral clock functions

   function Get_SPI1_Clock return Natural;
   function Get_SPI2_Clock return Natural;
   function Get_SPI3_Clock return Natural;

   function Get_I2C1_Clock return Natural;
   function Get_I2C2_Clock return Natural;
   function Get_I2C3_Clock return Natural;

   function Get_USART1_Clock return Natural;
   function Get_USART2_Clock return Natural;
   function Get_USART3_Clock return Natural;
   function Get_UART4_Clock  return Natural;

   --  RCC enable hooks

   procedure Enable_SPI1;
   procedure Enable_SPI2;
   procedure Enable_SPI3;

   procedure Enable_USART1;
   procedure Enable_USART2;
   procedure Enable_USART3;
   procedure Enable_UART4;

   procedure Enable_I2C1;
   procedure Enable_I2C2;
   procedure Enable_I2C3;

   --  RCC reset hooks

   procedure Reset_SPI1;
   procedure Reset_SPI2;
   procedure Reset_SPI3;

   procedure Reset_USART1;
   procedure Reset_USART2;
   procedure Reset_USART3;
   procedure Reset_UART4;

   procedure Reset_I2C1;
   procedure Reset_I2C2;
   procedure Reset_I2C3;

end Clock_Tree;