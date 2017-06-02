#
# 'make depend' uses makedepend to automatically generate dependencies 
#               (dependencies are added to end of Makefile)
# 'make'        build executable file 'mycc'
# 'make clean'  removes all .o and executable files
#

# define the C++ compiler to use
CC = g++

# compiler flags:
#  -g    adds debugging information to the executable file
#  -Wall turns on most, but not all, compiler warnings
CFLAGS  = -g -Wall

# define library paths in addition to /usr/lib
LFLAGS = -F ~/Desktop/HCI\ Lab/Myo/sdk -framework myo -rpath ~/Desktop/HCI\ Lab/Myo/sdk 

all: hello-myo.cpp 
	 $(CC) $(CFLAGS)  -o hello-myo hello-myo.cpp  $(LFLAGS)
 
clean: 
	 $(RM) hello-myo *.o *~