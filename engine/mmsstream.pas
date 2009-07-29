unit mmsstream;

interface

uses
  SysUtils,
  Classes,
  Windows,
  DSoutput,
  wmfintf,
  libwma1,
  main,
  utils;

type
  TMMS = class(TRadioPlayer)
  private
    fHandle: wma_async_reader;
    fUrl: string;
  protected
    procedure updatebuffer(const offset: Cardinal); override;
    procedure initbuffer;
     function prebuffer: LongBool; override;
  public
    function GetProgress(): Integer; override;
    procedure GetInfo(out Atitle, Aquality: string); override;
    function Open(const url: string): LongBool; override;
    constructor Create();
    destructor Destroy; override;
  end;

implementation

{ TMP3 }

destructor TMMS.Destroy;
var
  i: Integer;
  SI: PSampleInfo;
begin
  inherited;
  with fHandle do
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

    for i := 0 to BlockList.Count - 1 do
    begin
      SI := BlockList.Items[i];
      Freemem(SI.Data);
      Freemem(SI);
    end;
    BlockList.Free;
  end;
end;

procedure TMMS.initbuffer;
begin
  Fhalfbuffersize := fDS.InitializeBuffer(fRate, fChannels);
end;

function TMMS.prebuffer: LongBool;
begin
  Result := False;
  // WAIT TO PREBUFFER!
  repeat
    Sleep(64);
    if (fHandle.status = WMT_CLOSED) or Terminated then
      Exit;
  until GetProgress() >= 110;
  InitBuffer();
  Result := True;
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
    if (fHandle.BlockList.Count > 0) then
    begin
      done := dssize - Decoded;
      lwma_async_reader_get_data(fHandle, outbuf, done);
      if done = 0 then Continue;
      Move(outbuf^, dsbuf[Decoded], done);
      Inc(Decoded, done);
    end
    else
    begin
      NotifyForm(NOTIFY_BUFFER, BUFFER_RECOVERING);
      fDS.Stop;
      repeat
        Sleep(50);
        if Terminated then Exit;
      until GetProgress() >= 70;
      fDS.Play;
      NotifyForm(NOTIFY_BUFFER, BUFFER_OK);
    end;
  until (Decoded >= dssize) or (Terminated);

  fDS.SoundBuffer.Unlock(dsbuf, dssize, nil, 0);
end;

function TMMS.Open(const url: string): LongBool;
begin
  fUrl := url;
  lwma_async_reader_open(fHandle, url);
  Result := fHandle.has_audio;
  if Result then
  begin
    Fchannels := fHandle.channels;
    Frate := fHandle.SampleRate;
  end
  else
  begin
    Terminate;
    Resume;
  end;  
end;

procedure TMMS.GetInfo(out Atitle, Aquality: string);
var
  Title: WideString;
begin
  Aquality := IntToStr(fHandle.Bitrate div 1000) + 'k wma';
  lwma_async_reader_get_title(fHandle, Title);
  Atitle := Title;
end;

function TMMS.GetProgress(): Integer;
const
  FULLBUFFERSECONDS = 3;
var
  bytespersec : Single;
begin
  with fHandle do
    bytespersec := ((BitsPerSample div 8) * SampleRate * channels);
  if bytespersec = 0 then
    Result := 0
  else
    Result := Round((100 / FULLBUFFERSECONDS) * (fHandle.BytesBuffered / bytespersec));
end;

constructor TMMS.Create();
begin
  inherited;
  if not WMInited then
    RaiseError('WMP engine not found');
  lwma_async_reader_init(fHandle);
  if fHandle.reader = nil then
    RaiseError('WMP Error'); 
end;

end.

