If Exist "C:\Program Files\Microsoft Lync\Media\" goto END

If Exist "C:\Program Files (x86)\Microsoft Lync\Media\" goto END

If Exist "C:\Program Files (x86)\" goto X64

"FILE" /install /silent

:X64

If NOT EXIST "C:\Program Files (x86)\" goto END

"FILE" /install /silent

:END

EXIT