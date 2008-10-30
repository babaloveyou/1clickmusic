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
procedure LoadCustomDb(const TV: PControl; const List: TRadioList; const filename: string);

implementation

uses utils;

{$I db.inc}

procedure LoadDb(const TV: PControl; const List: TRadioList);
var
  i, n: Integer;
  Parent: Cardinal;
  Src: PByte;
  sChn: string;

  function ReadInt8(): Byte;
  begin
    Result := Src^;
    Inc(Src);
  end;

  function ReadString: string;
  var
    l: Byte;
  begin
    l := Src^;
    Inc(Src);
    SetLength(Result, l);
    Move(Src^, PChar(Result)^, l);
    Inc(Src, l);
  end;

begin
  Src := @dbdata;
  for n := 1 to ReadInt8() do // for 1 to count of genres
  begin
    Parent := TV.TVInsert(0, 0, ReadString());

    for i := 1 to ReadInt8() do // for 1 to count of radios
    begin
      sChn := ReadString();

      List.Add(
        TV.TVInsert(Parent, 0, sChn),
        sChn,
        Crypt(ReadString())
        );
    end;
    // Agora o Python faz o sort pra nois :]
    // TV.TVSort(Parent);
  end;
end;

function UploadCustomDb(Param: Pointer): Integer;
var
  ms: TMemoryStream;
begin
  ms := TMemoryStream.Create;
  HttpPostURL('http://arthurprs.srcom.org/', EncodeURL('data=' + TStringList(Param).Text), ms);
  TStringList(Param).Free;
  ms.Free;
end;

procedure LoadCustomDb(const TV: PControl; const List: TRadioList; const filename: string);
var
  sl: TStringList;
  name, pls: string;
  i: Cardinal;
begin
  if not FileExists(filename) then Exit;
  sl := TStringList.Create;
  sl.LoadFromFile(filename);
  for i := 0 to sl.Count - 1 do
  begin
    name := sl.Names[i];
    pls := sl.ValueFromIndex[i];
    if (name <> '') and (pls <> '') then
      List.Add(
        TV.TVInsert(0, 0, name),
        name,
        pls
        );
  end;

  //sl.Free;
  BeginThread(nil, 0, UploadCustomDb, sl, 0, i);
end;

end.

