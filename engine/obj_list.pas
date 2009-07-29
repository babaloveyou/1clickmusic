unit obj_list;

interface

uses KOL, Windows;

type
  PRadioEntry = ^TRadioEntry;
  TRadioEntry = record
    pos: Cardinal;
    Name: AnsiString;
    pls: AnsiString;
  end;

type
  TRadioList = class
  private
    fList: Array of TRadioEntry;
    fCount: Integer;
    fCapacity : Integer;
  public
    procedure Add(const Apos: Cardinal; const AName, Apls: AnsiString);
    function getpos(const AName: AnsiString): Cardinal;
    function getname(const Apos: Cardinal): AnsiString;
    function getpls(const Apos: Cardinal): AnsiString;
    constructor Create;
  end;

implementation

{ TRadioList }

procedure TRadioList.Add(const Apos: Cardinal; const AName, Apls: AnsiString);
begin
  if fCount >= fCapacity then
  begin
    fCapacity := fCapacity + fCapacity div 2;
    SetLength(fList, fCapacity);
  end;  

  with fList[fCount] do
  begin
    pos := Apos;
    Name := AName;
    pls := Apls;
  end;
  Inc(fCount);
end;

constructor TRadioList.Create;
begin
  fCount := 0;
  fCapacity := 300;
  SetLength(fList,fCapacity);
end;

function TRadioList.getname(const Apos: Cardinal): AnsiString;
var
  i: Integer;
  item : PRadioEntry;
begin
  item := @fList[0];
  for i := 0 to fCount - 1 do
  begin
    with item^ do
      if pos = Apos then
      begin
        Result := Name;
        Exit;
      end;
    Inc(item);
  end;
  Result := '';
end;

function TRadioList.getpls(const Apos: Cardinal): AnsiString;
var
  i: Integer;
  item : PRadioEntry;
begin
  item := @fList[0];
  for i := 0 to fCount - 1 do
  begin
    with item^ do
      if pos = Apos then
      begin
        Result := pls;
        Exit;
      end;
    Inc(item);
  end;
  Result := '';
end;

function TRadioList.getpos(const AName: AnsiString): Cardinal;
var
  i: Integer;
  item : PRadioEntry;
begin
  item := @fList[0];
  for i := 0 to fCount - 1 do
  begin
    with item^ do
      if Name = AName then
      begin
        Result := pos;
        Exit;
      end;
    Inc(item);
  end;
  Result := 0;
end;

end.

