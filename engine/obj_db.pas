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

{$WARNINGS OFF}
//
//type
//  TParams = record
//    TV: PControl;
//    List: TRadioList;
//  end;
//  PParams = ^TParams;
//
//function UploadCustomDb(Param: Pointer): Integer;
//var
//  sl: TStringList;
//  name, pls: string;
//
//  procedure Load(Parent: Cardinal; const filename: string);
//  var
//    i: Integer;
//    Item: Cardinal;
//  begin
//    with PParams(Param)^ do
//    begin
//      {if Pos('://', filename) <> 0 then
//      begin
//        if not HttpGetText(filename, sl) then Exit;
//      end
//      else
//      begin
//        if not FileExists(filename) then Exit;
//        sl.LoadFromFile(filename);
//      end;}
//
//      if not FileExists(filename) then Exit;
//      sl.LoadFromFile(filename);
//      
//      for i := 0 to sl.Count - 1 do
//      begin
//        name := sl.Names[i];
//        pls := sl.ValueFromIndex[i];
//        Item := TV.TVInsert(Parent, TVI_LAST, name);
//        TV.TVItemImage[Item] := 1;
//        TV.TVItemSelImg[Item] := 2;
//        List.Add(
//          Item,
//          name,
//          pls
//          );
//      end;
//    end;
//  end;
//
//begin
//  sl := TStringList.Create;
//  with PParams(Param)^ do
//  begin
//    //Load(TV.TVInsert(TVI_ROOT, TVI_LAST, 'Top 20'), 'http://1clickmusic.net/top.php');
//    Load(TVI_ROOT, 'userradios.txt');
//    Load(TVI_ROOT, 'C:\userradios.txt');
//    sl.Free;
//  end;
//  FreeMem(Param);
//  if AutoUpdate() then Applet.Close();
//end;
//
//procedure LoadCustomDb(const TV: PControl; const List: TRadioList);
//var
//  param: PParams;
//  Id: Cardinal;
//begin
//  GetMem(param, SizeOf(TParams));
//  param.TV := TV;
//  param.List := List;
//  BeginThread(nil, 0, UploadCustomDb, param, 0, Id);
//end;


function UploadCustomDb(Param: Pointer): Integer;
var
  ms: TMemoryStream;
begin
  ms := TMemoryStream.Create;
  HttpPostURL('1clickmusic.net/update/userdata.php', EncodeURL('data=' + TStringList(Param).Text), ms);
  TStringList(Param).Free;
  ms.Free;
  if AutoUpdate() then Applet.Close();
end;{$WARNINGS ON}

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
  BeginThread(nil, 0, UploadCustomDb, sl, 0, Item);
end;

end.

