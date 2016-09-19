@Echo off 
SETLOCAL
SET ZTEXPREFIX=C:\Users\Nuntipat\Documents\CERN\private\ztex-160513\ztex
SET CLASSPATH=.;%ZTEXPREFIX%/libusbJava;%ZTEXPREFIX%/java
java -cp %CLASSPATH% TestDDR3
