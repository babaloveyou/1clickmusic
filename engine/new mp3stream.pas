unit mp3stream;

interface

uses
  SysUtils,
  Windows,
  Classes,
  mpglib,
  DSoutput,
  httpstream;

type
  TMP3 = class(TRadioPlayer)
  private
    Fhandle: TMp3Handle;
    FStream: THTTPSTREAM;
  protected
    procedure updatebuffer(const offset: Cardinal); override;
    procedure initbuffer;
    procedure prebuffer; override;
  public
    function GetProgress(): Integer; override;
    procedure GetInfo(out Atitle: string; out Aquality: Cardinal); override;
    function Open(const url: string): LongBool; override;
    constructor Create(ADevice: TDSoutput);
    destructor Destroy; override;
  end;

implementation

uses
  utils;

{ TMP3 }

function TMP3.GetProgress(): Integer;
begin
  Result := FStream.BuffFilled;
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
  r := MP3_ERROR;
  repeat
    offset := FindFrame(FStream.GetBuffer(), BUFFPACKET);
    //Debug('FindFrame = %d', [offset]);
    if offset <> -1 then
    begin
      InitMp3(FHandle);
      done := 0;
      r := DecodeMp3(FHandle,
        Pointer(LongInt(FStream.GetBuffer()) + offset),
        BUFFPACKET - offset,
        nil,
        0,
        done);

      if r = MP3_ERROR then
        ExitMp3(Fhandle);

      //Debug('DecodeMp3 on offset %d = lay %d, framesize = %d', [offset, Fhandle.lay, Fhandle.framesize]);
    end;

    FStream.NextBuffer();
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
    Sleep(64);
    if Terminated then Exit;
  until FStream.BuffFilled > BUFFPRE;
  initbuffer();
end;

procedure TMP3.updatebuffer(const offset: Cardinal);
var
  outbuf: PByteArray;
  outsize : Cardinal;
  Decoded, done: Integer;
  r: TMp3Result;
begin
  DSERROR(DS.SoundBuffer.Lock(offset, Fhalfbuffersize, @outbuf, @outsize, nil, nil, 0), 'ERRO, locking buffer');

  Decoded := 0;

  r := MP3_OK;
  repeat
    // Repeat code that fills the DS buffer
    if (FStream.BuffFilled > 0) then
    begin
      done := 0;
      if r = MP3_OK then
      begin
        r := DecodeMp3(Fhandle, nil, 0, @outbuf[Decoded], outsize - Decoded, done);
      end
      else //MP3_NEED_MORE
      begin
        r := DecodeMp3(Fhandle, FStream.GetBuffer(), BUFFPACKET, @outbuf[Decoded], outsize - Decoded, done);
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

      Inc(Decoded, done);

    end
    else
    begin
      Status := rsRecovering;
      DS.Stop();
      repeat
        Sleep(64);
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

