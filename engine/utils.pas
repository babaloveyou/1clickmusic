unit utils;

interface

uses
  KOL,
  SysUtils,
  Classes,
  Windows;

{$IFDEF DEBUG}
procedure Debug(const s: string); overload;
procedure Debug(const s: string; a: array of const); overload;
{$ENDIF}

function Crypt(const str: string): string;
procedure WriteToFile(const FileName, Text: string);
function MultiPos(const SubStr: array of string; const str: string): LongBool;
procedure RaiseError(const Error: string; const Fatal: LongBool = True);
function PosEx(const SubStr, S: string; Offset: Integer = 1): Integer;

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

const
  KEYCODE = 704; //# encoding password

function Crypt(const str: string): string;
var
  i: Integer;
  key: Byte;
begin
  SetLength(Result, Length(str));
  key := Length(str) mod 10;
  for i := 1 to Length(str) do
  begin
    Result[i] := Char((ord(str[i]) xor ((KEYCODE * i) + key)) mod 256);
  end;
end;

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

procedure RaiseError(const Error: string; const Fatal: LongBool = True);
begin
  MessageBox(0, PChar('ERRO, ' + Error), '1ClickMusic Exception', MB_ICONERROR);
  WriteToFile('ERROR.txt', Error);
  if Fatal then Halt;
end;

// taken from fastcode posex
function PosEx(const SubStr, S: string; Offset: Integer = 1): Integer;
var
  len, lenSub: integer;
  ch: char;
  p, pSub, pStart, pStop: pchar;
label
  Loop0, Loop4,
  TestT, Test0, Test1, Test2, Test3, Test4,
  AfterTestT, AfterTest0,
  Ret, Exit;
begin;
  pSub:=pointer(SubStr);
  p:=pointer(S);

  if (p=nil) or (pSub=nil) or (Offset<1) then begin;
    Result:=0;
    goto Exit;
    end;

  lenSub:=pinteger(pSub-4)^-1;
  len:=pinteger(p-4)^;
  if (len<lenSub+Offset) or (lenSub<0) then begin;
    Result:=0;
    goto Exit;
    end;

  pStop:=p+len;
  p:=p+lenSub;
  pSub:=pSub+lenSub;
  pStart:=p;
  p:=p+Offset+3;

  ch:=pSub[0];
  lenSub:=-lenSub;
  if p<pStop then goto Loop4;
  p:=p-4;
  goto Loop0;

Loop4:
  if ch=p[-4] then goto Test4;
  if ch=p[-3] then goto Test3;
  if ch=p[-2] then goto Test2;
  if ch=p[-1] then goto Test1;
Loop0:
  if ch=p[0] then goto Test0;
AfterTest0:
  if ch=p[1] then goto TestT;
AfterTestT:
  p:=p+6;
  if p<pStop then goto Loop4;
  p:=p-4;
  if p<pStop then goto Loop0;
  Result:=0;
  goto Exit;

Test3: p:=p-2;
Test1: p:=p-2;
TestT: len:=lenSub;
  if lenSub<>0 then repeat;
    if (psub[len]<>p[len+1])
    or (psub[len+1]<>p[len+2]) then goto AfterTestT;
    len:=len+2;
    until len>=0;
  p:=p+2;
  if p<=pStop then goto Ret;
  Result:=0;
  goto Exit;

Test4: p:=p-2;
Test2: p:=p-2;
Test0: len:=lenSub;
  if lenSub<>0 then repeat;
    if (psub[len]<>p[len])
    or (psub[len+1]<>p[len+1]) then goto AfterTest0;
    len:=len+2;
    until len>=0;
  inc(p);
Ret:
  Result:=p-pStart;
Exit:
end;

end.

