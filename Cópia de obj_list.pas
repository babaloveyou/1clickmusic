unit obj_list;

interface

uses kol;

type
  PRadioItem = ^TRadioItem;
  TRadioItem = record
    pos: Cardinal;
    name: string;
    pls: string;
  end;

type
  PRadioList = ^TRadioList;
  TRadioList = object(TObj)
  private
    list: PList;
    function Get(index: Integer): PRadioItem;
  public
    property items[index: Integer]: PRadioItem read Get; default;
    procedure Add(const pos: Cardinal; const name: string; const pls : string);
    function count: Integer;
    function getpos(const name: string): Cardinal;
    function getname(const pos: Cardinal): string;
    function getpls(const name: string): string;
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

procedure TRadioList.Add(const pos: Cardinal; const name: string; const pls : string);
var
  newitem: PRadioItem;
begin
  New(newitem);
  newitem.pos := pos;
  newitem.name := name;
  newitem.pls := pls;
  list.Add(newitem);
end;

function TRadioList.count: Integer;
begin
  Result := list.Count;
end;

constructor TRadioList.Create;
begin
  inherited Create;
  list := NewList;
end;

destructor TRadioList.Destroy;
begin
  while list.Count > 0  do
  begin
    Dispose(PRadioItem(list.Items[0]));
	  list.delete(0);
  end;
  list.Free;
end;

function TRadioList.Get(index: Integer): PRadioItem;
begin
  Result := list.Items[index];
end;


function TRadioList.getname(const pos: Cardinal): string;
var i: Integer;
begin
  for i := 0 to count - 1 do
    if items[i].pos = pos then
    begin
      Result := PRadioItem(list.items[i]).name;
      Exit;
    end;
  Result := '';
end;

function TRadioList.getpls(const name: string): string;
var i: Integer;
begin
  for i := 0 to count - 1 do
    if items[i].name = name then
    begin
      Result := PRadioItem(list.items[i]).pls;
      Exit;
    end;
  Result := '';
end;

function TRadioList.getpos(const name: string): Cardinal;
var i: Integer;
begin
  for i := 0 to count - 1 do
    if items[i].name = name then
    begin
      Result := PRadioItem(list.items[i]).pos;
      Exit;
    end;
  Result := 0;
end;

end.

