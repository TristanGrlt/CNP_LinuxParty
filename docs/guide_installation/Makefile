# Variables
TYPST       := typst
FLAGS       := --root ../.. --font-path ../fonts
SOURCE      := guide_installation.typ
OUTPUT      := guide_installation.pdf

.PHONY: all compile watch clean

all: compile

compile:
	$(TYPST) compile $(FLAGS) $(SOURCE) $(OUTPUT)

watch:
	$(TYPST) watch $(FLAGS) $(SOURCE) $(OUTPUT)

clean:
	rm -f $(OUTPUT)
