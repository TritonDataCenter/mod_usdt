BUILD=build
PROVIDER=http

$(BUILD)/$(PROVIDER)_provider.h: src/$(PROVIDER)_provider.d | $(BUILD)
	dtrace -xnolibs -h -o $@ -s $<

$(BUILD):
	mkdir -p $(BUILD)
