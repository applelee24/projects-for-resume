backandforth: backandforth.c functions.o
	gcc -g -Wall -static -m32 -o backandforth backandforth.c functions.o
functions.o: functions.asm
	nasm -g -f elf32 -F dwarf -o functions.o functions.asm
clean:
	rm *.o backandforth
