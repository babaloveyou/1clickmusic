unit httpstream;

interface
uses
  SysUtils,
  Classes,
  Windows,
  blcksock,
  _DirectSound;

const // CONFIGURATION
  BUFFTOTALSIZE = 51200;
  BUFFSIZE = 512;
  BUFFCOUNT = BUFFTOTALSIZE div BUFFSIZE;

  BUFFMIN = 8; // PERCENT
  BUFFRESTORE = 50; // PERCENT
  BUFFPRE = (BUFFCOUNT div 10) * 8; // N. of BUFF = 80%

type
  THTTPSTREAM = class(TThread)
  private
    Fbytesread: Cardinal; // used to manage icy data
    FHTTP: TTCPBlockSocket;
    MetaInterval, MetaBitrate: Cardinal;
    MetaTitle: string;
    BuffFilled: Cardinal;
    inbuffer: array[0..BUFFCOUNT-1] of array[0..BUFFSIZE-1] of Byte;
    procedure UpdateBuffer;
    procedure ParseMetaData(meta: string);
    class function ParseMetaHeader(var meta: string; out MetaInterval, MetaBitrate: Cardinal): Integer;
    class procedure ParseURL(url: string; out host, port, icyheader: string);
  protected
    procedure Execute; override;
  public
    Cursor, Feed: Cardinal;
    //# Return % of buffer that is filled
    function GetBuffPercentage: Cardinal;
    //# Get ShoutCast info
    procedure GetMetaInfo(out Atitle: string; out Aquality: Cardinal);
    //# Read the Buffer
    function GetBuffer:Pointer;
    procedure NextBuffer;
    //# Prebuffer, Open stream
    procedure PreBuffer;
    function Open(const url: string): Boolean;
    constructor Create;
    destructor Destroy; override;
  end;

implementation

uses utils;

procedure SplitValue(const data: string; out field, value: string);
const
  delimiter = ':';
var
  p: Integer;
begin
  p := Pos(delimiter, data);
  if p > 0 then
  begin
    field := Copy(data, 1, p - 1);
    value := Copy(data, p + 1, Length(data) - p)
  end;
end;

class procedure THTTPSTREAM.ParseURL(url: string; out host, port, icyheader: string);
const
  ICYHEADERSTUB =
    'GET %s HTTP/1.0' + #13#10 +
    'Host: %s' + #13#10 +
    'Accept: */*' + #13#10 +
    'User-Agent: 1ClickMusic/1.7.1' + #13#10 +
    'Icy-MetaData: 1' + #13#10 +
    #13#10;
var
  i: Integer;
begin
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

  if Pos('200 OK', MetaData[0]) > 0 then
  begin
    Result := 1;
    for i := 1 to MetaData.Count - 1 do
    begin
      SplitValue(MetaData[i], field, value);

      if field = 'icy-metaint' then MetaInterval := StrToInt(value)
      else if field = 'icy-br' then MetaBitrate := StrToInt(value)
        //else if field='icy-description' then StreamInfo.Desc:=Value
        //else if field='icy-genre' then StreamInfo.Genre:=Value
        //else if field = 'icy-name' then StreamInfo.Name := value
        //else if field='icy-pub' then StreamInfo.Pub:=Value
        //else if field='icy-url' then StreamInfo.URL:=Value
        ;
    end;
    if (MetaInterval = 0) and (MetaBitrate = 0) then
      Result := 0;
  end
  else
    if MultiPos(['302', '303', '301'], MetaData[0]) then
    begin
      Result := -1;
      for i := 1 to MetaData.Count - 1 do
        if Pos('Location:', MetaData[i]) > 0 then
        begin
          Meta := Trim(Copy(MetaData[i], Length('Location:') + 1, Length(MetaData[i])));
          break;
        end;
    end;

  MetaData.Free;
end;

procedure THTTPSTREAM.ParseMetaData(meta: string);
const
  field = 'StreamTitle=''';
  fieldlen = Length(field);
begin
  if meta = '' then Exit;
  Delete(meta, 1, fieldlen);
  MetaTitle := Copy(meta, 1, Pos('''', meta) - 1);
end;

{ THTTPSTREAM }

procedure THTTPSTREAM.UpdateBuffer;
var
  metalength: Byte;
  byteswrited, bytestowrite: Cardinal;
begin
  byteswrited := 0;
  while byteswrited < BUFFSIZE do
  begin
    if (Fbytesread = MetaInterval) then
    begin // METADATA IS HERE =D
      Fbytesread := 0;
      metalength := FHTTP.RecvByte(MaxInt) * 16;
      if metalength = 0 then Continue;
      ParseMetaData(FHTTP.RecvBufferStr(metalength, MaxInt));
    end
    else
    begin
      bytestowrite := BUFFSIZE - byteswrited;
      if bytestowrite > MetaInterval - Fbytesread then
        bytestowrite := MetaInterval - Fbytesread;
      FHTTP.RecvBufferEx(@inbuffer[Feed,byteswrited], bytestowrite, MaxInt);
      Inc(Fbytesread, bytestowrite);
      Inc(byteswrited, bytestowrite);
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
end;

destructor THTTPSTREAM.Destroy;
begin
  FHTTP.CloseSocket;
  Terminate;
  FHTTP.Free;
  inherited;
end;

procedure THTTPSTREAM.Execute;
begin
  repeat
    if Cursor <> Feed then
      UpdateBuffer();
    Sleep(5);
  until Terminated;
end;

function THTTPSTREAM.Open(const url: string): Boolean;
var
  host, port, icyheader: string;
  icy: string;
begin
  Result := False;
  ParseURL(url, host, port, icyheader);
  FHTTP.CloseSocket;
  FHTTP.Connect(host, port);
  FHTTP.SendString(icyheader);

  Cursor := MaxInt; // para evitar que bloqueie
  Feed := 0;
  BuffFilled := 0;
  MetaInterval := 0;
  Fbytesread := 0;

  icy := FHTTP.RecvTerminated(1000, #13#10#13#10);

  case ParseMetaHeader(icy, MetaInterval, MetaBitrate) of
    1:
      Result := True;
    0:
      Result := False;
    -1:
      Result := open(icy);
  end;
end;

procedure THTTPSTREAM.PreBuffer;
begin
  while Feed < BUFFPRE do
    UpdateBuffer;
end;

{procedure THTTPSTREAM.ReadBuffer(const Buffer: Pointer);
begin
  EnterCriticalSection(FCritical);
  CopyMemory(Buffer, @inbuffer[FCursor], BUFFSIZE);
  if FCursor = BUFFCOUNT - 1 then FCursor := 0 else Inc(FCursor);
  Dec(BuffFilled);
  LeaveCriticalSection(FCritical);
end;

procedure THTTPSTREAM.WriteBuffer(const Buffer: Pointer);
begin
  EnterCriticalSection(FCritical);
  CopyMemory(@inbuffer[FFeed], Buffer, BUFFSIZE);
  if FFeed = BUFFCOUNT - 1 then FFeed := 0 else Inc(FFeed);
  Inc(BuffFilled);
  LeaveCriticalSection(FCritical);
end;}

function THTTPSTREAM.GetBuffPercentage: Cardinal;
begin
  Result := BuffFilled;
  //Result := Round((BuffFilled / BUFFCOUNT) * 100);
end;

procedure THTTPSTREAM.GetMetaInfo(out Atitle: string; out Aquality: Cardinal);
begin
  Atitle := MetaTitle;
  Aquality := MetaBitrate;
end;

function THTTPSTREAM.GetBuffer: Pointer;
begin
  Result := @inbuffer[Cursor];
end;

procedure THTTPSTREAM.NextBuffer;
begin
  if Cursor = BUFFCOUNT - 1 then Cursor := 0 else Inc(Cursor);
  Dec(BuffFilled);
end;  

end.

