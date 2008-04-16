unit httpstream;

interface
uses
  SysUtils,
  Classes,
  Windows,
  blcksock,
  _DirectSound;

const // CONFIGURATION
  BUFFSIZE = 768;
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
    property GetBuffPercentage: Cardinal read BuffFilled;
    //function GetBuffPercentage: Cardinal;
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

  if Pos('200', MetaData[0]) > 0 then
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
  bytesreceived, bytestoreceive: Cardinal;
begin
  bytesreceived := 0;
  while bytesreceived < BUFFSIZE do
  begin
    if (BytesUntilMeta = 0) then
    begin // METADATA IS HERE =D
      BytesUntilMeta := MetaInterval;
      metalength := FHTTP.RecvByte(MaxInt) * 16;
      if metalength = 0 then Continue;
      ParseMetaData(FHTTP.RecvBufferStr(metalength, MaxInt));
    end
    else
    begin
      bytestoreceive := BUFFSIZE - bytesreceived;
      if bytestoreceive > BytesUntilMeta then
        bytestoreceive := BytesUntilMeta;

      FHTTP.RecvBufferEx(@inbuffer[Feed,bytesreceived], bytestoreceive, MaxInt);

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

  icy := FHTTP.RecvTerminated(1000, #13#10#13#10);

  case ParseMetaHeader(icy, MetaInterval, MetaBitrate) of
    1:
      Result := True;
    0:
      Exit;
    -1:
      Result := open(icy);
  end;

  Cursor := MaxInt; // para evitar que bloqueie
  Feed := 0;
  BuffFilled := 0;
  BytesUntilMeta := MetaInterval;
  
end;

procedure THTTPSTREAM.PreBuffer;
begin
  while BuffFilled < BUFFPRE do
    UpdateBuffer;
end;

procedure THTTPSTREAM.GetMetaInfo(out Atitle: string; out Aquality: Cardinal);
begin
  Atitle := MetaTitle;
  Aquality := MetaBitrate;
end;

function THTTPSTREAM.GetBuffer: Pointer;
begin
  Result := @inbuffer[Cursor,0];
end;

procedure THTTPSTREAM.NextBuffer;
begin
  if Cursor = BUFFCOUNT - 1 then Cursor := 0 else Inc(Cursor);
  Dec(BuffFilled);
end;  

end.

