TARGET=serve

all: clean $(TARGET)

.PHONY: $(TARGET)
$(TARGET):
	cd go && go build -o $(TARGET) .

.PHONY: clean
clean:
	rm -rf go/$(TARGET)
