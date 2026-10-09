# Variables
TYPST       := typst
FLAGS       := --root ../.. --font-path ../fonts
SOURCE      := decharge.typ
OUTPUT      := decharge.pdf

.PHONY: all compile watch clean

all: compile

compile:
	$(TYPST) compile $(FLAGS) $(SOURCE) $(OUTPUT)

watch:
	$(TYPST) watch $(FLAGS) $(SOURCE) $(OUTPUT)

clean:
	rm -f $(OUTPUT)
