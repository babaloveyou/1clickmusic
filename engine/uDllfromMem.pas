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
unit uDllfromMem;

interface

{$DEBUGINFO OFF}
{$WARNINGS OFF}
{$HINTS OFF}

uses
  Windows;

type
  PImageBaseRelocation = ^TImageBaseRelocation;
  _IMAGE_BASE_RELOCATION = packed record
    VirtualAddress: DWORD;
    SizeOfBlock: DWORD;
  end;
{$EXTERNALSYM _IMAGE_BASE_RELOCATION}
  TImageBaseRelocation = _IMAGE_BASE_RELOCATION;
  IMAGE_BASE_RELOCATION = _IMAGE_BASE_RELOCATION;
{$EXTERNALSYM IMAGE_BASE_RELOCATION}

type
  PImageImportDescriptor = ^TImageImportDescriptor;
  TImageImportDescriptor = packed record
    OriginalFirstThunk: dword;
    TimeDateStamp: dword;
    ForwarderChain: dword;
    Name: dword;
    FirstThunk: dword;
  end;

type
  PImageImportByName = ^TImageImportByName;
  TImageImportByName = packed record
    Hint: WORD;
    Name: array[0..255] of Char;
  end;

type
  PImageThunkData = ^TImageThunkData;
  TImageThunkData = packed record
    case integer of
      0: (ForwarderString: PBYTE);
      1: (FunctionPtr: PDWORD);
      2: (Ordinal: DWORD);
      3: (AddressOfData: PImageImportByName);
  end;

type
  TDllEntryProc = function(hinstdll: THandle; fdwReason: DWORD; lpReserved: Pointer): BOOL; stdcall;

function memLoadLibrary(FileBase: Pointer): Pointer;
function memGetProcAddress(Physbase: Pointer; NameOfFunction: string): Pointer;
function memFreeLibrary(physbase: Pointer): Boolean;

const
  IMAGE_REL_BASED_HIGHLOW = 3;
  IMAGE_ORDINAL_FLAG32 = DWORD($80000000);

implementation

function GetSectionProtection(ImageScn: cardinal): cardinal;
begin
  Result := 0;
  if (ImageScn and IMAGE_SCN_MEM_NOT_CACHED) <> 0 then
  begin
    Result := Result or PAGE_NOCACHE;
  end;
  if (ImageScn and IMAGE_SCN_MEM_EXECUTE) <> 0 then
  begin
    if (ImageScn and IMAGE_SCN_MEM_READ) <> 0 then
    begin
      if (ImageScn and IMAGE_SCN_MEM_WRITE) <> 0 then
      begin
        Result := Result or PAGE_EXECUTE_READWRITE
      end
      else
      begin
        Result := Result or PAGE_EXECUTE_READ
      end;
    end
    else if (ImageScn and IMAGE_SCN_MEM_WRITE) <> 0 then
    begin
      Result := Result or PAGE_EXECUTE_WRITECOPY
    end
    else
    begin
      Result := Result or PAGE_EXECUTE
    end;
  end
  else if (ImageScn and IMAGE_SCN_MEM_READ) <> 0 then
  begin
    if (ImageScn and IMAGE_SCN_MEM_WRITE) <> 0 then
    begin
      Result := Result or PAGE_READWRITE
    end
    else
    begin
      Result := Result or PAGE_READONLY
    end
  end
  else if (ImageScn and IMAGE_SCN_MEM_WRITE) <> 0 then
  begin
    Result := Result or PAGE_WRITECOPY
  end
  else
  begin
    Result := Result or PAGE_NOACCESS;
  end;
end;

function memLoadLibrary(FileBase: Pointer): Pointer;
var
  pfilentheader: PImageNtHeaders;
  pfiledosheader: PImageDosHeader;
  pphysntheader: PImageNtHeaders;
  pphysdosheader: PImageDosHeader;
  physbase: Pointer;
  pphyssectionheader: PImageSectionHeader;
  i: Integer;
  importsDir: PImageDataDirectory;
  importsBase: Pointer;
  importDesc: PImageImportDescriptor;
  importThunk: PImageThunkData;
  dll_handle: Cardinal;
  importbyname: pimageimportbyname;
  relocbase: Pointer;
  relocdata: PIMAGeBaseRElocation;
  relocitem: PWORD;
  reloccount: Integer;
  dllproc: TDLLEntryProc;
begin
  try
    pfiledosheader := filebase;

    pfilentheader := Pointer(Cardinal(filebase) + pfiledosheader^._lfanew);

    //////////////////////
    ///////////allozieren/
    {physbase := VirtualAlloc(Pointer(pfilentheader^.OptionalHeader.ImageBase), pfilentheader^.OptionalHeader.SizeOfImage, MEM_RESERVE, PAGE_READWRITE);
    if physbase = nil then begin
      physbase := VirtualAlloc(nil, pfilentheader^.OptionalHeader.SizeOfImage, MEM_RESERVE or MEM_COMMIT, PAGE_READWRITE);
    end;}

    // above code does not work, this work
    physbase := VirtualAlloc(Pointer(pfilentheader^.OptionalHeader.ImageBase), pfilentheader^.OptionalHeader.SizeOfImage, MEM_RESERVE or MEM_COMMIT, PAGE_READWRITE);

    ///////////////////////////
    ///////////header kopieren/
    Move(filebase^, physbase^, pfilentheader^.OptionalHeader.SizeOfHeaders);

    //header im memory finden & anpassen
    pphysdosheader := physbase;
    pphysntheader := Pointer(Cardinal(physbase) + pphysdosheader^._lfanew);
    pphysntheader^.OptionalHeader.ImageBase := Cardinal(physbase);


    ///////////////////////////////
    /////////////sections kopieren/
    pphyssectionheader := Pointer(Cardinal(pphysntheader) + SizeOf(TIMAGENTHEADERS));
    for i := 0 to (pphysntheader^.FileHeader.NumberOfSections - 1) do
    begin
      if (pphyssectionheader^.SizeOfRawData = 0) then
      //keine raw data
        FillChar(Pointer(Cardinal(physbase) + pphyssectionheader^.VirtualAddress)^, pphyssectionheader^.Misc.VirtualSize, 0)
      else
      //raw data vorhanden
        Move(Pointer(Cardinal(filebase) + pphyssectionheader^.PointerToRawData)^, Pointer(Cardinal(physbase) + pphyssectionheader^.VirtualAddress)^, pphyssectionheader^.SizeOfRawData);
      pphyssectionheader^.Misc.PhysicalAddress := Cardinal(physbase) + pphyssectionheader^.VirtualAddress;


      Inc(pphyssectionheader);
      //next one please
      // same as above
      //pphyssectionheader := Pointer(Cardinal(pphyssectionheader) + SizeOf(TIMAGESECTIONHEADER));
    end;


  //////////////////////
  /////////////imports/
    importsBase := Pointer(Cardinal(physbase) + pphysntheader^.OptionalHeader.DataDirectory[IMAGE_DIRECTORY_ENTRY_IMPORT].VirtualAddress);
    importDesc := importsBase;
    while (importDesc.Name) <> 0 do
    begin
      dll_handle := LoadLibrary(pchar(Cardinal(physbase) + importdesc.Name));
      importDesc.ForwarderChain := dll_handle;
      importThunk := Pointer(Cardinal(physbase) + importDesc.FirstThunk);
      while (importThunk.Ordinal <> 0) do
      begin
        importbyname := Pointer(Cardinal(physbase) + importThunk.Ordinal);
        //Später noch überprüfen ob OriginalFirstThunk = 0
        if (importThunk.Ordinal and IMAGE_ORDINAL_FLAG32) <> 0 then
        //ordinal
          importThunk.FunctionPtr := GetProcaddress(dll_handle, pchar(importThunk.Ordinal and $FFFF))
        else //normal
          importThunk.FunctionPtr := GetProcAddress(dll_handle, importByname.name);

        Inc(importThunk);
        // same as above
        //next one, please
        //importThunk := Pointer(Cardinal(importThunk) + SizeOf(TIMAGETHUNKDATA));
      end;

      Inc(importDesc);
    //next one, please
    // same as above
    //importDesc := Pointer(Cardinal(importDesc) + sizeOf(TIMAGEIMPORTDESCRIPTOR));
    end;


    /////////////////////
    /////////////relocs/
    relocbase := Pointer(Cardinal(physbase) + pphysntheader.OptionalHeader.DataDirectory[IMAGE_DIRECTORY_ENTRY_BASERELOC].VirtualAddress);
    relocData := relocbase;
    while (Cardinal(relocdata) - Cardinal(relocbase)) < pphysntheader.OptionalHeader.DataDirectory[IMAGE_DIRECTORY_ENTRY_BASERELOC].Size do
    begin
      reloccount := ((relocdata.SizeOfBlock - 8) div 2);
      relocitem := Pointer(Cardinal(relocdata) + 8);
      for i := 0 to (reloccount - 1) do begin
        if (relocitem^ shr 12) = IMAGE_REL_BASED_HIGHLOW then begin
          Inc(PDWord(Cardinal(physbase) + relocdata.VirtualAddress + (relocitem^ and $FFF))^, (Cardinal(physbase) - pfilentheader.OptionalHeader.ImageBase));
        end;
        Inc(relocitem);
      //relocitem := Pointer(Cardinal(relocitem) + SizeOf(WORD));
      end;


      Inc(PByte(relocdata), relocdata.SizeOfBlock);
    // same as above
    //next one please
    //relocdata := Pointer(Cardinal(relocdata) + relocdata.SizeOfBlock);
    end;


    /////////////////////////////////
    ////////Section protection & so/
    pphyssectionheader := Pointer(Cardinal(pphysntheader) + SizeOf(TIMAGENTHEADERS));
    for i := 0 to (pphysntheader^.FileHeader.NumberOfSections - 1) do
    begin
      VirtualProtect(Pointer(Cardinal(physbase) + pphyssectionheader^.VirtualAddress), pphyssectionheader^.Misc.VirtualSize, GetSectionProtection(pphyssectionheader.Characteristics), nil);
      Inc(pphyssectionheader);
      //pphyssectionheader := Pointer(Cardinal(pphyssectionheader) + SizeOf(TIMAGESECTIONHEADER));
    end;


    ////////////////////////////////
    ////////////////Dll entry proc/
    dllproc := Pointer(Cardinal(physbase) + pphysntheader.OptionalHeader.AddressOfEntryPoint);
    dllproc(cardinal(physbase), DLL_PROCESS_ATTACH, nil);

    Result := physbase;
  except
    Result := nil;
  end;
end;

function memGetProcAddress(Physbase: Pointer; NameOfFunction: string): Pointer;
var
  pdosheader: PImageDosHeader;
  pntheader: PImageNtHeaders;
  pexportdir: PImageExportDirectory;
  i: Integer;
  pexportname: PDWORD;
  //pexportordinal: PWORD;
  pexportFunction: PDWORD;
begin
  Result := nil;
  pdosheader := physbase;
  pntheader := Pointer(Cardinal(physbase) + pdosheader._lfanew);
  pexportdir := Pointer(Cardinal(physbase) + pntheader.OptionalHeader.DataDirectory[IMAGE_DIRECTORY_ENTRY_EXPORT].VirtualAddress);
  if pexportdir.NumberOfFunctions or pexportdir.NumberOfNames = 0 then exit;
  pexportName := Pointer(Cardinal(physbase) + Cardinal(pexportDir.AddressOfNames));
    //pexportordinal := Pointer(Cardinal(physbase) + Cardinal(pexportDir.AddressOfNameOrdinals));
  pexportFunction := Pointer(Cardinal(physbase) + Cardinal(pexportDir.AddressOfFunctions));

  for i := 0 to (pexportdir.NumberOfNames - 1) do
  begin
    if string(PChar(Pointer(Cardinal(physbase) + pexportName^))) = NameOfFunction then
    begin
      Result := Pointer(Cardinal(physbase) + pexportFunction^);
      Break;
    end;

      //next one, please
    Inc(pexportFunction);
    Inc(pexportName);
      //Inc(pexportOrdinal);
  end;
end;

function memFreeLibrary(physbase: Pointer): Boolean;
var
  dllproc: TDllEntryProc;
begin
  try
    Result := True;
    // ugly code to avoid needing the globalvariable
    dllproc := TDllEntryProc(Cardinal(physbase) + PImageNtHeaders(Cardinal(physbase) + PImageDosHeader(physbase)^._lfanew)^.OptionalHeader.AddressOfEntryPoint);
    dllproc(Cardinal(physbase), DLL_PROCESS_DETACH, nil);
    VirtualFree(physbase, 0, MEM_RELEASE);
  except
    Result := False;
  end;
end;

end.

