unit mmsstream;

interface

// THIS ONE DOES NOT NEED HTTPSTREAM

uses SysUtils, Classes, Windows, DSoutput, wmfintf, libwma1;

type
  TMMS = class(TRadioPlayer)
  private
    Fhandle: wma_async_reader;
  protected
    procedure updatebuffer(const offset: Cardinal); override;
    procedure initbuffer;
    procedure prebuffer; override;
  public
    procedure GetProgress(out ABuffPercentage: Integer); override;
    procedure GetInfo(out Atitle: string; out Aquality: Cardinal); override;
    function Open(const url: string): LongBool; override;
    constructor Create(ADevice: TDSoutput);
    destructor Destroy; override;
  end;

implementation

uses
  main, utils;

{ TMP3 }

destructor TMMS.Destroy;
begin
  inherited;
  if Fhandle.reader <> nil then
    lwma_async_reader_free(Fhandle);
end;

procedure TMMS.initbuffer;
begin
  Fhalfbuffersize := DS.InitializeBuffer(Frate, Fchannels);
end;

procedure TMMS.prebuffer;
begin
  // WAIT TO PREBUFFER!
  repeat
    Sleep(50);
    if Terminated then Exit;
  until Fhandle.BlockList.Count >= 6;
  InitBuffer();
end;

procedure TMMS.updatebuffer(const offset: Cardinal);
var
  outBuffer, outBufferPos: PByte;
  inBuffer : Pointer;
  outSize, Decoded, done: Cardinal;
begin
  DSERROR(DS.SoundBuffer.Lock(offset, Fhalfbuffersize, @outBuffer, @outSize, nil, nil, 0), 'ERRO, locking buffer');

  outBufferPos := outBuffer;
  Decoded := 0;

  repeat
    if (Fhandle.BlockList.Count > 0) then
    begin
      done := outSize - Decoded;
      lwma_async_reader_get_data(Fhandle, inBuffer, done);
      if done = 0 then Continue;
      Move(inBuffer^, outBufferPos^, done);
      Inc(outBufferPos, done);
      Inc(Decoded, done);
    end
    else
    begin
      Status := rsRecovering;
      DS.Stop;
      repeat
        Sleep(50);
        if Terminated then Exit;
      until Fhandle.BlockList.Count >= 3;
      DS.Play;
      Status := rsPlaying;
    end;
  until (Decoded >= outSize) or (Terminated);

  DS.SoundBuffer.Unlock(outBuffer, outSize, nil, 0);
end;

function TMMS.Open(const url: string): LongBool;
begin
  if proxy_enabled then
    lwma_async_reader_set_proxy(Fhandle, 'http', proxy_host, StrToInt(proxy_port));
  lwma_async_reader_open(Fhandle, url);
  Result := Fhandle.has_audio;
  if Result then
  begin
    Fchannels := Fhandle.channels;
    Frate := Fhandle.SampleRate;
    Status := rsPrebuffering;
    Resume;
  end;
end;

procedure TMMS.GetInfo(out Atitle: string; out Aquality: Cardinal);
begin
  Aquality := Fhandle.Bitrate div 1000;
end;

procedure TMMS.GetProgress(out ABuffPercentage: Integer);
begin
  ABuffPercentage := 0;
end;

constructor TMMS.Create(ADevice: TDSoutput);
begin
  inherited;
  if not WMInited then
    RaiseError('WMP engine not found');
  lwma_async_reader_init(Fhandle);
  if Fhandle.reader = nil then
    RaiseError('could not initialize WMP engine');
end;

end.

