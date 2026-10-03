GIMP ?= $(shell command -v gimp-console 2>/dev/null || echo gimp)

SRCS := $(wildcard *.xcf)
PNGS := $(SRCS:.xcf=.png)

.PHONY: all clean

all: $(PNGS)

%.png: %.xcf
	@echo "==> Export GIMP: $< -> $@"
	@$(GIMP) -i -b '(let* ((image (car (gimp-file-load RUN-NONINTERACTIVE "$<" "$<"))) (drawable (car (gimp-image-merge-visible-layers image CLIP-TO-IMAGE)))) (gimp-file-save RUN-NONINTERACTIVE image drawable "$@" "$@") (gimp-image-delete image))' -b '(gimp-quit 0)'

clean:
	rm -f $(PNGS)
