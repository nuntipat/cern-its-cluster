# Must be defined according to each development host!!!
# Defines the location of the EZ-USB SDK
ZTEXPREFIX=/home/wordbox/Documents/CERN/private/ztex-160513/ztex/

ifeq ($(OS),Windows_NT)
	SEPARATOR = ;
	RM = del /Q
else
	SEPARATOR = :
	RM = rm -f
endif

CLASSPATH := .$(SEPARATOR)$(ZTEXPREFIX)/libusbJava$(SEPARATOR)$(ZTEXPREFIX)/java

all: SimpleMIGTest

SimpleMIGTest: SimpleMIGTest.java
	javac -cp $(CLASSPATH) SimpleMIGTest.java

clean:
	$(RM) *.class
