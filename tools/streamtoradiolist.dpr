program streamtoradiolist;

{$APPTYPE CONSOLE}

uses
  SysUtils,
  Classes,
  EncryptIt;

var
  Source : TFileStream;
  Target : TStringList;


const
  SECTION = 'S';
  TREE = 'T';
  ITEM = 'i';
  ITEMPLS = 'p';

function ReadString(): string;
var
  len: Word;
  Prefix : Char;
begin
  Source.Read(Prefix, 1);
  Source.Read(len, 2);
  SetLength(Result,len);
  Source.Read(result[1], len);
  result := Decrypt(result, 704);
end;

begin
  Source := TFileStream.Create('radios.dat',fmOpenRead);
  Target := TStringList.Create;

  while Source.Position < Source.Size do
  begin
    Target.Add(ReadString);
  end;  


  Source.Free;
  Target.SaveToFile('radios.txt');
  Target.Free;
end.
