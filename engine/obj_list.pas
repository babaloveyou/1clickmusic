unit obj_list;

interface

type
  PRadioEntry = ^TRadioEntry;
  TRadioEntry = record
    pos: Cardinal;
    Name: string;
    pls: string;
  end;

{ a perfect performance/size implementation for the program needs}
type
  TRadioList = class
  private
    fList: PRadioEntry;
    fListSize: Integer;
    fListCapacity: Integer;
  public
    procedure Add(const Apos: Cardinal; const AName, Apls: string);
    function getpos(const AName: string): Cardinal;
    function getname(const Apos: Cardinal): string;
    function getpls(const Apos: Cardinal): string;
    constructor Create;
    destructor Destroy; override;
  end;

implementation

{ TRadioList }

procedure TRadioList.Add(const Apos: Cardinal; const AName, Apls: string);
var
  entry: PRadioEntry;
begin
  if fListSize = fListCapacity then
  begin
    fListCapacity := fListCapacity * 2;
    ReallocMem(fList,fListCapacity * SizeOf(TRadioEntry));
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
  FreeMem(fList);
end;

function TRadioList.getname(const Apos: Cardinal): string;
var
  i: Integer;
  entry: PRadioEntry;
begin
  i := 0;
  entry := fList;
  while i < fListSize do
  begin
    if entry.pos = Apos then
    begin
      Result := entry.Name;
      Exit;
    end;
    Inc(i);
    Inc(entry);
  end;
  Result := '';
end;

function TRadioList.getpls(const Apos: Cardinal): string;
var
  i: Integer;
  entry: PRadioEntry;
begin
  i := 0;
  entry := fList;
  while i < fListSize do
  begin
    if entry.pos = Apos then
    begin
      Result := entry.pls;
      Exit;
    end;
    Inc(i);
    Inc(entry);
  end;
  Result := '';
end;

function TRadioList.getpos(const AName: string): Cardinal;
var
  i: Integer;
  entry: PRadioEntry;
begin
  i := 0;
  entry := fList;
  while i < fListSize do
  begin
    if entry.Name = AName then
    begin
      Result := entry.pos;
      Exit;
    end;
    Inc(i);
    Inc(entry);
  end;
  Result := 0;
end;

end.

