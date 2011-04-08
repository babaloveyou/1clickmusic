{
[===========================================]
[?]uDllFromMem - Loading a DLL from Memory[?]
[v]              Version 1.0              [v]
[c]          Hamtaro aka CorVu5           [c]
[@]     hamtaro.6x.to OR corvu5.6x.to     [@]
[================Description================]
[With this Code, you can load a DLL in your ]
[application directly from Memory, the file ]
[doesnt have to be present on your Harddrive]
[===================Note====================]
[   This example doesnt work with Bound     ]
[       Import Tables at this time          ]
[==================thx to===================]
[              CDW, Cryptocrack             ]
[           & Joachim Bauch for his         ]
[      GetSectionProtection function        ]
[===========================================]
[  there must be 50 ways to learn to hover  ]
[===========================================]

MODIFIED BY ARTHURPRS for 1clickmusic
- fixed some bugs
- human readable code
- remove garbage
- added some compiler directives
}
unit uDllfromMemEx;

interface

{$DEBUGINFO OFF}
{$WARNINGS OFF}
{$HINTS OFF}

uses
  Windows, SysUtils, Classes, KOL, main;

function memLoadLibrary(FileBase: Pointer; Size: Integer): Pointer;
function memGetProcAddress(Physbase: Pointer; const NameOfFunction: string): Pointer;
procedure memFreeLibrary(physbase: Pointer);

implementation

function memLoadLibrary(FileBase: Pointer; Size: Integer): Pointer;
var
  fdllpath: string;
  fdll: PStream;
begin
  fdllpath := GetTempDir() + UInt2Str(Cardinal(FileBase)) + UInt2Str(APPVERSION) + '.dll';
  if FileSize(fdllpath) <> Size then
  begin
    fdll := NewWriteFileStream(fdllpath);
    fdll.Write(FileBase^, Size);
    fdll.Free;
  end;
  Result := Pointer(LoadLibrary(PChar(fdllpath)));
end;

function memGetProcAddress(Physbase: Pointer; const NameOfFunction: string): Pointer;
begin
  Result := GetProcAddress(Cardinal(Physbase), PChar(NameOfFunction));
end;

procedure memFreeLibrary(physbase: Pointer);
begin
  FreeLibrary(Cardinal(physbase));
end;

end.

