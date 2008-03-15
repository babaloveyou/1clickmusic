unit obj_scrobber;

interface

uses
  SysUtils,
  DateUtils,
  Classes,
  IcsMD5,
  httpsend;

type
  TScrobber = class
  private
    user: string;
    pass: string;
    passMD5: string;
    scroburl: string;
    sessioncode: string;
    function HandShake(const UserName, password: string): Boolean;
    function Scrobb(const artist, track: string): Boolean;
  public
    Error: string;
    function Execute(const title: string): Boolean;
  end;

implementation

{ TScrober }

uses main;

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

function LCStrMD5(const str: string): string;
begin
  Result := AnsiLowerCase(StrMD5(str));
end;

function TScrobber.HandShake(const UserName, password: string): Boolean;
const
  handshakeurl = 'http://post.audioscrobbler.com/?hs=true&p=1.1&c=1cm&v=0.1&u=%s';
var
  sl: TStringlist;
begin
  Result := False;
  user := UserName;
  pass := password;
  passMD5 := LCStrMD5(pass);
  sl := TStringlist.Create;
  HttpGetText(Format(handshakeurl, [user]), sl);
  try
    if sl[0] = 'UPTODATE' then
    begin
      Result := True;
      sessioncode := sl[1]; // SESSION CODE
      scroburl := sl[2]; // SCROB URL
    end
    else
      Error := Format('Last.FM plugin handshake ERROR :' + #10#13 + '%s', [sl[0]]);
  finally
    sl.Free;
  end;
end;

function TScrobber.Execute(const title: string): Boolean;
var
  artist, track: string;
  p: Integer;
begin
  Result := False;

  if not HandShake(lastfm_user, lastfm_pass) then
    Exit;

  p := Pos(' - ', title);

  if (p = 0) or
    (Pos('.FM', UpperCase(title)) > 0) or
    (Pos('http', title) > 0) or
    (Pos('www', title) > 0) then
    Exit;

  artist := Copy(title, 1, p - 1);
  track := Copy(title, p + 3, Length(title) - p + 2);

  if not Scrobb(artist, track) then
    Exit;

  Result := True;
end;

function TScrobber.Scrobb(const artist, track: string): Boolean;
const
  scroburlparam = 'u=%s&s=%s&a[0]=%s&t[0]=%s&b[0]=%s&m[0]=&l[0]=%d&i[0]=%s';
var
  moment: string;
  md5response: string;
  urldata: UTF8String;
  sl: TStringlist;
begin
  Result := False;
  sl := TStringlist.Create;
  // Format and Correct the GMT - 2 time
  moment := FormatDateTime('YYYY-MM-DD hh:mm:ss', IncHour(Now, 2));
  // md5 response
  md5response := LCStrMD5(passMD5 + sessioncode);
  // the finalurl encoded to UTF-8
  urldata := AnsiToUtf8(Format(scroburlparam, [user, md5response, artist, track, '', 240, moment]));
  // submit the POST
  if HttpPostText(scroburl, urldata, sl) and (sl[0] = 'OK') then
    Result := True
  else
    Error := Format('Last.FM plugin scrobbing ERROR :' + #10#13 + '%s', [sl[0]]);
  //
  sl.Free;
end;

end.

