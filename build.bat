ca65 main.s -I include --bin-include-dir assets -o main.o
ld65 main.o -o calculator.nes -C config.cfg