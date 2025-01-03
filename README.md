# turbopascal-xlib-unit
This Pascal unit, xlibunit, is a graphics library designed for use in Turbo Pascal programs. It provides various procedures for initializing and manipulating VGA graphics modes, handling color palettes, and drawing on the screen. It's particularly useful for creating graphic demos.

## Compile
Compile.bat uses Turbo Pascal 6.0 installed in c:\progrs\tp\
```
compile.bat
```

## Methods

| **Method**         | **Description**                                                                 |
|--------------------|---------------------------------------------------------------------------------|
| `initxlib`         | Initializes VGA mode 13.                                                        |
| `initxmode`        | Initializes extended mode.                                                      |
| `clearxmode`       | Quickly clears the screen in extended mode.                                     |
| `cleartext`        | Quickly clears the screen in text mode.                                         |
| `exitxlib`         | Exits the library and initializes VGA mode 3.                                   |
| `point`            | Draws a point in extended mode.                                                 |
| `blackpal`         | Sets all colors to black.                                                       |
| `vert_retr`        | Waits for vertical retrace.                                                     |
| `fadeup`           | Fades up the palette.                                                           |
| `fadedown`         | Fades down the palette.                                                         |
| `copypic13`        | Copies a picture from a segment and offset to VGA in mode 13.                   |
| `copypicx`         | Copies a picture from a segment and offset to VGA in extended mode.             |
| `copypicxd`        | Copies a picture in virtual horizontal 640 mode.                                |
| `copypal`          | Copies a palette from a segment and offset to another palette.                  |
| `startingarea`     | Sets the linear starting area.                                                  |
| `vert400`          | Switches to 320x400 resolution.                                                 |
| `vert200`          | Switches to 320x200 resolution.                                                 |
| `vert100`          | Switches to 320x100 resolution (not tested).                                    |
| `hor640`           | Switches to virtual horizontal 640 resolution.                                  |
| `hor320`           | Switches to normal horizontal 320 resolution.                                   |
| `vpan`             | Vertical panning.                                                               |
| `hpan`             | Horizontal panning.                                                             |
| `hbegin`           | Sets the horizontal start position.                                             |
| `CRTC_UnProtect`   | Unprotects the CRTC (Cathode Ray Tube Controller).                              |
| `CRTC_Protect`     | Protects the CRTC.                                                              |
| `unprotect`        | Unprotects the screen.                                                          |
| `protect`          | Protects the screen.                                                            |
| `hor_retr`         | Waits for horizontal retrace.                                                   |
| `moveblock`        | Moves a block of memory.                                                        |
| `setdac`           | Sets the DAC (Digital-to-Analog Converter) color.                               |
| `print`            | Prints text on the screen.                                                      |
| `locate`           | Sets the cursor position.                                                       |
| `key`              | Checks if a key is pressed.                                                     |
