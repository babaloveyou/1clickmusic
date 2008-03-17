unit obj_playlist;

interface

uses
  Classes,
  SysUtils,
  httpsend,
  KOL;

type
  TRadioType = (rtMP3, rtMMS);

type
  TPlaylist = class
  public
    urls: TStringlist;
    function openpls(const plsurl: string): TRadioType;
    constructor Create;
    destructor Destroy; override;
  end;

implementation

{ TPlaylist }

uses StrUtils, utils;

procedure ParseASX(Lines: TStrings);

var
  i, a, b: Integer;
  Line: string;
begin
  // Delete first line, it is not usefull
  Lines.Delete(0);
  i := 0;
  while i < Lines.Count do
  begin
    Line := Lines[i];
    if (not MultiPos(['.htm', '.as', '.php'], Line))
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
  urls := TStringlist.Create;
end;

destructor TPlaylist.Destroy;
begin
  urls.Free;
  inherited;
end;

function TPlaylist.openpls(const plsurl: string): TRadioType;
begin
  Result := rtMMS;
  if plsurl = '' then Exit;
  urls.Clear;

  if MultiPos(['.as', '.wma'], plsurl) then
  begin
    HttpGetText(plsurl, urls);
    ParseASX(urls);
    Exit;
  end;

  //# php cuz of some dynamic generated playlists ex: triplag
  if multipos(['.pls', '.m3u', '.php'], plsurl) then
  begin
    HttpGetText(plsurl, urls);
    ParsePLS(urls);
  end
  else
    urls.Add(plsurl);

  if (Pos('mms://', urls.Text) > 0) then
    Result := rtMMS
  else
    Result := rtMP3;
end;

end.

