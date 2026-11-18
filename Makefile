# Deedpoll Makefile - Bundles and installs Deedpoll

INSTALL=/usr/local

all: unix windows

unix:
	# Presume Lua is installed and add shebang
	mkdir -p build/unix
	cp deedpoll.lua build/unix/deedpoll
	echo '#!/usr/bin/env lua' | cat - build/unix/deedpoll > temp && mv temp build/unix/deedpoll
	chmod +x build/unix/deedpoll

clean:
	rm -r build test

# Install/Uninstall only for Unix systems
install:
	cp build/unix/deedpoll $(INSTALL)/bin || sudo cp build/unix/deedoll $(INSTALL)/bin

uninstall:
	rm $(INSTALL)/bin/deedpoll || sudo rm $(INSTALL)/bin/deedpoll

suite:
	# Create a test suite of files and directories
	-rm -r test
	mkdir -p "test/dir1/dir space"
	echo "find" > "test/short"
	echo "find1" > "test/test.txt"
	echo "find2" > "test/test two.txt"
	echo "find3" > "test two three (brackets).txt"
	echo "find4" > "test_underscore.txt"
	echo "find5" > "test/újjáválaszthatóságáról"
	echo "find5" > "test/A really Long name with No meaningful Case Pattern.txt"

# TODO: Make a test suite
test: suite
	# cd test && lua ../deedpoll c t
