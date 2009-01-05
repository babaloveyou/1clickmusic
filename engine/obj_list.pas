unit obj_list;

interface

uses KOL;

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
    fList: PList;
  public
    procedure Add(const Apos: Cardinal; const AName, Apls: AnsiString);
    function getpos(const AName: AnsiString): Cardinal;
    function getname(const Apos: Cardinal): AnsiString;
    function getpls(const Apos: Cardinal): AnsiString;
    constructor Create;
    destructor Destroy; override;
  end;

implementation

{ TRadioList }

procedure TRadioList.Add(const Apos: Cardinal; const AName, Apls: AnsiString);
var
  entry: PRadioEntry;
begin
  entry := New(PRadioEntry);
  with entry^ do
  begin
    pos := Apos;
    Name := AName;
    pls := Apls;
  end;

  fList.Add(entry);
end;

constructor TRadioList.Create;
begin
  fList := NewList;
  fList.Capacity := 300;
end;

destructor TRadioList.Destroy;
var
  i : Integer;
begin
  for i := 0 to fList.Count - 1 do
    Dispose(PRadioEntry(fList.Items[i]));
  fList.Free;
end;

function TRadioList.getname(const Apos: Cardinal): AnsiString;
var
  i: Integer;
begin
  for i := 0 to fList.Count - 1 do
    with PRadioEntry(fList.Items[i])^ do
      if pos = Apos then
      begin
        Result := Name;
        Exit;
      end;
  Result := '';
end;

function TRadioList.getpls(const Apos: Cardinal): AnsiString;
var
  i: Integer;
begin
  for i := 0 to fList.Count - 1 do
    with PRadioEntry(fList.Items[i])^ do
      if pos = Apos then
      begin
        Result := pls;
        Exit;
      end;
  Result := '';
end;

function TRadioList.getpos(const AName: AnsiString): Cardinal;
var
  i: Integer;
begin
  for i := 0 to fList.Count - 1 do
    with PRadioEntry(fList.Items[i])^ do
      if Name = AName then
      begin
        Result := pos;
        Exit;
      end;
  Result := 0;
end;

end.

