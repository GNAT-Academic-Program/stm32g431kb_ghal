with Gpio_Control;
with STM32G431_GPIO;

package Gpio_Control_Impl is new Gpio_Control
  (Pin              => STM32G431_GPIO.Pin,
   Driver_Configure => STM32G431_GPIO.Driver_Configure);