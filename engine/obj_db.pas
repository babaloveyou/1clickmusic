unit obj_db;

interface

uses
  SysUtils,
  KOL,
  Classes,
  obj_list,
  synacode,
  synautil,
  httpsend;

procedure LoadDb(const TV: PControl; const List: TRadioList);
procedure LoadCustomDb(const TV: PControl; const List: TRadioList; const filename: AnsiString);

implementation

uses utils, Main;

{$I db.inc}

procedure LoadDb(const TV: PControl; const List: TRadioList);
var
  i, n: Integer;
  Item: Cardinal;
  Parent: Cardinal;
  Src: PByte;
  sChn: AnsiString;

  function ReadInt8(): Byte;
  begin
    Result := Src^;
    Inc(Src);
  end;

  function ReadString(): AnsiString;
  begin
    SetString(Result, PChar(Cardinal(Src) + 1), Src^);
    Inc(Src, Src^ + 1);
  end;

begin
  Src := @dbdata;
  for n := 1 to ReadInt8() do // for 1 to count of genres
  begin
    Parent := TV.TVInsert(TVI_ROOT, TVI_LAST, ReadString());
    for i := 1 to ReadInt8() do // for 1 to count of radios
    begin
      sChn := ReadString();
      Item := TV.TVInsert(Parent, TVI_LAST, sChn);
      TV.TVItemImage[Item] := 1;
      TV.TVItemSelImg[Item] := 2;
      List.Add(
        Item,
        sChn,
        Crypt(ReadString())
        );
    end;
    // Agora o Python faz o sort pra nois :]
    // TV.TVSort(Parent);
  end;
end;

function Async(Param: Pointer): Integer;
begin
  if AutoUpdate() then
  begin
    firstrun_enabled := True;
    Applet.Close();
  end
  else
  begin
    with THTTPSend.Create do
    begin
      UserAgent := '';
      HTTPMethod('GET', 'http://1clickmusic.net/s.php?url=&ttl=&res=&ref=' + APPVERSIONSTR);
      Free;
    end;
  end;
end;

procedure LoadCustomDb(const TV: PControl; const List: TRadioList; const filename: AnsiString);
var
  sl: TStringList;
  name, pls: string;
  i: Integer;
  Item: Cardinal;
begin
  if not FileExists(filename) then Exit;
  sl := TStringList.Create;
  sl.LoadFromFile(filename);
  for i := 0 to sl.Count - 1 do
  begin
    name := sl.Names[i];
    pls := sl.ValueFromIndex[i];
    Item := TV.TVInsert(TVI_ROOT, TVI_LAST, name);
    TV.TVItemImage[Item] := 1;
    TV.TVItemSelImg[Item] := 2;
    List.Add(
      Item,
      name,
      pls
      );
  end;

  //sl.Free;
  BeginThread(nil, 0, Async, sl, 0, Item);
end;

end.

