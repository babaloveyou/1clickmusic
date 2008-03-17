unit httpstream;

interface
uses
  SysUtils, Classes, Windows, blcksock;

const // CONFIGURATION
  BUFFTOTALSIZE = 100000;
  BUFFSIZE = 1000;
  BUFFCOUNT = BUFFTOTALSIZE div BUFFSIZE;

  BUFFMIN = 10; // PERCENT
  BUFFRESTORE = 50; // PERCENT
  BUFFPRE = (BUFFCOUNT div 3) * 2; // N. of BUFF = 75%

type
  THTTPSTREAM = class(TThread)
  private
    Fbytesread: Cardinal; // used to manage icy data
    FHTTP: TTCPBlockSocket;
    procedure UpdateBuffer;
    procedure ParseMetaData(meta: string);
    function ParseMetaHeader(var meta: string): Integer;
  protected
    procedure Execute; override;
  public
    bufffilled: Integer;
    inbuffer: array[0..BUFFCOUNT] of array[1..BUFFSIZE] of Byte;
    Cursor, Feed: Cardinal;
    MetaInterval, MetaBitrate: Cardinal;
    MetaTitle: string;
  public
    procedure PreBuffer;
    function open(const url: string): Boolean;
    procedure close;
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

procedure ParseURL(url: string; out host, port, icyheader: string);
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

function THTTPSTREAM.ParseMetaHeader(var meta: string): Integer;
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
    if (Pos('302', MetaData[0]) > 0) or
      (Pos('301', MetaData[0]) > 0) or
      (Pos('303', MetaData[0]) > 0) then
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

  meta := MetaTitle;

end;

{ THTTPSTREAM }

// let's do magic =D

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
      FHTTP.RecvBufferEx(@inbuffer[Feed, byteswrited + 1], bytestowrite, MaxInt);
      Inc(Fbytesread, bytestowrite);
      Inc(byteswrited, bytestowrite);
    end;
  end;
  if feed = BUFFCOUNT - 1 then feed := 0 else Inc(feed);
  Inc(bufffilled);
end;

procedure THTTPSTREAM.close;
begin
  FHTTP.CloseSocket;
end;

constructor THTTPSTREAM.Create;
begin
  inherited Create(True);
  FHTTP := TTCPBlockSocket.Create;
  Priority := tpTimeCritical;
end;

destructor THTTPSTREAM.Destroy;
begin
  close;
  Terminate;
  FHTTP.Free;
  inherited;
end;

procedure THTTPSTREAM.Execute;
var
  cs: TRTLCriticalSection;
begin
  InitializeCriticalSection(cs);
  repeat
    EnterCriticalSection(cs);
    if Cursor <> Feed then
      UpdateBuffer;
    LeaveCriticalSection(cs);
    sleep(5);
  until Terminated;
  DeleteCriticalSection(cs);
end;

function THTTPSTREAM.open(const url: string): Boolean;
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
  bufffilled := 0;
  MetaInterval := 0;
  Fbytesread := 0;

  icy := FHTTP.RecvTerminated(1000, #13#10#13#10);

  case ParseMetaHeader(icy) of
    1:
      Result := True;
    0:
      Result := False;
    -1:
      Result := open(icy);
  end;

  if not Result then writeFile('ERROR.txt',icy);
end;

procedure THTTPSTREAM.PreBuffer;
var
  i: Integer;
begin
  for i := 0 to BUFFPRE do
    UpdateBuffer;
end;

end.

