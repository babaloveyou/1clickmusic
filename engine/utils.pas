unit utils;

interface

uses
  SysUtils,
  Classes,
  Windows;

type
  TPointerStream = class(TCustomMemoryStream)
  public
    constructor Create(data : Pointer; size : Integer);
    function Write(const Buffer; Count: Longint): Longint; override;
  end;

function Crypt(const str: string): string;
procedure writeFile(const FileName, Text: string);
function MultiPos(const SubStr: array of string; const str: string): LongBool;
procedure RaiseError(const Error: string; const Fatal: LongBool = True);

implementation

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

procedure writeFile(const FileName, Text: string);
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
  DateTimeToString(timeprefix, '[dd/mm/yy hh:nn:ss] ', Now);
  Writeln(myfile, timeprefix, Text);
  CloseFile(myfile);
{$I+}
end;

function MultiPos(const SubStr: array of string; const str: string): LongBool;
var
  i: Integer;
begin
  Result := True;
  for i := 0 to High(SubStr) do
    if Pos(SubStr[i], str) > 0 then
      Exit;
  Result := False;
end;

procedure RaiseError(const Error: string; const Fatal: LongBool = True);
begin
  MessageBox(0, PChar('ERRO, ' + Error), '1ClickMusic Exception', MB_ICONERROR);
  writeFile('ERROR.txt', Error);
  if Fatal then Halt;
end;

{ TPointerStream }

constructor TPointerStream.Create(data: Pointer; size: Integer);
begin
  SetPointer(data,size);
end;

function TPointerStream.Write(const Buffer; Count: Integer): Longint;
begin
  Result := 0;
end;

end.

