unit utils;

interface

uses
  sysutils,
  Windows;

procedure writeFile(const FileName, Text: string);
function MultiPos(const SubStr: array of string; const str: string): Boolean;
procedure RaiseError(const Error: string; const Fatal: Boolean = True);
{$IFDEF _LOG_}
procedure Log();
{$ENDIF}
implementation

procedure writeFile(const FileName, Text: string);
var
  myfile: TextFile;
  timeprefix: string;
begin
  AssignFile(myfile, FileName);
  if FileExists(FileName) then
    Append(myfile)
  else
    Rewrite(myfile);
  DateTimeToString(timeprefix, '[dd/mm/yy hh:nn:ss] ', Now);
  Writeln(myfile, timeprefix, Text);
  CloseFile(myfile);
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
  MessageBox(0, '1ClickMusic Exception', PChar(Error), MB_ICONERROR);
  writeFile('ERROR.txt', Error);
  if Fatal then Halt;
end;

{$IFDEF _LOG_}
var
  step: Cardinal = 0;

procedure Log();
begin
  writeFile('LOG.txt', IntToStr(step));
  Inc(step);
end;

initialization
  writeFile('LOG.txt','SESSION STARTING');
{$ENDIF}

end.

