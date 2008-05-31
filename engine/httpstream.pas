unit httpstream;

interface
uses
  SysUtils,
  Classes,
  Windows,
  blcksock,
  _DirectSound;

const // CONFIGURATION
  BUFFSIZE = 1024;
  BUFFCOUNT = 100;
  BUFFTOTALSIZE = BUFFSIZE * BUFFCOUNT;

  BUFFMIN = 8; // PERCENT TO TRIGER BUFF RECOVER?
  BUFFRESTORE = 50; // PERCENT TO RECOVER
  BUFFPRE = 80; // 80% PREBUFFER

type
  THTTPSTREAM = class(TThread)
  private
    BytesUntilMeta: Cardinal; // used to manage icy data
    FHTTP: TTCPBlockSocket;
    MetaInterval, MetaBitrate: Cardinal;
    MetaTitle: string;

    inbuffer: array[0..BUFFCOUNT - 1] of array[0..BUFFSIZE - 1] of Byte;
    procedure UpdateBuffer;
    class procedure ParseMetaData(meta: string; out MetaTitle: string);
    class function ParseMetaHeader(var meta: string; out MetaInterval, MetaBitrate: Cardinal): Integer;
    class procedure ParseURL(url: string; out host, port, icyheader: string);
  protected
    procedure Execute; override;
  public
    Cursor, Feed: Cardinal;
    //# % of buffer that is filled
    BuffFilled: Cardinal;
    //# Get ShoutCast info
    procedure GetMetaInfo(out Atitle: string; out Aquality: Cardinal);
    //# Read the Buffer
    function GetBuffer: PByte;
    procedure NextBuffer;
    //# Open stream
    function Open(const url: string): Boolean;
    constructor Create;
    destructor Destroy; override;
  end;

implementation

uses utils, main, Messages;

procedure SplitValue(const data: string; out field, value: string);
var
  p: Integer;
begin
  p := Pos(':', data);
  if p > 0 then
  begin
    field := Trim(Copy(data, 1, p - 1));
    value := Trim(Copy(data, p + 1, Length(data) - p));
  end;
end;

class procedure THTTPSTREAM.ParseURL(url: string; out host, port, icyheader: string);
const
  ICYHEADERSTUB =
    'GET %s HTTP/1.0' + #13#10 +
    'Host: %s' + #13#10 +
    'Accept: */*' + #13#10 +
    'Icy-MetaData: 1' + #13#10 +
    'User-Agent: 1ClickMusic' + #13#10 +
    #13#10;
var
  i: Integer;
begin
  url := LowerCase(url);
  if Pos('http://', url) > 0 then
    Delete(url, 1, 7); // delete http://
  i := Pos(':', url);
  if i > 0 then
  begin // has port
    host := Copy(url, 1, i - 1);
    Delete(url, 1, i); // delete host
    i := Pos('/', url);
    if i > 0 then // take port
    begin
      port := Copy(url, 1, i - 1);
      Delete(url, 1, i - 1); // delete port
    end
    else
      port := Copy(url, 1, Length(url));
  end
  else
  begin // don't have port, default = 80
    port := '80';
    i := Pos('/', url);
    if i > 0 then // no port, take host
    begin
      host := Copy(url, 1, i - 1);
      Delete(url, 1, i - 1); // delete host
    end
    else
      host := Copy(url, 1, Length(url));
  end;

  if i = 0 then
    url := '/';

  icyheader := Format(ICYHEADERSTUB, [url, host + ':' + port]);
end;

class function THTTPSTREAM.ParseMetaHeader(var meta: string; out MetaInterval, MetaBitrate: Cardinal): Integer;
var
  MetaData: TStringlist;
  field, value: string;
  i: Integer;
begin
  Result := 0;
  if meta = '' then Exit;

  MetaData := TStringlist.Create;
  MetaData.Text := meta;

  if Pos('200', MetaData[0]) > 0 then
  begin
    for i := 1 to MetaData.Count - 1 do
    begin
      SplitValue(MetaData[i], field, value);

      if field = 'icy-metaint' then MetaInterval := StrToInt(value)
      else if field = 'icy-br' then MetaBitrate := StrToInt(value)
      else if value = 'audio/mpeg' then Result := 1;
        //else if field='icy-description' then StreamInfo.Desc:=Value
        //else if field='icy-genre' then StreamInfo.Genre:=Value
        //else if field= 'icy-name' then StreamInfo.Name := value
        //else if field='icy-pub' then StreamInfo.Pub:=Value
        //else if field='icy-url' then StreamInfo.URL:=Value
      ;
    end;
    if (MetaInterval = 0) or (MetaBitrate = 0) then
      Result := 0;
  end
  else
    if MultiPos(['302', '303', '301'], MetaData[0]) then
    begin
      for i := 1 to MetaData.Count - 1 do
      begin
        SplitValue(MetaData[i], field, value);
        if field = 'Location' then
        begin
          Result := -1;
          Meta := value;
          break;
        end;
      end;
    end;

  MetaData.Free;
end;

class procedure THTTPSTREAM.ParseMetaData(meta: string; out MetaTitle: string);
//const
  //field = 'StreamTitle=''';
  //fieldlen = Length(field); = 13
begin
  if meta = '' then Exit;
  Delete(meta, 1, 13);
  MetaTitle := Copy(meta, 1, Pos('''', meta) - 1);
end;

{ THTTPSTREAM }

procedure THTTPSTREAM.UpdateBuffer;
var
  metalength: Byte;
  bytesreceived, bytestoreceive: Cardinal;
begin
  bytesreceived := 0;
  while bytesreceived < BUFFSIZE do
  begin
    if (BytesUntilMeta = 0) then
    begin
      BytesUntilMeta := MetaInterval;
      metalength := FHTTP.RecvByte(MaxInt);
      if metalength = 0 then Continue;
      ParseMetaData(FHTTP.RecvBufferStr(metalength * 16, MaxInt), MetaTitle);
    end
    else
    begin
      bytestoreceive := BUFFSIZE - bytesreceived;
      if bytestoreceive > BytesUntilMeta then
        bytestoreceive := BytesUntilMeta;

      FHTTP.RecvBufferEx(@inbuffer[Feed, bytesreceived], bytestoreceive, MaxInt);
      if (FHTTP.LastError <> 0) and
        (not Terminated) then
      begin
        Terminate;
        PostMessage(appwinHANDLE, WM_USER, Integer(chn), 0);
      end;

      Dec(BytesUntilMeta, bytestoreceive);
      Inc(bytesreceived, bytestoreceive);
    end;
  end;
  if Feed = BUFFCOUNT - 1 then Feed := 0 else Inc(Feed);
  Inc(BuffFilled);
end;

constructor THTTPSTREAM.Create;
begin
  inherited Create(True);
  FHTTP := TTCPBlockSocket.Create;
  Priority := tpTimeCritical;

  Cursor := MaxInt; // para evitar que bloqueie
  Feed := 0;
  BuffFilled := 0;
  MetaInterval := 0;
  MetaBitrate := 0;
end;

destructor THTTPSTREAM.Destroy;
begin
  Terminate;
  FHTTP.CloseSocket;
  FHTTP.Free;
  inherited;
end;

procedure THTTPSTREAM.Execute;
begin
  repeat
    if Cursor <> Feed then
      UpdateBuffer();
    Sleep(10);
  until Terminated;
end;

function THTTPSTREAM.Open(const url: string): Boolean;
var
  host, port, icyheader: string;
  response: string;
begin
  Result := False;
  ParseURL(url, host, port, icyheader);
  FHTTP.CloseSocket;
  if proxy_enabled then
  begin
    FHTTP.HTTPTunnelTimeout := 2500;
    FHTTP.HTTPTunnelIP := proxy_host;
    FHTTP.HTTPTunnelPort := proxy_port;
  end;

  FHTTP.Connect(host, port);
  if FHTTP.LastError <> 0 then
    Exit;
  FHTTP.SendString(icyheader);

  response := FHTTP.RecvTerminated(5000, #13#10#13#10);

  case ParseMetaHeader(response, MetaInterval, MetaBitrate) of
    1:
      Result := True;
    0:
      Exit;
    -1:
      Result := Open(response);
  end;

  BytesUntilMeta := MetaInterval;
end;

procedure THTTPSTREAM.GetMetaInfo(out Atitle: string; out Aquality: Cardinal);
begin
  Atitle := MetaTitle;
  Aquality := MetaBitrate;
end;

function THTTPSTREAM.GetBuffer: PByte;
begin
  Result := @inbuffer[Cursor];
end;

procedure THTTPSTREAM.NextBuffer;
begin
  if Cursor = BUFFCOUNT - 1 then Cursor := 0 else Inc(Cursor);
  Dec(BuffFilled);
end;

end.

