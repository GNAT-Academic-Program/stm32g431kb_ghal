# stm32g431

STM32G431 Hardware Abstraction Layer for bare-metal Ada applications.

## Overview

`stm32g431` provides hardware-specific implementations of generic peripheral interfaces for the STM32G431 microcontroller family. It instantiates generic packages (GPIO, SPI, I2C, USART) with STM32G431-specific drivers, providing a vendor-neutral API at the MCU level.

## Features

- STM32G431-specific peripheral drivers
- SVD-generated register definitions
- Clock tree configuration
- Generic interface instantiations for:
  - GPIO (General Purpose Input/Output)
  - SPI (Serial Peripheral Interface)
  - I2C (Inter-Integrated Circuit)
  - USART (Universal Synchronous/Asynchronous Receiver/Transmitter)

## Architecture

This crate sits between generic peripheral interfaces and board support packages:

```
Application
    ↓
Board Package (nucleo_g431kb)
    ↓
MCU Package (stm32g431) ← This crate
    ↓
Generic Interfaces (gpio_generic, spi_generic, i2c_generic, usart_generic)
```

## Usage

Typically used as a dependency of board support packages. For direct use:

```ada
with Gpio;
with STM32G431_GPIO;

Led_Pin : Gpio.Pin := STM32G431_GPIO.Make_Pin (STM32G431_GPIO.B, 8);
```

## Integration

Add to your `alire.toml`:

```toml
[[depends-on]]
stm32g431 = "^0.1.0"
```

## Dependencies

- `gpio_generic` - Generic GPIO interface
- `spi_generic` - Generic SPI interface
- `i2c_generic` - Generic I2C interface
- `usart_generic` - Generic USART interface
- `debug_generic` - Generic debug output
- `machine_types` - Machine-level types
- `light_tasking_stm32g4xx` - Lightweight Ada runtime

## License

MIT OR Apache-2.0 WITH LLVM-exception
