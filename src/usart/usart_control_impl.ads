with Usart_Control;
with STM32G431KB_USART;

package Usart_Control_Impl is new Usart_Control
     (Device       => STM32G431KB_USART.Device,
      Driver_Init  => STM32G431KB_USART.Init,
      Driver_Start => STM32G431KB_USART.Start,
      Driver_Stop  => STM32G431KB_USART.Stop,
      Driver_Reset => STM32G431KB_USART.Reset);