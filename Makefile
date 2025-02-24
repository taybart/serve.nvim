TARGET=serve

all: clean $(TARGET)

.PHONY: $(TARGET)
$(TARGET):
	cd $(TARGET) && go build -o $(TARGET) .

.PHONY: clean
clean:
	rm -rf $(TARGET)/$(TARGET)
