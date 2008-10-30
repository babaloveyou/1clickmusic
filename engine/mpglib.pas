unit mpglib;

interface

uses Windows, SysUtils, Classes, uDllfromMem;

function FindFrame(buf: PByte; size: Integer): Integer;

{$MINENUMSIZE 4}

type
  TMp3Handle = packed record
    head, tail: Pointer;
    bsize, framesize, fsizeold: Integer;
    stereo: Integer;
    jsbound: Integer;
    single: Integer;
    lsf: Integer;
    mpeg25: Integer;
    header_change: Integer;
    lay: Integer;
    error_protection: Integer;
    bitrate_index: Integer;
    sampling_frequency: Integer;
    padding: Integer;
    extension: Integer;
    mode: Integer;
    mode_ext: Integer;
    copyright: Integer;
    original: Integer;
    emphasis: Integer;
    dummy: array[1..20000] of Byte;
  end;

  TMp3Result = (MP3_ERROR = -1, MP3_OK = 0, MP3_NEED_MORE = 1);

var
  InitMp3: function(var mp: TMp3Handle): LongBool; cdecl;
  ExitMp3: procedure(var mp: TMp3Handle); cdecl;
  DecodeMp3: function(var mp: TMp3Handle; inmem: PByte; insize: LongInt; outmem: PByte; outsize: LongInt; var done: LongInt): TMp3Result; cdecl;


implementation

uses utils;

function swap(n: LongInt): LongInt; assembler;
asm
  bswap eax
end;

function check(n: LongInt): LongBool;
begin
  n := swap(n);
  Result := False;
  if (n and $FFE00000) <> $FFE00000 then Exit;
  if ((n shr 10) and $3) = $3 then Exit;
  if ((n shr 12) and $F) = $F then Exit;
  if ((n shr 12) and $F) = $0 then Exit;
  // only layer 3, nothing else
  if (4 - (n shr 17) and 3) = 3 then
    Result := True
end;

function FindFrame(buf: PByte; size: Integer): Integer;
begin
  for Result := 0 to size - 5 do
  begin
    if check(PLongInt(buf)^) then
    //OK, it looks like frame we are looking for
      Exit;

    Inc(buf);
  end;

  Result := -1;
end;

{$I mpglib.inc}

var
  mpglibDLL: Pointer;
initialization
  mpglibDLL := memLoadLibrary(@mpglibData);
  DecodeMp3 := memGetProcAddress(mpglibDLL, 'decodeMP3');
  InitMp3 := memGetProcAddress(mpglibDLL, 'InitMP3');
  ExitMp3 := memGetProcAddress(mpglibDLL, 'ExitMP3');

finalization
  memFreeLibrary(mpglibDLL);

{var mpglibDLL: TDLLLoader;
var DLLData: TPointerStream;

initialization
  mpglibDLL := TDLLLoader.Create;
  DLLData := TPointerStream.Create(@mpglibData,mpglibSize);
  mpglibDLL.Load(DLLData);
  DLLData.Free;
  DecodeMp3 := mpglibDll.FindExport('decodeMP3');
  InitMp3 := mpglibDLL.FindExport('InitMP3');
  ExitMp3 := mpglibDLL.FindExport('ExitMP3');

finalization
  mpglibDLL.Free;}
  
end.

