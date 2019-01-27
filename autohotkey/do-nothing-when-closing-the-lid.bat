powercfg /setacvalueindex scheme_current sub_buttons lidaction 0
powercfg /setdcvalueindex scheme_current sub_buttons lidaction 0

::Re-activate current scheme to make settings take effect immediately
powercfg /setactive scheme_current

@echo off
echo "Done!, now computer will do nothing when the lid is closed"
