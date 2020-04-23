@echo off
: detect if busybox.exe is in the PATH or not
for %%X in (busybox.exe) do (set FOUND=%%~$PATH:X)
if not defined FOUND (
  echo ERROR: Unable to find busybox.exe in your PATH. 
  echo        This application uses busybox in order to run bash scripts on Windows 
  echo        Please download it and move it into some directory that is in your PATH
  echo        It is found at https://frippery.org/files/busybox/busybox.exe
  goto end
)
: generate the awk script that helps format the .alias file
echo BEGIN {print "#!./busybox bash\n\n# Don't allow any other versions of these commands on the PATH\nexport PATH=""\n\n"} > .alias-format.awk
echo {print "alias " $1 "=\"./busybox " $1 "\""} >> .alias-format.awk
: busybox awk needs unix line termination
busybox dos2unix .alias-format.awk
: generate the .alias file -> major self referencing black magic happens here
busybox | busybox tail -11 | busybox tr ", " "\n" | busybox sed "/^$/d" | busybox sed -e "s/^[ \t]*//" | busybox sort | busybox awk -f .alias-format.awk > .aliases
: get the name of this batch file
:set file-name="%~nx0"
set file-name="%~dpnx0"
: figure out the name of the shell script
set file-name=%file-name:.bat=.sh%
:echo %file-name% 
: use busybox bash to run the shell script with all args
busybox bash %file-name% %*
: clean up the generated files
busybox rm .alias-format.awk .aliases
: end
