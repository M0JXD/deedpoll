# Deedpoll Makefile - Bundles and installs Deedpoll

INSTALL=/usr/local

all: unix windows

unix:
	# Presume Lua is installed and add shebang
	mkdir -p build/unix
	cp deedpoll.lua build/unix/deedpoll
	echo '#!/usr/bin/env lua' | cat - build/unix/deedpoll > temp && mv temp build/unix/deedpoll
	chmod +x build/unix/deedpoll

windows:
	# Create a bundle for Windows with batch starter
	mkdir -p build/windows
	# Fetch Lua executable
	# Create Batch Launcher/Installer

clean:
	rm -r build

# Install/Uninstall only for Unix systems
install:
	cp build/unix/deedpoll $(INSTALL)/bin || sudo cp build/unix/deedoll $(INSTALL)/bin

uninstall:
	rm $(INSTALL)/bin/deedpoll || sudo rm $(INSTALL)/bin/deedpoll

# TODO: Make a test suite
test:
