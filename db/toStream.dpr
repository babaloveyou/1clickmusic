program toStream;

{$APPTYPE CONSOLE}

uses
  SysUtils, Classes, Radios, utils;

var
  Dest: TMemoryStream;

procedure WriteString(const text: string);
var
  l: Byte;
begin
  l := Length(text);
  Dest.Write(l, 1);
  Dest.Write(PChar(text)^, l);
end;

procedure WriteInt8(const num : Byte);
begin
  Dest.Write(num,1);
end;  

procedure doIt;
var
  i: Integer;
begin
  Dest := TMemoryStream.Create;

  WriteInt8(High(genrelist) + 1);

  
  
  WriteString(genrelist[0]);
  WriteInt8(High(chn_eletronic) + 1);
  for i := 0 to High(chn_eletronic) do
  begin
    WriteString(chn_eletronic[i]);
    WriteString(Crypt(pls_eletronic[i]));
  end;

  WriteString(genrelist[1]);
  WriteInt8(High(chn_downtempo) + 1);
  for i := 0 to High(chn_downtempo) do
  begin
    WriteString(chn_downtempo[i]);
    WriteString(Crypt(pls_downtempo[i]));
  end;

  WriteString(genrelist[2]);
  WriteInt8(High(chn_rockmetal) + 1);
  for i := 0 to High(chn_rockmetal) do
  begin
    WriteString(chn_rockmetal[i]);
    WriteString(Crypt(pls_rockmetal[i]));
  end;

  WriteString(genrelist[3]);
  WriteInt8(High(chn_ecletic) + 1);
  for i := 0 to High(chn_ecletic) do
  begin
    WriteString(chn_ecletic[i]);
    WriteString(Crypt(pls_ecletic[i]));
  end;

  WriteString(genrelist[4]);
  WriteInt8(High(chn_hiphop) + 1);
  for i := 0 to High(chn_hiphop) do
  begin
    WriteString(chn_hiphop[i]);
    WriteString(Crypt(pls_hiphop[i]));
  end;

  WriteString(genrelist[5]);
  WriteInt8(High(chn_oldmusic) + 1);
  for i := 0 to High(chn_oldmusic) do
  begin
    WriteString(chn_oldmusic[i]);
    WriteString(Crypt(pls_oldmusic[i]));
  end;

  WriteString(genrelist[6]);
  WriteInt8(High(chn_industrial) + 1);
  for i := 0 to High(chn_industrial) do
  begin
    WriteString(chn_industrial[i]);
    WriteString(Crypt(pls_industrial[i]));
  end;

  WriteString(genrelist[7]);
  WriteInt8(High(chn_misc) + 1);
  for i := 0 to High(chn_misc) do
  begin
    WriteString(chn_misc[i]);
    WriteString(Crypt(pls_misc[i]));
  end;

  WriteString(genrelist[8]);
  WriteInt8(High(chn_brasil) + 1);
  for i := 0 to High(chn_brasil) do
  begin
    WriteString(chn_brasil[i]);
    WriteString(Crypt(pls_brasil[i]));
  end;

  Dest.SaveToFile('db.dat');
  Dest.Free;
end;


begin
  doIt;
end.

