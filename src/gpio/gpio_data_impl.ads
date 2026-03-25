with Gpio_Data;
with STM32G431_GPIO;

package Gpio_Data_Impl is new Gpio_Data
  (Pin           => STM32G431_GPIO.Pin,
   Driver_Set    => STM32G431_GPIO.Driver_Set,
   Driver_Clr    => STM32G431_GPIO.Driver_Clr,
   Driver_Toggle => STM32G431_GPIO.Driver_Toggle,
   Driver_Read   => STM32G431_GPIO.Driver_Read);