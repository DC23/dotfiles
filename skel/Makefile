# Skeleton Makefile
# OPTFLAGS is used to pass extra flags from the command line
# OPTLIBS passes extra libraries
#
SHELL=/bin/sh

## Compilation flags
# Common C flags
CFLAGS_COMMON= $(OPTFLAGS)

# Release C flags
CFLAGS= $(CFLAGS_COMMON)

# Common C++ flags
CXXFLAGS_COMMON=-Wall -Wextra -Isrc -static $(OPTFLAGS)

# C++ Release flags
CXXFLAGS=-O2 -ipo -xHost -DNDEBUG $(CXXFLAGS_COMMON)

# C & C++ Debug build flags
CFLAGS_DEBUG= $(CFLAGS_COMMON)
CXXFLAGS_DEBUG=-DDEBUG -g -traceback -debug full $(CXXFLAGS_COMMON)

# OpenMP flags. Overridden by the serial target
OMP_FLAGS=-openmp

## Link flags
# LD link flags. Don't put OpenMP link options here, as this allows us to
# override OpenMP flags for serial builds
LDFLAGS=

# Specify libraries here
LIBS= $(OPTLIBS)

## Installation options
#PREFIX?=/usr/local
PREFIX?=`pwd`/bin

## Source code
SOURCES=$(wildcard src/**/*.cpp src/*.cpp)
OBJECTS=$(patsubst %.cpp,%.o,$(SOURCES))

# The final compilation target
TARGET?=build/your_app_here

# The default build: release
all: $(TARGET)

# debug build: override the release options
debug: CXXFLAGS=$(CXXFLAGS_DEBUG)
debug: CFLAGS=$(CFLAGS_DEBUG)
debug: LDFLAGS+=-g
debug: $(TARGET)

# Serial build: change OpenMP to serial
serial: OMP_FLAGS=-openmp-stubs
serial: $(TARGET)

# The primary build, with implicit build rule for generating the object files
$(TARGET): CXXFLAGS+=$(OMP_FLAGS)
$(TARGET): CFLAGS+=$(OMP_FLAGS)
$(TARGET): LDFLAGS+=$(OMP_FLAGS)
$(TARGET): build $(OBJECTS)
	$(CXX) $(LDFLAGS) $(LIBS) -o $@ $(OBJECTS)

# The build target ensures the output build directory is present
build:
	@mkdir -p build

# Clean
clean:
	rm -rf build $(OBJECTS)

# Install
install: all
	install -d $(DESTDIR)/$(PREFIX)/
	install $(TARGET) $(DESTDIR)/$(PREFIX)/
