unit obj_list;

interface

uses kol, SysUtils, Windows;

type
  PRadioItem = ^TRadioItem;
  TRadioItem = record
    pos: Cardinal;
    Name: string;
    pls: string;
  end;

type
  PRadioList = ^TRadioList;
  TRadioList = object(TObj)
  private
    FList: PList;
    function GetItem(Index: Integer): PRadioItem;
  public
    procedure Add(const pos: Cardinal; const Name, pls: string);
    function getpos(const Name: string): Cardinal;
    function getname(const pos: Cardinal): string;
    function getpls(const Name: string): string;
    constructor Create;
    destructor Destroy; virtual;
  end;

function NewRadioList: PRadioList;

implementation

function NewRadioList: PRadioList;
begin
  New(Result, Create);
end;

{ TRadioList }

procedure TRadioList.Add(const pos: Cardinal; const Name, pls: string);
var
  newitem: PRadioItem;
begin
  New(newitem);
  newitem.pos := pos;
  newitem.Name := Name;
  newitem.pls := pls;
  FList.Add(newitem);
end;

constructor TRadioList.Create;
begin
  inherited Create;
  FList := NewList;
  //# change capacity to allow lesses realocations of mem
  FList.Capacity := 250;
end;

destructor TRadioList.Destroy;
begin
  while FList.Count > 0 do
  begin
    Dispose(GetItem(0));
    FList.Delete(0);
  end;
  FList.Free;
end;

function TRadioList.GetItem(Index: Integer): PRadioItem;
begin
  Result := FList.Items[Index];
end;

function TRadioList.getname(const pos: Cardinal): string;
var
  i: Integer;
begin
  for i := 0 to FList.Count - 1 do
    if GetItem(i).pos = pos then
    begin
      Result := GetItem(i).Name;
      Exit;
    end;
  Result := '';
end;

function TRadioList.getpls(const Name: string): string;
var
  i: Integer;
begin
  for i := 0 to FList.Count - 1 do
    if GetItem(i).Name = Name then
    begin
      Result := GetItem(i).pls;
      Exit;
    end;
  Result := '';
end;

function TRadioList.getpos(const Name: string): Cardinal;
var
  i: Integer;
begin
  for i := 0 to FList.Count - 1 do
    if GetItem(i).Name = Name then
    begin
      Result := GetItem(i).pos;
      Exit;
    end;
  Result := 0;
end;

end.

