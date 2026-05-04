all: Schedule

Schedule: src/Main.o src/Utils.o src/Memory_functions.o src/Terminal_functions.o src/Schedule.o
	ld -o Schedule $^ -m elf_i386
	rm -f src/*.o 

src/Main.o: src/Main.s
	as --32 -o $@ $<

src/Utils.o: src/Utils.s
	as --32 -o $@ $<

src/Terminal_functions.o: src/Terminal_functions.s
	as --32 -o $@ $<

src/Memory_functions.o: src/Memory_functions.s
	as --32 -o $@ $<

src/Schedule.o: src/Schedule.s
	as --32 -o $@ $<

clean:
	rm -f src/*.o Schedule