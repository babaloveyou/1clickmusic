unit obj_db;

interface

uses SysUtils, Windows, KOL, Classes, utils, obj_list;

procedure LoadDb(const TV: PControl; const List: TRadioList);
procedure LoadCustomDb(const TV: PControl; const List: TRadioList; const filename: string);


implementation

procedure LoadDb(const TV: PControl; const List: TRadioList);
var
  i, n: Integer;
  Parent: Cardinal;
  Src: TResourceStream;
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
  Src := TResourceStream.Create(HInstance, 'db', RT_RCDATA);

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

procedure LoadCustomDb(const TV: PControl; const List: TRadioList; const filename: string);
var
  sl: TStringList;
  i: Integer;
begin
  sl := TStringList.Create;
  sl.LoadFromFile(filename);
  for i := 0 to sl.Count - 1 do
    List.Add(
      TV.TVInsert(0, 0, sl.Names[i]),
      sl.Names[i],
      sl.ValueFromIndex[i]
      );
  sl.Free;
end;

end.

