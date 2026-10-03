GIMP ?= $(shell command -v gimp-console 2>/dev/null || echo gimp)

SRCS := $(wildcard *.xcf)
PNGS := $(SRCS:.xcf=.png)

PDFS_A4 := $(SRCS:.xcf=_a4.pdf)
PDFS_A3 := $(SRCS:.xcf=_a3.pdf)

.PHONY: all clean

all: $(PNGS) $(PDFS_A4) $(PDFS_A3)

%.png: %.xcf
	@echo "==> Export GIMP: $< -> $@"
	@$(GIMP) -i -b '(let* ((image (car (gimp-file-load RUN-NONINTERACTIVE "$<" "$<"))) (drawable (car (gimp-image-merge-visible-layers image CLIP-TO-IMAGE)))) (gimp-file-save RUN-NONINTERACTIVE image drawable "$@" "$@") (gimp-image-delete image))' -b '(gimp-quit 0)'

%_a4.pdf: %.png
	@echo "==> Export PDF A4: $< -> $@"
	@img2pdf $< --pagesize A4 --auto-orient -o $@

%_a3.pdf: %.png
	@echo "==> Export PDF A3: $< -> $@"
	@img2pdf $< --pagesize A3 --auto-orient -o $@

clean:
	rm -f $(PNGS) $(PDFS_A4) $(PDFS_A3)
