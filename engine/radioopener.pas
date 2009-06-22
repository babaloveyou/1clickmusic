unit radioopener;

interface

//{$R decoders.res}

uses
  SysUtils,
  Classes,
  DSOutput,
  mmsstream, {$DEFINE MMS}
  mp3stream, {$DEFINE MP3}
  aacpstream, {$DEFINE AACP}
  httpsend,
  main,
  utils;

// "THIS" retrieves the PLS or M3U or WTF!...
// and then try to open the linwith avaliable decoders

type
  TRadioOpener = class(TThread)
  private
    fUrl: string;
  protected
    procedure Execute(); override;
  public
    constructor Create(const url: string);
  end;

implementation

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
    if (a <> 0) and (not MultiPos(['.htm', {'.as',} '.php', '.cgi', '<!--'], Line)) then
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

    if (p = 1) or
      ((p <> 0) and (Pos('file', Line) = 1)) then
    begin
      Lines[i] := Copy(Line, p, Length(Line) - p + 1);
      Inc(i);
    end
    else
      Lines.Delete(i);
  end;

end;

procedure OpenPls(const url: string; const urls: TStringList);
begin
  if MultiPos(['mms://', 'rtsp://'], url) then
  begin
    urls.Add(url);
    Exit;
  end;

  // mms is the only we know for sure,
  // otherwise we will test the url for asx, m3u and pls
  HttpGetText(url, urls);
  if urls.Count = 0 then Exit;
  if urls[0] = '' then urls.Delete(0);
  // lowercase the content for parse
  urls.Text := LowerCase(urls.Text);

  if Pos('asx', urls[0]) <> 0 then
    ParseASX(urls)
  else
    if MultiPos(['playlist', 'm3u'], urls[0]) or
      (Pos('.m3u', url) <> 0) then
      ParsePLS(urls)
    else
      urls.Add(url);
end;

{ TRadioOpener }

constructor TRadioOpener.Create(const url: string);
begin
  fUrl := url;
  inherited Create(False);
  FreeOnTerminate := True;
end;

procedure TRadioOpener.Execute;
{$IFDEF MMS}
label
  _WMA_;
{$ENDIF}
var
  urls: TStringList;
  i: Integer;
  Player: TRadioPlayer;
  r: LongBool;
begin
  Player := nil;
  r := False;
  urls := TStringList.Create;

  OpenPls(fUrl, urls);

  i := 0;
  while (not Terminated) and (i < urls.Count) do
  begin
{$IFDEF MMS}
    if MultiPos(['mms://', '.wma', '.asf'], urls[i]) then goto _WMA_;
{$ENDIF}
{$IFDEF MP3}
    Player := TMP3.Create();
    r := Player.Open(urls[i]);
    if r or Terminated then Break;
{$ENDIF}
{$IFDEF AACP}
    Player := TAACP.Create();
    r := Player.Open(urls[i]);
    if r or Terminated then Break;
{$ENDIF}
{$IFDEF MMS}
    _WMA_:
    Player := TMMS.Create();
    r := Player.Open(urls[i]);
{$ENDIF}
    Inc(i);
  end;

  urls.Free;

  if Terminated then
  begin
    if r then
    begin
      Player.Terminate;
      Player.Resume;
    end;
  end
  else
  begin
    if r then
    begin
      Chn := Player;
      Player.Resume;
    end
    else
      NotifyForm(NOTIFY_OPENERROR, 0);
  end;
end;

end.

