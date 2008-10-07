unit obj_playlist;

interface

uses
  SysUtils,
  StrUtils,
  Classes,
  Windows,
  httpsend;

type
  TPlaylist = class
  public
    urls: TStringList;
    procedure openpls(const plsurl: string);
    constructor Create;
    destructor Destroy; override;
  end;

implementation

{ TPlaylist }

uses
  utils;

procedure ParseASX(Lines: TStrings);
var
  i, a, b: Integer;
  Line: string;
begin
  i := 0;
  while i < Lines.Count do
  begin
    Line := Lines[i];
    if (not MultiPos(['.htm', '.as', '.php', '.cgi'], Line))
      and
      (Pos('<REF', UpperCase(Line)) > 0) then
    begin
      a := Pos('"', Line) + 1;
      b := PosEx('"', Line, a + 5);
      Lines[i] := Copy(Line, a, (Length(Line) - a) - (Length(Line) - b));
      Inc(i);
    end
    else
      Lines.Delete(i);
  end;
end;

procedure ParsePLS(Lines: TStrings);
var
  i, p: Integer;
  Line: string;
begin
  i := 0;
  while i < Lines.Count do
  begin
    Line := Lines[i];

    p := Pos('http://', Line); // can be mms or http
    if p = 0 then p := Pos('mms://', Line);

    if (p > 0) and (Line[1] <> '#') then
    begin
      Lines[i] := Copy(Line, p, Length(Line) - p + 1);
      Inc(i);
    end
    else
      Lines.Delete(i);
  end;

end;

constructor TPlaylist.Create;
begin
  urls := TStringList.Create;
end;

destructor TPlaylist.Destroy;
begin
  urls.Free;
  inherited;
end;

procedure TPlaylist.openpls(const plsurl: string);
begin
  if plsurl = '' then Exit;
  urls.Clear;

  if MultiPos(['.as', '.wma'], plsurl) then
  begin
    HttpGetText(plsurl, urls);
    ParseASX(urls);
  end
  else
  //# php cuz of triplag and some others
    if multipos(['.pls', '.m3u', '.php', '.wmx'], plsurl) then
    begin
      HttpGetText(plsurl, urls);
      ParsePLS(urls);
    end
    else
      urls.Add(plsurl);
end;

end.

