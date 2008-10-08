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
    //nowplayurl : string
    scroburl: string;
    sessioncode: string;
    procedure fixTrackName(var Title: string);
    function HandShake(const UserName, password: string): LongBool;
    procedure Scrobb(const artist, track: string);
  public
    ErrorStr: string;
    function Execute(title: string): LongBool;
  end;

implementation

uses
  utils, main;

{ TScrober }

function HttpPostText(const URL, URLdata: string; Response: TStringList): Boolean;
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


procedure TScrobber.fixTrackName(var Title: string);
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

function TScrobber.HandShake(const UserName, password: string): LongBool;
const
  handshakeurl = 'http://post.audioscrobbler.com/?hs=true&p=1.2.1&c=1cm&v=1.2&u=%s&t=%s&a=%s';
var
  sl: TStringList;
  timestamp: string;
  authMD5: string;
begin
  ///////////// http://www.last.fm/api/submissions
  Result := True;
  timestamp := IntToStr(DateTimeToUnix(IncHour(Now, 3)));
  authMD5 := StrToHex(MD5(StrToHex(MD5(password)) + timestamp));

  sl := TStringList.Create;
  if HttpGetText(Format(handshakeurl, [username, timestamp, authMD5]), sl) then
    if (sl.Count > 3) and (sl[0] = 'OK') then
    begin
      sessioncode := sl[1]; // SESSION CODE
    //nowplayurl := sl[2]; // Now Playing URL
      scroburl := sl[3]; // SCROB URL
    end
    else
    begin
      ErrorStr := 'Last.FM plugin handshake' + #10#13 + sl.Text;
      Result := False;
    end;

  sl.Free;
end;

function TScrobber.Execute(title: string): LongBool;
var
  artist, track: string;
  p: Integer;
begin
  Result := HandShake(lastfm_user, lastfm_pass);
  if not Result then Exit;

  fixTrackname(title);

  p := Pos(' - ', title);

  if (p = 0) or MultiPos(['www', 'http', '.fm'], title) then
    Exit;

  artist := Copy(title, 1, p - 1);
  track := Copy(title, p + 3, MaxInt);

  Scrobb(artist, track);
end;

procedure TScrobber.Scrobb(const artist, track: string);
const
  //nowplayparam = 's=%s&a=%s&t=%s&b=&l=&n=&m=';
  scrobparam = 's=%s&a[0]=%s&t[0]=%s&i[0]=%s&o[0]=P&r[0]=L&l[0]=320&b[0]=&n[0]=&m[0]=';
var
  sl: TStringList;
  urldata, timestamp: string;
begin
  sl := TStringList.Create;
  //urldata := EncodeURL(AnsiToUtf8(Format(nowplayparam, [sessioncode, artist, track])));
  //HttpPostText(nowplayurl, urldata, sl);
  timestamp := IntToStr(DateTimeToUnix(IncHour(Now, 3)));
  urldata := EncodeURL(AnsiToUtf8(Format(scrobparam, [sessioncode, artist, track, timestamp])));
  HttpPostText(scroburl, urldata, sl);
  sl.Free;
end;

end.

