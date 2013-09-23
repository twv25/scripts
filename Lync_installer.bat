If Exist "C:\Program Files\Microsoft Lync\Media\" goto END

If Exist "C:\Program Files (x86)\Microsoft Lync\Media\" goto END

If Exist "C:\Program Files (x86)\" goto X64

"\\pmint\SYSVOL\pmint.pmihq.org\scripts\Lync Installs\32 Bit\LyncSetup.exe" /install /silent

:X64

If NOT EXIST "C:\Program Files (x86)\" goto END

"\\pmint\SYSVOL\pmint.pmihq.org\scripts\Lync Installs\64 Bit\LyncSetup.exe" /install /silent

:END

EXIT