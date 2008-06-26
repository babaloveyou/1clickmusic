unit utils;

interface

uses
  sysutils,
  Windows;

{$IFDEF LOG}
procedure Log(const Text: string);
{$ENDIF}

function Crypt(const str: string): string;
procedure writeFile(const FileName, Text: string);
function MultiPos(const SubStr: array of string; const str: string): Boolean;
procedure RaiseError(const Error: string; const Fatal: Boolean = True);

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

function MultiPos(const SubStr: array of string; const str: string): Boolean;
var
  i: Integer;
begin
  Result := True;
  for i := 0 to High(SubStr) do
    if Pos(SubStr[i], str) > 0 then
      Exit;
  Result := False;
end;

procedure RaiseError(const Error: string; const Fatal: Boolean = True);
begin
  MessageBox(0, PChar(Error), '1ClickMusic Exception', MB_ICONERROR);
  writeFile('ERROR.txt', Error);
  if Fatal then Halt;
end;

end.

