The 6502 does not place any hard constraints, or meaning to any of the memory locations in the CPU. The Apple II uses the following map:

(from http://apple2history.org/history/ah03.html)

```
Page $00:		used by the 6502 processor for storage of information that it can access quickly.  This is prime real-estate that is seldom available for general use by programmers without special care.
Page $01:		used by the 6502 for internal operations as a "stack."
Page $02:		used by the Apple II firmware as an input buffer when using the keyboard from BASIC, or when a program uses any of the firmware input routines.
Page $03:		general storage area, up to the top three rows (from $3D0 through $3FF) which are used by the disk operating system and the firmware for pointers to internal routines.
Pages $04-$07:		used for the 40 column text screen.
Pages $08-$BF:		available for use by programs, operating systems, and for hi-res graphics.  Within this space, Woz designated pages $08-$0A as a secondary text and lo-res graphics page (although it was not easy to directly use, as the firmware did not support it), pages $20-$3F for hi-res "page" one, and pages $40-$5F for hi-res "page" two.
Page $C0:		internal I/O and softswitches
Pages $C1-$C7:		ROM assigned to each of the seven peripheral cards
Pages $C8-$CF:		switchable ROM available for each of the seven cards
Pages $D0-$D7:		empty ROM socket #1
Pages $D8-$DF:		empty ROM socket #2
Pages $E0-$F7:		Integer BASIC ROM
Pages $F8-$FF:		Monitor ROM
```