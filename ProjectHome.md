This snippet I wrote uses a library I found in the forums somewhere to drive up to 8 servo's on any pin except pin 8, using timer2. Timer1 is used to capture a ppm sum stream from any receiver that's able to output such a combined stream.

Some AVR chips only have one 16bit timer and combining this timer with servo writes is very complicated. The 8bit timer is by default not a good solution to drive the servo's, because it results in poor resolution. This code uses the overflow of the 8bit timer to be able to count beyond 255, yielding 1us resolution on the servo's anyway.

In combination with the capture, you can now use this code on any project that uses a much simpler AVR chip and you could add some additional logic to drive the servo's differently.

I wrote this code for example for the 328 chip on the ArduIMUv3, which allows one to develop control systems that keep platforms level or at some defined angle.