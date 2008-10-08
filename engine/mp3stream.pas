unit mp3stream;

interface

uses
  SysUtils,
  Windows,
  Classes,
  mpglib,
  DSoutput,
  httpstream;

const
  PCMBUFSIZE = 4608;
  //MP3BUFSIZE = BUFFPACKET;
type
  TMP3 = class(TRadioPlayer)
  private
    pcmbuf: array[0..PCMBUFSIZE - 1] of Byte;
    pcmbufpos, pcmbuffilled: Integer;
    //mp3buf: array[0..MP3BUFSIZE - 1] of Byte;
    Fhandle: TMp3Handle;
    FStream: THTTPSTREAM;
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
  utils, main;

{ TMP3 }

procedure TMP3.GetProgress(out ABuffPercentage: Integer);
begin
  ABuffPercentage := FStream.BuffFilled;
end;

procedure TMP3.GetInfo(out Atitle: string; out Aquality: Cardinal);
begin
  FStream.GetMetaInfo(Atitle, Aquality);
end;

destructor TMP3.Destroy;
begin
  inherited;
  FStream.Free;
  ExitMp3(Fhandle);
end;

procedure TMP3.initbuffer;
const
  freqs: array[0..8] of Integer = (
    44100, 48000, 32000,
    22050, 24000, 16000,
    11025, 12000, 8000);
var
  offset: Integer;
  done: Integer;
  r: TMp3Result;
begin
  pcmbufpos := 0;
  r := MP3_ERROR;
  offset := 0;
  repeat
    offset := FindFrame(Pointer(LongInt(FStream.GetBuffer()) + offset), BUFFPACKET - offset);
    //Debug('FindFrame = %d', [offset]);
    if offset <> -1 then
    begin
      InitMp3(FHandle);
      done := 0;
      r := DecodeMp3(FHandle,
        Pointer(LongInt(FStream.GetBuffer()) + offset),
        BUFFPACKET - offset,
        @pcmbuf,
        PCMBUFSIZE,
        done);

      if r = MP3_ERROR then
      begin
        ExitMp3(Fhandle);
        if BUFFPACKET - offset > 4  then Continue;
      end;

      pcmbuffilled := done;

      //Debug('DecodeMp3 on offset %d = lay %d, framesize = %d', [offset, Fhandle.lay, Fhandle.framesize]);
    end;

    FStream.NextBuffer();
    offset := 0;
  until (r <> MP3_ERROR) or (Fstream.BuffFilled = 0);

  if r = MP3_ERROR then
    RaiseError('Discovering Audio Format');

  Fchannels := Fhandle.stereo;
  Frate := freqs[Fhandle.sampling_frequency];

  //Debug('DS.InitializeBuffer(%d, %d);', [Frate, Fchannels]);
  Fhalfbuffersize := DS.InitializeBuffer(Frate, Fchannels);
end;

function TMP3.Open(const url: string): LongBool;
begin
  Result := FStream.open(url);
  if Result then
  begin
    Status := rsPrebuffering;
    Resume;
  end;
end;

procedure TMP3.prebuffer;
begin
  // WAIT TO PREBUFFER!
  repeat
    Sleep(50);
    if Terminated then Exit;
  until FStream.BuffFilled > BUFFPRE;
  initbuffer();
end;

procedure TMP3.updatebuffer(const offset: Cardinal);
var
  outbuf: PByteArray;
  outsize, Decoded, done: Integer;
  r: TMp3Result;
begin
  DSERROR(DS.SoundBuffer.Lock(offset, Fhalfbuffersize, @outbuf, @outsize, nil, nil, 0), 'ERRO, locking buffer');

  Decoded := 0;

  // some data is already decoded
  if pcmbuffilled <> 0 then
  begin
    Decoded := pcmbuffilled;
    Move(pcmbuf[pcmbufpos], outbuf^, Decoded);
    pcmbufpos := 0;
    pcmbuffilled := 0;
  end;

  r := MP3_OK;
  repeat
    // Repeat code that fills the DS buffer
    if (FStream.BuffFilled > 0) then
    begin
      done := 0;

      if r = MP3_OK then
        r := DecodeMp3(Fhandle, nil, 0, @pcmbuf, PCMBUFSIZE, done)
      else
      begin // NEED_MORE
        r := DecodeMp3(Fhandle, FStream.GetBuffer(), BUFFPACKET, @pcmbuf, PCMBUFSIZE, done);
        FStream.NextBuffer();
      end;

      if r = MP3_ERROR then
      begin
        DS.Stop();
        ExitMp3(FHandle);
        initbuffer();
        DS.Play();
        Exit;
      end;

      if done = 0 then Continue;
      
      if done + Decoded <= outsize then
        Move(pcmbuf, outbuf[Decoded], done)
      else
      begin
        pcmbufpos := outsize - Decoded;
        pcmbuffilled := done - pcmbufpos;
        Move(pcmbuf, outbuf[Decoded], pcmbufpos);
        done := pcmbufpos;
      end;

      Inc(Decoded, done);

    end
    else
    begin
      Status := rsRecovering;
      DS.Stop();
      repeat
        Sleep(99);
        if Terminated then Exit;
      until FStream.BuffFilled > BUFFRESTORE;
      DS.Play();
      Status := rsPlaying;
    end;
  until (Decoded >= outsize) or (Terminated);

  DS.SoundBuffer.Unlock(outbuf, outsize, nil, 0);
end;

constructor TMP3.Create(ADevice: TDSoutput);
begin
  inherited;
  FStream := THTTPSTREAM.Create;
end;

end.

