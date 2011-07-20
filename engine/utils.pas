unit utils;

interface

uses
  KOL,
  SysUtils,
  synautil,
  Classes,
  Windows;

{$IFDEF DEBUG}
procedure Debug(const s: string); overload;
procedure Debug(const s: string; a: array of const); overload;
{$ENDIF}

function strstr(const str1, str2: PChar): PChar; cdecl; varargs; external 'msvcrt.dll';
function sscanf(const s, format: PChar): Integer; cdecl; varargs; external 'msvcrt.dll';
procedure WriteToFile(const FileName, Text: string);
function MultiPos(const SubStr: array of string; const str: string): LongBool;
procedure RaiseError(const Error: string; const Fatal: LongBool = True);
function PosEx(const SubStr, S: string; Offset: Integer = 1): Integer;
procedure SplitValue(const data : string; var field, value: string);

{function ExtractResource(const res : string): string;}

implementation

{$IFDEF DEBUG}
var
  ok: LongBool = False;
  f: TextFile;

procedure Debug(const s: string);
begin
  if not ok then
  begin
    ok := True;
    AssignFile(f, 'log.txt');
    Rewrite(f);
  end;
  Writeln(f, DateTimeToStr(Now) + ': ' + s);
  Flush(f);
end;

procedure Debug(const s: string; a: array of const);
begin
  if not ok then
  begin
    ok := True;
    AssignFile(f, 'f.txt');
    Reset(f);
  end;
  Writeln(f,Format(s, a));
  Flush(f);
end;
{$ENDIF}

{function ExtractResource(const res : string): string;
var
  temppath : array[0..MAX_PATH] of Char;
  reshandle, outfile : THandle;
  resdata : Pointer;
  written : Cardinal;
begin
  GetTempPath(MAX_PATH, temppath);
  reshandle := FindResource(0, PChar(res), RT_RCDATA);
  Result := temppath + res + '.dll';
  outfile := CreateFile(PChar(Result), GENERIC_WRITE, 0, nil, CREATE_ALWAYS, FILE_ATTRIBUTE_NORMAL, 0);
  resdata := LockResource(LoadResource(0, reshandle));
  WriteFile(outfile, resdata^, SizeOfResource(0, reshandle), written, nil);
  CloseHandle(outfile);
end;}

procedure WriteToFile(const FileName, Text: string);
var
  myfile: TextFile;
  timeprefix: string;
begin
{$I-}
  AssignFile(myfile, FileName);
  if FileExists(FileName) then
    Append(myfile)
  else
    Rewrite(myfile);
  DateTimeToString(timeprefix, '[ddddd tt] ', Now);
  Writeln(myfile, timeprefix, Text);
  CloseFile(myfile);
{$I+}
end;

function MultiPos(const SubStr: array of string; const str: string): LongBool;
var
  i: Integer;
begin
  Result := True;
  for i := 0 to Length(SubStr) - 1 do
    if Pos(SubStr[i], str) <> 0 then
      Exit;
  Result := False;
end;

procedure SplitValue(const data : string; var field, value: string);
var
  p: Integer;
begin
  p := Pos(':', data);
  if p > 0 then
  begin
    field := LowerCase(Copy(data, 1, p - 1));
    value := Trim(Copy(data, p + 1, MaxInt));
  end;
end;

procedure RaiseError(const Error: string; const Fatal: LongBool = True);
begin
  MessageBox(0, PChar('ERRO, ' + Error), '1ClickMusic Exception', MB_ICONERROR);
  WriteToFile('ERROR.txt', Error);
  if Fatal then Halt;
end;

// taken from fastcode posex
function PosEx(const SubStr, S: string; Offset: Integer = 1): Integer;
begin
  Result := PosFrom(SubStr, S, Offset);
end;

end.

