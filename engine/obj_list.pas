unit obj_list;

interface

type
  PRadioEntry = ^TRadioEntry;
  TRadioEntry = record
    pos: Cardinal;
    Name: AnsiString;
    pls: AnsiString;
  end;

  {
  a perfect performance/size implementation for the program needs,
  WARNING! the class assumes that it at least 1 entry
  }
type
  TRadioList = class
  private
    fList: PRadioEntry;
    fListSize: Integer;
    fListCapacity: Integer;
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
  if fListSize = fListCapacity then
  begin
    fListCapacity := fListCapacity * 2;
    ReallocMem(fList, fListCapacity * SizeOf(TRadioEntry));
  end;

  //entry := fList;
  //Inc(entry,fListsize);
  entry := Pointer(Integer(fList) + (fListSize * SizeOf(TRadioEntry)));
  with entry^ do
  begin
    pos := Apos;
    Name := AName;
    pls := Apls;
  end;

  Inc(fListSize);
end;

constructor TRadioList.Create;
begin
  fListCapacity := 256;
  fListSize := 0;
  GetMem(fList, SizeOf(TRadioEntry) * fListCapacity);
end;

destructor TRadioList.Destroy;
begin
  // there is a string memory leak here
  FreeMem(fList);
end;

function TRadioList.getname(const Apos: Cardinal): AnsiString;
var
  i: Integer;
  entry: PRadioEntry;
begin
  i := 0;
  entry := fList;
  repeat
    if entry.pos = Apos then
    begin
      Result := entry.Name;
      Exit;
    end;
    Dec(i);
    Inc(entry);
  until i = 0; // no remaining items to search
  Result := '';
end;

function TRadioList.getpls(const Apos: Cardinal): AnsiString;
var
  i: Integer;
  entry: PRadioEntry;
begin
  i := fListSize;
  entry := fList;
  repeat
    if entry.pos = Apos then
    begin
      Result := entry.pls;
      Exit;
    end;
    Dec(i);
    Inc(entry);
  until i = 0; // no remaining items to search
  Result := '';
end;

function TRadioList.getpos(const AName: AnsiString): Cardinal;
var
  i: Integer;
  entry: PRadioEntry;
begin
  i := fListSize;
  entry := fList;
  repeat
    if entry.Name = AName then
    begin
      Result := entry.pos;
      Exit;
    end;
    Dec(i);
    Inc(entry);
  until i = 0; // no remaining items to search
  Result := 0;
end;

end.

