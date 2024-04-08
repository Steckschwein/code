# Externen Code ausführen
- Serielle Schnittstelle
- 6551 ACIA, später 16550 UART
- Protokoll?
  - erst "sternchen" für jedes Byte
  - bin. Protokoll (anz. Bytes, startadresse, daten)
  - XMODEM


# Massenspeicher
- IDE-Platte? Disketten? SD-Karte!
- SD-Karte, kann SPI, viel GB für wenig €
  - SPI als Peripherie-Bus
    - SD-Karte
    - RTC
    - Tastaturcontroller
- FAT32 Treiber


# Wir wollen was sehen (2014)
- LCD Display
- Videochip TMS9929
  - Problem: Chip gibt YPbPr aus 
    Lösung: Umwandlung per Analogschaltung nach RGB
  - Problem: DRAM interface, nicht stabil auf Steckbrett, ausgelegt auf 4116 DRAMs
    Lösung: SRAM replacement

# Platinen (2015)
- Aufbau auf Platinen statt Steckbrett
  Problem: Steckbrett zunehmend instabil
  Lösung: Aufbau mit Einzelplatinen CPU/RAM, I/O, 
  Problem: Welche EDA-Software?
    - Eagle: bekannt, aber nur 1/2 Europakarte in der freien Version
    - gEDA: etabliert, sehr abgehangen, schnell aufgegeben
    - KiCad: Mega!
  
# Was zum Spielen
- MicroChess (2015)
  - Legendäre Schachsoftware von Peter Jennings
  - Erste "3rd Party Software" auf dem Steckschwein

- Dinosaur endless runner
  Problem: TMS9929 hat keine Scrollregister
  Lösung: um 4px versetztes Tileset um 4px scrolling zu erzeugen

# Schneller, härter, breiter
- Wait state generator
  - CPU und RAM laufen mit 8MHz statt 4MHz
  - Für langsamere Komponenten wird "gebremst"
  
# Multimedia-Upgrade
- VDP V9958 von Yamaha
  - Nachfolger vom Nachfolger des TMS9929
  - Unterstützt 64kx4 DRAMs
  - Direkt RGB Output statt YPbPr
    - Wegfall Diskrete Ausgangsstufe 
    - Sony CXA2075M erzeugt Composite und S-Video  
- Soundchip Yamaha YM3812 (OPL2) 
  - Bekannt von AdLib und frühen Soundblaster-Karten

Emulator
- VCFb 2019, Frage von Michael Steil "Wie könnt ihr ohne Emulator Software entwickeln?"
  - Michael hat uns seinen X16-Emulator "entkernt"
  - Anpassungen:
    - Memory Mapping
    - Einige 65C02-Instruktionen/Adressierungsarten
    - V9958 aus BlueMSX-Emulator
    - OPL2 Emulation 

SBC
- Endlich angekommen - Steckschwein als Einplatinenrechner
  Probleme:
  - QA des Gesamtschaltplans
  - CPLD als neues Thema (Lernkurve)
  Lösung:
  - Mehrere Revisionen
  - VHDL lernen


