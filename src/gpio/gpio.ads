with Gpio_Interface;
with Gpio_Control_Impl;
with Gpio_Data_Impl;

with STM32G431_GPIO;

package Gpio is new Gpio_Interface
  (Pin     => STM32G431_GPIO.Pin,
   Control => Gpio_Control_Impl,
   Data    => Gpio_Data_Impl);