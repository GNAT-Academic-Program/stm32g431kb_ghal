with Usart_Data;
with STM32G431KB_USART;

package Usart_Data_Impl is new Usart_Data
     (Device         => STM32G431KB_USART.Device,
      Driver_Tx_Push => STM32G431KB_USART.Tx_Push,
      Driver_Rx_Pop  => STM32G431KB_USART.Rx_Pop);