SHELL := /bin/sh

OPENSCAD ?= openscad
SCAD_COMMON_ARGS := --backend=Manifold --enable=textmetrics
HARDWARNINGS := --hardwarnings

DESIGNER := Karim Aziiev
DESIGNER_CONTACT := Karim Aziiev <karim.aziiev@gmail.com>
LICENSE_TERMS := GPL-3.0-or-later
DEFAULT_MATERIAL_TYPE := basematerial
TIRE_MATERIAL_TYPE := TPU 95A HF
DEFAULT_COLOR := \#f9d72c
DEFAULT_DECIMAL_PRECISION := 6

ASSEMBLY_SRC := scad/assembly.scad

EXPORT_DIR := build/export
STL_DIR := $(EXPORT_DIR)/stl
MF3_DIR := $(EXPORT_DIR)/3mf

ASSEMBLY_TARGETS := $(STL_DIR)/assembly.stl $(MF3_DIR)/assembly.3mf

PRINTABLE_SRCS := $(sort $(wildcard scad/printable_parts/*.scad) scad/printable.scad)
PRINTABLE_BASES := $(notdir $(basename $(PRINTABLE_SRCS)))
PRINTABLE_STL := $(addprefix $(STL_DIR)/,$(addsuffix .stl,$(PRINTABLE_BASES)))
PRINTABLE_3MF := $(addprefix $(MF3_DIR)/,$(addsuffix .3mf,$(PRINTABLE_BASES)))

PRINTABLE_PAIRS := $(foreach s,$(PRINTABLE_SRCS),$(notdir $(basename $s))|$s)

3MF_META_ARGS = \
	-O export-3mf/color-mode=model \
	-O export-3mf/color="$(DEFAULT_COLOR)" \
	-O export-3mf/unit=millimeter \
	-O export-3mf/decimal-precision=$(DEFAULT_DECIMAL_PRECISION) \
	-O export-3mf/add-meta-data=true \
	-O export-3mf/meta-data-designer="$(DESIGNER)" \
	-O export-3mf/meta-data-copyright="$(DESIGNER_CONTACT)" \
	-O export-3mf/meta-data-license-terms="$(LICENSE_TERMS)"

.PHONY: all assembly printable tests clean clean-assembly clean-printable clean-tests help

all: tests assembly printable

help:
	@echo "Usage: make <target>"
	@echo "Targets:"
	@echo "  help             Show this help message."
	@echo "  all              Run tests, then build assembly and printable exports."
	@echo "  tests            Run OpenSCAD assertion suites (tolerates empty top-level geometry)."
	@echo "  assembly         Export scad/assembly.scad to $(STL_DIR)/assembly.stl and $(MF3_DIR)/assembly.3mf with hard warnings."
	@echo "  printable        Export scad/printable.scad and scad/printable_parts/*.scad to flattened $(STL_DIR) and $(MF3_DIR)."
	@echo "  clean            Remove build outputs and test temp files."
	@echo "  clean-assembly   Remove build/assembly outputs."
	@echo "  clean-printable  Remove build/printable outputs."
	@echo "  clean-tests      Remove temp OpenSCAD test artifacts under /tmp."

assembly: $(ASSEMBLY_TARGETS)

printable: $(PRINTABLE_STL) $(PRINTABLE_3MF)

tests:
	@status=0; \
	for src in tests/test_*.scad; do \
		name=$$(basename $$src .scad); \
		out=$$(mktemp /tmp/picar-cad-test-$$name-XXXXXX.stl); \
		log=$$(mktemp /tmp/picar-cad-test-log-XXXXXX.txt); \
		echo "Running $$src"; \
		if $(OPENSCAD) $(SCAD_COMMON_ARGS) -o "$$out" "$$src" >"$$log" 2>&1; then rc=0; else rc=$$?; fi; \
		if grep -q "FAIL:" "$$log"; then cat "$$log"; status=1; \
		elif [ $$rc -ne 0 ] && ! grep -q "Current top level object is empty" "$$log"; then \
			cat "$$log"; status=$$rc; \
		else \
			cat "$$log"; \
		fi; \
		rm -f "$$log" "$$out"; \
	done; \
	if [ $$status -ne 0 ]; then exit $$status; fi; \
	echo "Tests finished (artifacts cleaned)."

clean: clean-assembly clean-printable clean-tests

clean-assembly:
	rm -f $(ASSEMBLY_TARGETS)

clean-printable:
	rm -f $(PRINTABLE_STL) $(PRINTABLE_3MF)

clean-tests:
	rm -f /tmp/picar-cad-test-*.stl /tmp/picar-cad-test-log-*.txt

$(STL_DIR)/%.stl: scad/%.scad
	@mkdir -p $(dir $@)
	$(OPENSCAD) $(SCAD_COMMON_ARGS) $(HARDWARNINGS) -o "$@" "$<"

$(MF3_DIR)/%.3mf: scad/%.scad
	@mkdir -p $(dir $@)
	@title=$$(basename "$(@F)" .3mf); \
	description="Assembly export from $< (units: mm)"; \
	material="$(DEFAULT_MATERIAL_TYPE)"; \
	if $(OPENSCAD) $(SCAD_COMMON_ARGS) $(HARDWARNINGS) $(3MF_META_ARGS) \
		-O export-3mf/meta-data-title="$$title" \
		-O export-3mf/meta-data-description="$$description" \
		-O export-3mf/material-type="$$material" \
		-o "$@" "$<"; then :; else exit $$?; fi

define GEN_PRINT_RULES
$(STL_DIR)/$(1).stl: $(2)
	@mkdir -p $$(dir $$@)
	$(OPENSCAD) $(SCAD_COMMON_ARGS) $(HARDWARNINGS) -o "$$@" "$$<"

$(MF3_DIR)/$(1).3mf: $(2)
	@mkdir -p $$(dir $$@)
	@title=$$$$(basename "$$(@F)" .3mf); \
	description="Exported from $$< (units: mm)"; \
	material="$(DEFAULT_MATERIAL_TYPE)"; \
	case "$$title" in \
		tire*|*tire*) \
			material="$(TIRE_MATERIAL_TYPE)"; \
			description="Recommended material: $(TIRE_MATERIAL_TYPE). Exported from $$< (units: mm)";; \
	esac; \
	if $(OPENSCAD) $(SCAD_COMMON_ARGS) $(HARDWARNINGS) $(3MF_META_ARGS) \
		-O export-3mf/meta-data-title="$$title" \
		-O export-3mf/meta-data-description="$$description" \
		-O export-3mf/material-type="$$material" \
		-o "$$@" "$$<"; then :; \
	elif [ "$$material" != "$(DEFAULT_MATERIAL_TYPE)" ]; then \
		echo "openscad rejected material type '$$material' for $$@, falling back to $(DEFAULT_MATERIAL_TYPE)" >&2; \
		$(OPENSCAD) $(SCAD_COMMON_ARGS) $(HARDWARNINGS) $(3MF_META_ARGS) \
			-O export-3mf/meta-data-title="$$title" \
			-O export-3mf/meta-data-description="$$description" \
			-O export-3mf/material-type="$(DEFAULT_MATERIAL_TYPE)" \
			-o "$$@" "$$<"; \
	else \
		exit $$?; \
	fi
endef

$(foreach pair,$(PRINTABLE_PAIRS),$(eval $(call GEN_PRINT_RULES,$(word 1,$(subst |, ,$(pair))),$(word 2,$(subst |, ,$(pair))))))
