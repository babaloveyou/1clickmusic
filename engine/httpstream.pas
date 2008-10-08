unit httpstream;

interface

uses
  SysUtils,
  Classes,
  Windows,
  synautil,
  blcksock,
  DSoutput;

const // CONFIGURATION
  BUFFPACKET = 1024;
  BUFFPACKETCOUNT = 128; // 28 extra buffers
  BUFFSIZETOTAL = 1024 * BUFFPACKETCOUNT;

  BUFFRESTORE = 55;
  BUFFPRE = 70;

type
  THTTPSTREAM = class(TThread)
  private
    BytesUntilMeta: Integer; // used to manage icy data
    FHTTP: TTCPBlockSocket;
    MetaInterval, MetaBitrate: Integer;
    MetaTitle: string;
    Cursor, Feed: Integer;
    inbuffer: array[0..BUFFPACKETCOUNT - 1, 0..BUFFPACKET - 1] of Byte;
    procedure UpdateBuffer;
  protected
    procedure Execute; override;
  public
    //# n buff packets filled
    BuffFilled: Integer;
    //# Get ShoutCast info
    procedure GetMetaInfo(out Atitle: string; out Aquality: Cardinal);
    //# Read the Buffer
    function GetBuffer(): PByte;
    procedure NextBuffer();
    //# Open stream
    function Open(const url: string): LongBool;
    constructor Create;
    destructor Destroy; override;
  end;

implementation

uses utils, main;

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


procedure ParseHeader(const url: string; out host, port, icyheader: string);
const
  ICYHEADERSTUB =
    'GET %s HTTP/1.0' + #13#10 +
    'Host: %s' + #13#10 +
    'Accept: */*' + #13#10 +
    'Icy-MetaData: 1' + #13#10 +
    'User-Agent: 1ClickMusic' + #13#10 +
    #13#10;
var
  prot, user, pass,path, para: string;
begin
  ParseURL(url, prot, user, pass, host, port, path, para);
  icyheader := Format(ICYHEADERSTUB, [path, host + ':' + port]);
end;

{procedure ParseHeader(url: string; out host, port, icyheader: string);
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
end;}

function ParseMetaHeader(var meta: string; out MetaInterval, MetaBitrate: Integer): Integer;
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
  // 302, 303, 301
    if Pos('30', MetaData[0]) > 0 then
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

procedure ParseMetaData(const meta: string; out MetaTitle: string);
const
  field = 'StreamTitle=''';
  fieldlen = Length(field);
begin
  MetaTitle := Copy(meta, 14, Pos(''';', meta) - 14);
end;

{ THTTPSTREAM }

procedure THTTPSTREAM.UpdateBuffer;
var
  metalength: Byte;
  bytesreceived, bytestoreceive: Integer;
begin
  bytesreceived := 0;
  repeat
    if BytesUntilMeta = 0 then
    begin
      BytesUntilMeta := MetaInterval;
      metalength := FHTTP.RecvByte(MaxInt);
      if metalength = 0 then Continue;
      ParseMetaData(FHTTP.RecvBufferStr(metalength * 16, MaxInt), MetaTitle);
      NotifyForm(1);
    end
    else
    begin
      bytestoreceive := BUFFPACKET - bytesreceived;
      if bytestoreceive > BytesUntilMeta then
        bytestoreceive := BytesUntilMeta;

      FHTTP.RecvBufferEx(@inbuffer[Feed, bytesreceived], bytestoreceive, MaxInt);

      if (FHTTP.LastError <> 0) and (not Terminated) then
      begin
        Terminate;
        NotifyForm(0);
      end;

      Dec(BytesUntilMeta, bytestoreceive);
      Inc(bytesreceived, bytestoreceive);
    end;
  until bytesreceived >= BUFFPACKET;

  if Feed = BUFFPACKETCOUNT - 1 then Feed := 0 else Inc(Feed);

  Inc(BuffFilled);
end;

constructor THTTPSTREAM.Create;
begin
  inherited Create(True);
  FHTTP := TTCPBlockSocket.Create;
  Priority := tpTimeCritical;

  Cursor := 0;
  Feed := 0;
  BuffFilled := 0;
  MetaInterval := 0;
  MetaBitrate := 0;
end;

destructor THTTPSTREAM.Destroy;
begin
  // flag terminated := True
  Terminate;
  // now close socket
  FHTTP.CloseSocket;
  // destroy the thread
  inherited;
  // now we can free the Socket
  FHTTP.Free;
end;

procedure THTTPSTREAM.Execute;
begin
  repeat
    //# if we have a free buffer lets fill it
    if BuffFilled < BUFFPACKETCOUNT then
      UpdateBuffer()
    else
      Sleep(64);
  until Terminated;
end;

function THTTPSTREAM.Open(const url: string): LongBool;
var
  host, port, icyheader: string;
  response: string;
begin
  Result := False;
  ParseHeader(url, host, port, icyheader);
  FHTTP.CloseSocket;
  if proxy_enabled then
  begin
    FHTTP.HTTPTunnelTimeout := 5000;
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
      begin
        BytesUntilMeta := MetaInterval;
        Resume;
        Result := True;
      end;
    -1:
      Result := Open(response);
  end;

end;

procedure THTTPSTREAM.GetMetaInfo(out Atitle: string; out Aquality: Cardinal);
begin
  Atitle := MetaTitle;
  Aquality := MetaBitrate;
end;

function THTTPSTREAM.GetBuffer(): PByte;
begin
  Result := @inbuffer[Cursor];
end;

procedure THTTPSTREAM.NextBuffer();
begin
  if Cursor = BUFFPACKETCOUNT - 1 then Cursor := 0 else Inc(Cursor);

  Dec(BuffFilled);
end;

end.

