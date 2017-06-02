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

# define any directories containing header files other than /usr/include
#

INCLUDES = -I /opt/local/include/eigen3/



# define library paths in addition to /usr/lib
LFLAGS = -F ~/Desktop/HCI\ Lab/Myo/sdk -framework myo -rpath ~/Desktop/HCI\ Lab/Myo/sdk 


default: myo

myo: hello-myo.o kalman.o
	 $(CC) $(CFLAGS) $(INCLUDES) -o myo hello-myo.o kalman.o  $(LFLAGS)

hello-myo.o: hello-myo.cpp kalman.h
	$(CC) $(CFLAGS) $(INCLUDES) -c hello-myo.cpp $(LFLAGS)

kalman.o: kalman.cpp kalman.h
	$(CC) $(CFLAGS) $(INCLUDES) -c kalman.cpp 

clean: 
	 $(RM) myo *.o *~
