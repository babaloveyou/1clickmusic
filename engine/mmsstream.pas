unit mmsstream;

interface

uses
  SysUtils,
  Classes,
  Windows,
  DSoutput,
  wmfintf,
  libwma1;

type
  TMMS = class(TRadioPlayer)
  private
    fhandle: wma_async_reader;
    fUrl: string;
  protected
    procedure updatebuffer(const offset: Cardinal); override;
    procedure initbuffer;
    procedure prebuffer; override;
  public
    function GetProgress(): Integer; override;
    procedure GetInfo(out Atitle, Aquality: string); override;
    function Open(const url: string): LongBool; override;
    constructor Create();
    destructor Destroy; override;
  end;

implementation

uses
  utils;

{ TMP3 }

destructor TMMS.Destroy;
var
  i: Integer;
  SI: PSampleInfo;
begin
  inherited;
  with fhandle do
  begin
    if reader = nil then Exit;

    reader.Stop;
    reader.Close;
    reader := nil;

    WMReaderCallback := nil;

    Event.SetEvent;
    Event.Free;
    CriticalSection.Release;
    CriticalSection.Free;

    if BlockList <> nil then
    begin
      for i := 0 to BlockList.Count - 1 do
      begin
        SI := BlockList.Items[i];
        Freemem(SI.Data);
        Freemem(SI);
      end;
      BlockList.Free;
    end;
  end;
end;

procedure TMMS.initbuffer;
begin
  Fhalfbuffersize := fDS.InitializeBuffer(Frate, Fchannels);
end;

procedure TMMS.prebuffer;
begin
  // WAIT TO PREBUFFER!
  repeat
    Sleep(64);
    if fhandle.status = WMT_CLOSED then
    begin
      Terminate;
      Status := rsStoped;
      Exit;
    end;
    if Terminated then Exit;
  until fhandle.BlockList.Count >= 4;
  InitBuffer();
end;

procedure TMMS.updatebuffer(const offset: Cardinal);
var
  dsbuf: PByteArray;
  outbuf: Pointer;
  dssize, Decoded, done: Cardinal;
begin
  DSERROR(fDS.SoundBuffer.Lock(offset, Fhalfbuffersize, @dsbuf, @dssize, nil, nil, 0), 'ERRO, locking buffer');

  Decoded := 0;
  repeat
    if Terminated then Exit;
    if (fhandle.BlockList.Count > 0) then
    begin
      done := dssize - Decoded;
      lwma_async_reader_get_data(fHandle, outbuf, done);
      if done = 0 then Continue;
      Move(outbuf^, dsbuf[Decoded], done);
      Inc(Decoded, done);
    end
    else
    begin
      Status := rsRecovering;
      fDS.Stop;
      repeat
        Sleep(50);
        if Terminated then Exit;
      until fhandle.BlockList.Count >= 2;
      fDS.Play;
      Status := rsPlaying;
    end;
  until (Decoded >= dssize) or (Terminated);

  fDS.SoundBuffer.Unlock(dsbuf, dssize, nil, 0);
end;

function TMMS.Open(const url: string): LongBool;
begin
  {if proxy_enabled then
    lwma_async_reader_set_proxy(fhandle, 'http', proxy_host, StrToInt(proxy_port));}
  fUrl := url;
  lwma_async_reader_open(fhandle, url);
  Result := Fhandle.has_audio;
  if Result then
  begin
    Fchannels := Fhandle.channels;
    Frate := Fhandle.SampleRate;
    Status := rsPrebuffering;
    Resume;
  end;
end;

procedure TMMS.GetInfo(out Atitle, Aquality: string);
var
  Title: WideString;
begin
  Aquality := IntToStr(Fhandle.Bitrate div 1000) + 'k wma';
  lwma_async_reader_get_title(FHandle, Title);
  Atitle := Title;
end;

function TMMS.GetProgress(): Integer;
begin
  Result := 0;
end;

constructor TMMS.Create();
begin
  inherited;
  if not WMInited then
    RaiseError('WMP engine not found');
  lwma_async_reader_init(Fhandle);
  if Fhandle.reader = nil then
    RaiseError('could not initialize WMP engine');
end;

end.

