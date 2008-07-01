unit obj_db;

interface

uses Windows, SysUtils, KOL, Classes, utils, obj_list;

procedure LoadDb(const TV: PControl; const List: PRadioList);

implementation

procedure LoadDb(const TV: PControl; const List: PRadioList);
var
  i: Integer;
  n: Integer;
  Parent: Cardinal;
  Src: TResourceStream;
  Genres: array of string;
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

  n := ReadInt8();
  SetLength(Genres, n);

  for i := 0 to High(Genres) do
    Genres[i] := ReadString();

  for n := 0 to High(Genres) do
  begin
    Parent := TV.TVInsert(0, 0, genres[n]);

    for i := 0 to ReadInt8() - 1 do
    begin
      sChn := ReadString();

      List.Add(
        TV.TVInsert(Parent, 0, sChn),
        sChn,
        Crypt(ReadString())
        );
    end;

    TV.TVSort(Parent);
  end;

  Src.Free;
end;

end.

