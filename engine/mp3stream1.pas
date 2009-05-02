unit mp3stream1;

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
    fHandle: TMp3Handle;
    FStream: THTTPSTREAM;
    //outBuffer: array[0..4608 - 1] of Byte;
    //outPos, outFilled: Integer;
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

function TMP3.GetProgress(): Integer;
begin
  Result := FStream.BuffFilled;
end;

procedure TMP3.GetInfo(out Atitle, Aquality: string);
begin
  FStream.GetMetaInfo(Atitle, Aquality);
  Aquality := Aquality + 'k mp3';
end;

destructor TMP3.Destroy;
begin
  inherited;
  FStream.Free;
  ExitMp3(fHandle);
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
  ExitMp3(fHandle);
  r := MP3_ERROR;
  repeat
    offset := FindFrame(FStream.GetBuffer(), BUFFPACKET);
    if offset <> -1 then
    begin
      InitMp3(fHandle);
      done := 0;
      r := decodeMp3(fHandle,
        @PByteArray(FStream.GetBuffer())[offset],
        BUFFPACKET - offset,
        nil,
        0,
        done);

      if r = MP3_ERROR then
        ExitMp3(fHandle);

      //outFilled := done;

      //Debug('DecodeMp3 on offset %d = lay %d, framesize = %d', [offset, fHandle.lay, fHandle.framesize]);
    end;

    FStream.NextBuffer();
  until (r <> MP3_ERROR) or (Fstream.BuffFilled = 0);

  if r = MP3_ERROR then
    RaiseError('Discovering Audio Format');

  Fchannels := fHandle.stereo;
  Frate := freqs[fHandle.sampling_frequency];

  //Debug('DS.InitializeBuffer(%d, %d);', [Frate, Fchannels]);
  Fhalfbuffersize := fDS.InitializeBuffer(Frate, Fchannels);
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
  inbuf : Pointer;
  dsbuf: PByteArray;
  dssize: Cardinal;
  Decoded: Cardinal;
  done: Integer;
  r: TMp3Result;
begin
  DSERROR(fDS.SoundBuffer.Lock(offset, Fhalfbuffersize, @dsbuf, @dssize, nil, nil, 0), 'ERRO, locking buffer');

  Decoded := 0;
  {if outFilled <> 0 then
  begin
    Move(outBuffer[outPos], dsbuf[0], outFilled);
    Inc(Decoded, outFilled);
    outPos := 0;
    outFilled := 0;
  end;}

  r := MP3_NEED_MORE;
  repeat
    // Repeat code that fills the DS buffer
    if (FStream.BuffFilled > 0) then
    begin
      done := 0;
      {if r = MP3_OK then
      begin
        inbuf := nil;
      end
      else
      begin
        inbuf := FStream.GetBuffer();
        FStream.NextBuffer();
      end;
        
      if dssize - Decoded < SizeOf(outBuffer) then
      begin
        r := decodeMP3(fHandle, inbuf, BUFFPACKET, @outBuffer, SizeOf(outBuffer), done);
        if done < dssize - Decoded then
        begin
          Move(outBuffer, dsbuf[Decoded], done);
        end
        else
        begin
          outPos := dssize - Decoded;
          Move(outBuffer, dsbuf[Decoded], outPos);
          outFilled := done - outPos;
        end;
      end
      else
      begin
        r := decodeMP3(fHandle, inbuf, BUFFPACKET, @dsbuf[Decoded], SizeOf(outBuffer), done);
      end;}


      if r = MP3_OK then
      begin
        r := DecodeMp3(fHandle, nil, 0, @dsbuf[Decoded], dssize - Decoded, done);
      end
      else //MP3_NEED_MORE
      begin
        r := DecodeMp3(fHandle, FStream.GetBuffer(), BUFFPACKET, @dsbuf[Decoded], dssize - Decoded, done);
        FStream.NextBuffer();
      end;

      if r = MP3_ERROR then
      begin
        fDS.Stop();
        initbuffer();
        fDS.Play();
        Exit;
      end;

      Inc(Decoded, done);

    end
    else
    begin
      Status := rsRecovering;
      fDS.Stop();
      repeat
        Sleep(64);
        if Terminated then Exit;
      until FStream.BuffFilled > BUFFRESTORE;
      fDS.Play();
      Status := rsPlaying;
    end;
  until (Decoded >= dssize) or (Terminated);

  fDS.SoundBuffer.Unlock(dsbuf, dssize, nil, 0);
end;

constructor TMP3.Create();
begin
  inherited;
  fStream := THTTPSTREAM.Create('audio/mpeg');
end;

end.

