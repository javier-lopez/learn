powercfg /setacvalueindex scheme_current sub_buttons lidaction 1
powercfg /setdcvalueindex scheme_current sub_buttons lidaction 1

::Re-activate current scheme to make settings take effect immediately
powercfg /setactive scheme_current

@echo off
echo "Done!, back to default, now computer will suspend when the lid is closed"
