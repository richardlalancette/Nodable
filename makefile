CXX = g++
CXXFLAGS+= -DDEBUG #uncomment if you want to display all debug messages
CXXFLAGS+= `sdl2-config --cflags` -lGL -ldl -I libs/imgui -I libs/imgui/examples/libs/gl3w `sdl2-config --libs` -std=c++11
LDFLAGS=
EXECUTABLE=nodable.bin

TARGET :=linux64

BINDIR :=bin/$(TARGET)
SRCDIR :=sources
OBJDIR :=build/$(TARGET)

SOURCES := $(wildcard $(SRCDIR)/*.cpp)
OBJECTS := $(patsubst $(SRCDIR)/%.cpp, $(OBJDIR)/%.o, $(SOURCES))
OBJECTS += libs/imgui/examples/sdl_opengl3_example/imgui_impl_sdl_gl3.o
OBJECTS += libs/imgui/examples/libs/gl3w/GL/gl3w.o
OBJECTS += $(patsubst %.cpp, %.o, $(wildcard ./libs/imgui/*.cpp))
DEPENDENCIES := $(patsubst $(SRCDIR)/%.cpp, $(OBJDIR)/%.d, $(SOURCES))

all: makeFolders dependencies $(EXECUTABLE)

include $(wildcard $(OBJDIR)/*.d)

$(EXECUTABLE): $(OBJECTS)
	$(CXX)  $(OBJECTS) -o $(BINDIR)/$(EXECUTABLE) $(CXXFLAGS)


./libs/imgui/%.o: ./libs/imgui/%.cpp

libs/imgui/examples/sdl_opengl3_example/imgui_impl_sdl_gl3.o : libs/imgui/examples/sdl_opengl3_example/imgui_impl_sdl_gl3.cpp
	$(CXX) -c $(CXXFLAGS) $< -o $@

libs/imgui/examples/libs/gl3w/GL/gl3w.o: libs/imgui/examples/libs/gl3w/GL/gl3w.c
	$(CXX) -c $(CXXFLAGS) $< -o $@

$(OBJDIR)/%.o: $(SRCDIR)/%.cpp $(OBJDIR)/%.d
	$(CXX) -c $(CXXFLAGS) $< -o $@

# This target creates a makefile per *.cpp (with all dependencies automatically generated by the compiler with -MM flag)
$(OBJDIR)/%.d : $(SRCDIR)/%.cpp
	@set -e; rm -f $@; \
	$(CXX) -MM $(CXXFLAGS) $< > $@.$$$$; \
	sed 's,\($*\)\.o[ :]*,$(OBJDIR)/\1.o $@ : ,g' < $@.$$$$ > $@; \
	rm -f $@.$$$$

# A target to run the program
.PHONY: run
run: all
	$(EXECUTABLE)

.PHONY: dependencies
dependencies: $(DEPENDENCIES)

.PHONY: makeFolders
makeFolders:
	mkdir -p $(OBJDIR)
	mkdir -p $(BINDIR)

.PHONY: clean
clean:
	rm -rf $(OBJECTS) $(DEPENDENCIES)

.PHONY: mrproper
mrproper: clean
	rm -rf $(EXEC)

