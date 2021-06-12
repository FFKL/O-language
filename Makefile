PROG_COMPILER = compiler/OCompiler
PROG_VM = vm/O
PROG_ASM = asm/OAsm

SRC = src
BUILD = build
DIST = dist

.PHONY: compiler vm asm clean ensure_dirs

all: compiler vm asm

compiler: ensure_dirs
	fpc -FE"$(DIST)" -FU"$(BUILD)" -Fu"$(SRC)/*" -O2 $(SRC)/$(PROG_COMPILER).pas

vm: ensure_dirs
	fpc -FE"$(DIST)" -FU"$(BUILD)" -Fu"$(SRC)/*" -O2 $(SRC)/$(PROG_VM).pas

asm: ensure_dirs
	fpc -FE"$(DIST)" -FU"$(BUILD)" -Fu"$(SRC)/*" -O2 $(SRC)/$(PROG_ASM).pas

ensure_dirs:
	mkdir -p $(BUILD)
	mkdir -p $(DIST)

clean:
	rm -fr $(DIST)
	rm -fr $(BUILD)
