unit obj_db;

interface

uses
  SysUtils,
  Windows,
  KOL,
  Classes,
  httpsend,
  synautil,
  synacode,
  obj_list;

procedure LoadDb(const TV: PControl; const List: TRadioList);
procedure LoadCustomDb(const TV: PControl; const List: TRadioList; const filename: string);

implementation

uses utils;

{$I db.inc}

procedure LoadDb(const TV: PControl; const List: TRadioList);
var
  i, n: Integer;
  Parent: Cardinal;
  Src: TStream;
  sChn: string;

  function ReadInt8(): Byte;
  begin
    Src.Read(Result, 1);
  end;

  function ReadString: string;
  var
    l: Byte;
  begin
    Src.Read(l, 1);
    SetLength(Result, l);
    Src.Read(PChar(Result)^, l);
  end;

begin
  Src := TPointerStream.Create(@dbdata, Length(dbdata));

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

  Src.Free;
end;


{function SubmitCustomDb(Parameter: Pointer): Integer;
var
  ms: TMemoryStream;
begin
  ms := TMemoryStream.Create;
  HttpPostURL('http://arthurprs.srcom.org/', EncodeURL('data=' + TStringList(Parameter).Text), ms);
  TStringList(Parameter).Free;
  ms.Free;
end;}

procedure LoadCustomDb(const TV: PControl; const List: TRadioList; const filename: string);
var
  sl: TStringList;
  name, pls : string;
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

  sl.Free;
  //BeginThread(nil, 0, SubmitCustomDb, sl, 0, i);
end;

end.

