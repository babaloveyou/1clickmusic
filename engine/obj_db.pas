unit obj_db;

interface

uses Windows, SysUtils, KOL, Classes, utils, obj_list;

procedure LoadDb(const TV: PControl; const List: PRadioList);

implementation

procedure LoadDb(const TV: PControl; const List: PRadioList);
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

end.

