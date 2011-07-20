unit obj_scrobbler;

interface

uses
  SysUtils,
  DateUtils,
  Classes,
  synautil,
  synacode;

type
  TScrobbler = class
  private
    //nowplayurl : string
    scroburl: string;
    sessioncode: string;
    function HandShake(const UserName, passwordmd5: string): LongBool;
    procedure Scrobb(const artist, track: string);
  public
    ErrorStr: string;
    function Execute(title: string): Integer;
  end;

implementation

uses
  utils, main;

{ TScrober }


procedure fixTrackName(var Title: string);
var
  p: Integer;
begin
  // POG
  // get rid of some ad's!
  p := Pos('http', Title);
  if p > 0 then
    Delete(Title, p, MaxInt);

  
  p := Pos('(WWW', Title);
  if p > 0 then
    Delete(Title, p, MaxInt);

  // get rid of | album:
  p := Pos('| Album', Title);
  if p > 0 then
    Delete(Title, p, MaxInt);
  //
end;

function TScrobbler.HandShake(const UserName, passwordmd5: string): LongBool;
const
  handshakeurl = 'http://post.audioscrobbler.com/?hs=true&p=1.2.1&c=1cm&v=1.2&u=%s&t=%s&a=%s';
var
  sl: TStringList;
  timestamp: string;
  authMD5: string;
begin
  ///////////// http://www.last.fm/api/submissions
  Result := True;
  timestamp := IntToStr(DateTimeToUnix(GetUTTime()));
  authMD5 := StrToHex(MD5(passwordmd5 + timestamp));

  sl := TStringList.Create;
  if HttpGetTextEx(Format(handshakeurl, [username, timestamp, authMD5]), sl) then
    if (sl.Count > 3) and (sl[0] = 'OK') then
    begin
      sessioncode := sl[1]; // SESSION CODE
      //nowplayurl := sl[2]; // Now Playing URL
      scroburl := sl[3]; // SCROB URL
    end
    else
    begin
      ErrorStr := 'Last.fm plugin Error' + #13 + sl.Text;
      Result := False;
    end;

  sl.Free;
end;

function TScrobbler.Execute(title: string): Integer;
var
  artist, track: string;
  p: Integer;
begin
  Result := 0;
  if not HandShake(lastfm_user, lastfm_pass) then Exit;

  Result := -1;
  fixTrackname(title);
  p := Pos(' - ', title);
  if (p = 0) or MultiPos(['www.', 'http://', 'A suivre', '.fm', '.com'], title) then
    Exit;

  artist := Copy(title, 1, p - 1);
  track := Copy(title, p + 3, MaxInt);

  Scrobb(artist, track);
  Result := 1;
end;

procedure TScrobbler.Scrobb(const artist, track: string);
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

  timestamp := IntToStr(DateTimeToUnix(GetUTTime()));
  urldata := EncodeURL(AnsiToUtf8(Format(scrobparam, [sessioncode, artist, track, timestamp])));
  HttpPostTextEx(scroburl, urldata, sl);
  sl.Free;
end;

end.

