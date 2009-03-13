unit radioopener;

interface

uses
  SysUtils,
  Classes,
  httpsend,
  DSoutput,
  mmsstream,
  mp3stream;

function OpenRadio(const url: string; var APlayer: TRadioPlayer; const ADevice: TDSoutput): LongBool;

implementation

uses utils, StrUtils;

procedure ParseASX(const Lines: TStrings);
var
  i, a, b: Integer;
  Line: string;
begin
  i := 0;
  while i < Lines.Count do
  begin
    Line := Lines[i];
    a := Pos('<ref', Line);
    if (a > 0){ and (not MultiPos(['.htm', '.as', '.php', '.cgi'], Line)) }then
    begin
      a := PosEx('"', Line, a) + 1;
      b := PosEx('"', Line, a + 5);
      Lines[i] := Copy(Line, a, b - a);
      Inc(i);
    end
    else
      Lines.Delete(i);
  end;
end;

procedure ParsePLS(const Lines: TStrings);
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

procedure openpls(const url: string; const urls : TStringList);
begin
  if Pos('mms://', url) > 0 then
  begin
    urls.Add(url);
    Exit;
  end;

  // mms is the only we know for sure,
  // otherwise we will test the url for asx, m3u and pls
  HttpGetText(url, urls);
  if urls.Count < 2 then Exit;
  if urls[0] = '' then urls.Delete(0);
  // lowercase the content for parse
  urls.Text := LowerCase(urls.Text);

  if Pos('asx', urls[0]) > 0 then
    ParseASX(urls)
  else
    if MultiPos(['playlist', 'm3u'], urls[0]) or
     (Pos('.m3u', url) > 0)  then
      ParsePLS(urls)
    else
      urls.Add(url);
end;

function OpenRadio(const url: string; var APlayer: TRadioPlayer; const ADevice: TDSoutput): LongBool;
var
  urls: TStringList;
  i: Integer;
begin
  Result := False;
  urls := TStringList.Create;
  openpls(url, urls);
  for i := 0 to urls.Count - 1 do
  begin
    if MultiPos(['.as', '.wm'], url) or // asp aspx wmx wma
      MultiPos(['mms://', '.wma'], urls[i]) then
      APlayer := TMMS.Create(ADevice)
    else
      APlayer := TMP3.Create(ADevice);

    Result := APlayer.Open(urls[i]);
    if Result then
      Break
    else
      FreeAndNil(APlayer);
  end;
  urls.Free;
end;

end.

