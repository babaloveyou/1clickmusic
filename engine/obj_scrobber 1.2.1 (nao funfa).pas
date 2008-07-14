unit obj_scrobber;

interface

uses
  SysUtils,
  DateUtils,
  Classes,
  synautil,
  synacode,
  httpsend;

type
  TScrobber = class
  private
    scroburl: string;
    sessioncode: string;
    class procedure fixTrackName(var Title: string);
    function HandShake(const UserName, password: string): Boolean;
    function Scrobb(const artist, track: string): Boolean;
  public
    Error: string;
    function Execute(title: string): Boolean;
  end;

implementation

uses
  main,
  utils;

{ TScrober }

function HttpPostText(const URL, URLdata: string; Response: TStrings): Boolean;
var
  HTTP: THTTPSend;
begin
  HTTP := THTTPSend.Create;
  HTTP.MimeType := 'application/x-www-form-urlencoded';
  HTTP.Document.Write(PChar(URLdata)^, Length(URLdata));
  try
    Result := HTTP.HTTPMethod('POST', URL);
    if Result then
    begin
      Result := HTTP.ResultCode = 200;
      Response.LoadFromStream(HTTP.Document);
    end;
  finally
    HTTP.Free;
  end;
end;


class procedure TScrobber.fixTrackName(var Title: string);
var
  p: Integer;
begin
  // POG
  // get rid of some ad's!
  p := Pos('http', Title);
  if p > 0 then
    Delete(Title, p, Length(Title) - p);
  // get rid of 1.fm ad!
  p := Pos('(1.FM', Title);
  if p = 0 then p := Pos('(WWW', Title);

  if p > 0 then
    Delete(Title, p, Length(Title) - p);
  // get rid of | album:
  p := Pos('| Album', Title);
  if p > 0 then
    Delete(Title, p, Length(Title) - p);
  //
end;

function TScrobber.HandShake(const UserName, password: string): Boolean;
const
  handshakeurl = 'http://post.audioscrobbler.com/?hs=true&p=1.2.1&c=1cm&v=1.0&u=%s&t=%s&a=%s';
var
  lines: TStringlist;
  timestamp: string;
  authMD5: string;
begin

///////////// http://www.last.fm/api/submissions

  Result := False;
  timestamp := IntToStr(DateTimeToUnix(IncHour(Now, 3)));
  authMD5 := StrToHex(MD5(StrToHex(MD5(password)) + timestamp));

  lines := TStringlist.Create;
  if HttpGetText(Format(handshakeurl, [username, timestamp, authMD5]), lines) then
    if lines[0] = 'OK' then
    begin
      Result := True;
      sessioncode := lines[1]; // SESSION CODE
      scroburl := lines[2]; // SCROB URL
    end
    else
      Error := Format('Last.FM plugin handshake ERROR :' + #10#13 + '%s', [lines[0]])
  else
    Result := True;

  lines.Free;
end;

function TScrobber.Execute(title: string): Boolean;
var
  artist, track: string;
  p: Integer;
begin
  Result := False;

  if not HandShake(lastfm_user, lastfm_pass) then
    Exit;

  fixTrackname(title);

  p := Pos(' - ', title);

  if (p = 0) or MultiPos(['www', 'http', '.fm'], title) then
  begin
    Result := True; //# YES, result true
    Exit;
  end;


  artist := Copy(title, 1, p - 1);
  track := Copy(title, p + 3, MaxInt);

  if not Scrobb(artist, track) then
    Exit;

  Result := True;
end;

function TScrobber.Scrobb(const artist, track: string): Boolean;
const
  nowplayparam = 's=%s&a=%s&t=%s&b=&l=&n=&m=';
  scrobparam = 's=%s&a[0]=%s&t[0]=%s&i[0]=%s&o[0]=P&r[0]=L&l[0]=320&b[0]=&n[0]=&m[0]=';
var
  urldata: string;
  timestamp: string;
  lines: TStringlist;
begin
  Result := False;
  lines := TStringlist.Create;
  timestamp := IntToStr(DateTimeToUnix(IncHour(Now, 3)));
  urldata := EncodeURL(AnsiToUtf8(Format(nowplayparam, [sessioncode, artist, track])));
  HttpPostText(scroburl, urldata, lines);
  urldata := EncodeURL(AnsiToUtf8(Format(scrobparam, [sessioncode, artist, track, timestamp])));
  if HttpPostText(scroburl, urldata, lines) then
    if (lines[0] = 'OK') then
      Result := True
    else
      Error := 'Last.FM plugin scrobbing ERROR :' + #10#13 + lines[0]
  else
    Result := True;
  //
  lines.Free;
end;

end.

