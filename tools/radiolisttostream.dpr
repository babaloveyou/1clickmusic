program radiolisttostream;

{$APPTYPE CONSOLE}

uses
  SysUtils,
  Classes,
  EncryptIt;

var
  Source: TStringList;
  Target: TFileStream;
  i: Integer;


const
  SECTION = 'S';
  TREE = 'T';
  ITEM = 'i';
  ITEMPLS = 'p';


function Pos(const str: string): Boolean;
begin
  result := System.Pos(str, Source[i]) > 0;
end;

procedure WriteString(str: string; const Prefix: Char);
var
  len: Word;
begin
  if (str = '') then Exit;
  Writeln(prefix,#9,str);
  str := Encrypt(str, 704);
  len := Length(str);
  Target.Write(Prefix, 1);
  Target.Write(len, 2);
  Target.Write(str[1], len);
end;

function ClearStr(const str: string): string;
begin
  if Pos('''') then
    Result := AnsiDequotedStr(Trim(str), '''')
  else
    Result := '';
end;


begin
  Target := TFileStream.Create('radios.dat', fmCreate);
  Writeln('opening file');
  Source := TStringList.Create;
  Source.LoadFromFile('radios.pas');
  i := 0;
  while i < Source.Count do
  begin
    if Pos('genrelist') and Pos('of string') then
    begin
      Inc(i);
      repeat
        WriteString(
          ClearStr(Source[i]),
          SECTION);
        Inc(i);
      until Pos(';');
    end;

    if Pos('chn') and Pos('of string') then //#NAMES
    begin
      Inc(i);
      repeat
        WriteString(
          ClearStr(Source[i]),
          ITEM);
        Inc(i);
      until Pos(';');
    end;

    if Pos('pls') and Pos('of string') then //#PLS
    begin
      Inc(i);
      repeat
        WriteString(
          ClearStr(Source[i]),
          ITEMPLS);
        Inc(i);
      until Pos(';');
    end;
    Inc(i);
  end;


  Target.Free;
  Source.Free;
  Readln;

end.

