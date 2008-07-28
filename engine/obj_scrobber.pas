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
    user: string;
    passMD5: string;
    scroburl: string;
    sessioncode: string;
    function HandShake(const UserName, password: string): Boolean;
    procedure Scrobb(const artist, track: string);
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

procedure fixTrackName(var Title: string);
var
  p: Integer;
begin
  // POG!!!
  // get rid of 1.fm ad!
  p := Pos('(1.FM', Title);
  if p = 0 then p := Pos('(WWW',Title);
  if p > 0 then
    Delete(Title, p, MaxInt);
  // get rid of | album:
  p := Pos('| Album', Title);
  if p > 0 then
    Delete(Title, p, MaxInt);
  //
end;

function TScrobber.HandShake(const UserName, password: string): Boolean;
const
  handshakeurl = 'http://post.audioscrobbler.com/?hs=true&p=1.1&c=1cm&v=1.0&u=%s';
var
  lines: TStringlist;
begin
  Result := False;
  user := UserName;
  passMD5 := StrToHex(MD5(password));
  lines := TStringlist.Create;
  
  if HttpGetText(Format(handshakeurl, [user]), lines) then
    if lines[0] = 'UPTODATE' then
    begin
      Result := True;
      sessioncode := lines[1]; // SESSION CODE
      scroburl := lines[2]; // SCROB URL
    end
    else
      Error := 'Last.FM plugin handshake ERROR :' + #10#13 + lines[0]
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
  track := Copy(title, p + 3, Length(title) - p + 2);

  Scrobb(artist, track);

  Result := True;
end;

procedure TScrobber.Scrobb(const artist, track: string);
const
  scroburlparam = 'u=%s&s=%s&a[0]=%s&t[0]=%s&b[0]=&m[0]=&l[0]=240&i[0]=%s';
var
  timestamp: string;
  authmd5: string;
  urldata: string;
  lines: TStringlist;
begin
  // Format and Correct the UCT time
  timestamp := FormatDateTime('YYYY-MM-DD hh:mm:ss', IncHour(Now, 3));

  authmd5 := StrToHex(MD5(passMD5 + sessioncode));

  urldata := EncodeURL(AnsiToUtf8(Format(scroburlparam, [user, authmd5, artist, track, timestamp])));

  lines := TStringlist.Create;
  HttpPostText(scroburl, urldata, lines);
  if lines[0] <> 'OK' then
    writeFile('ERROR.txt', lines[0]);

  lines.Free;
end;

end.

