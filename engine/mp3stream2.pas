unit mp3stream2;

interface

uses
  SysUtils,
  Windows,
  Classes,
  MMSystem,
  msacm,
  DSoutput,
  httpstream,
  main,
  utils;


  // BEGIN OF ACM MP3 STUFF //
type
  PMPEGLAYER3WAVEFORMAT = ^TMPEGLAYER3WAVEFORMAT;
  TMPEGLAYER3WAVEFORMAT = packed record
    wfx: tWAVEFORMATEX;
    wID: WORD;
    fdwFlags: DWORD;
    nBlockSize: WORD;
    nFramesPerBlock: WORD;
    nCodecDelay: WORD;
  end;

const
  WAVE_FORMAT_MPEG = $50;
  WAVE_FORMAT_MPEGLAYER3 = $55;

  ACM_MPEG_LAYER1 = 1;
  ACM_MPEG_LAYER2 = 2;
  ACM_MPEG_LAYER3 = 4;

  ACM_MPEG_STEREO = 1;
  ACM_MPEG_JOINTSTEREO = 2;
  ACM_MPEG_DUALCHANNEL = 4;
  ACM_MPEG_SINGLECHANNEL = 8;

  ACM_MPEG_ID_MPEG1 = $10;
  MPEGLAYER3_ID_MPEG = 1;

  MPEGLAYER3_FLAG_PADDING_ON = 1;
  MPEGLAYER3_FLAG_PADDING_OFF = 2;
   // END OF ACM MP3 STUFF //

const
  inBufferlen = BUFFPACKET * 2;
  outBufferlen = 32 * 1024; // NOT SAFE, BUT ENOUGH
type
  TMP3 = class(TRadioPlayer)
  private
    fHandle: HACMSTREAM;
    fStreamHeader: TACMSTREAMHEADER;
    inBuffer: array[0..inBufferlen - 1] of Byte;
    inPos, inFilled: Cardinal;
    outBuffer: array[0..outBufferlen - 1] of Byte;
    outPos, outFilled: Cardinal;
    fStream: THTTPSTREAM;
  protected
    function FillinFormat(var inFormat: TMPEGLAYER3WAVEFORMAT): LongBool;
    procedure updatebuffer(const offset: Cardinal); override;
    procedure initbuffer;
    function prebuffer(): LongBool; override;
  public
    function GetProgress(): Integer; override;
    //function GetTrack(): string; override;
    procedure GetInfo(out Atitle, Aquality: string); override;
    function Open(const url: string): LongBool; override;
    constructor Create();
    destructor Destroy; override;
  end;

implementation

{ TMP3 }

function TMP3.GetProgress(): Integer;
begin
  Result := fStream.BuffFilled;
end;

procedure TMP3.GetInfo(out Atitle, Aquality: string);
begin
  fStream.GetMetaInfo(Atitle, Aquality);
  Aquality := Aquality + 'k mp3';
end;

destructor TMP3.Destroy;
begin
  inherited;
  fStreamHeader.cbSrcLength := inBufferlen;
  acmStreamUnprepareHeader(fHandle, fStreamHeader, 0);
  acmStreamClose(fHandle, 0);
  fStream.Free;
end;

{function swap32(n: Cardinal): Cardinal; assembler;
asm
  bswap eax;
end;}

function check(n: LongInt): LongBool;
begin
  Result := False;
  if (n and $FFE00000) <> $FFE00000 then Exit;
  if ((n shr 10) and $3) = $3 then Exit;
  if ((n shr 12) and $F) = $F then Exit;
  if ((n shr 12) and $F) = $0 then Exit;
  if (4 - ((n shr 17) and 3)) <> 3 then Exit; // only layer 3, nothing else
  Result := True
end;

function TMP3.FillinFormat(var inFormat: TMPEGLAYER3WAVEFORMAT): LongBool;
const
  SamplingFreq: array[0..8] of Integer = (44100, 48000, 32000, 22050, 24000, 16000, 11025, 12000, 8000);
  BitRates: array[0..15] of integer = (0, 32, 40, 48, 56, 64, 80, 96, 112, 128, 160, 192, 224, 256, 320, 0);
var
  i: Integer;
  frame: Cardinal;
  buf: PByteArray;
begin
  frame := 0;
  Result := False;
  while (fStream.BuffFilled > 0) and (not Result) do
  begin
    buf := PByteArray(fStream.GetBuffer());
    FStream.NextBuffer();
    for i := 0 to BUFFPACKET - 1 - 4 do
    begin
      //frame := swap32(PDWORD(LongInt(buf) + i)^);
      frame := PDWORD(LongInt(buf) + i)^;
      asm
        bswap esi
      end;

      if check(frame) then
      begin
        Result := True;
        Break;
      end;
    end;
  end;
  if not Result then Exit; // NOT FOUND A VALID FRAME

  with inFormat do
  begin
    with wfx do
    begin
      wFormatTag := WAVE_FORMAT_MPEGLAYER3;
      cbSize := SizeOf(TMPEGLAYER3WAVEFORMAT) - SizeOf(TWAVEFORMATEX);
      //3 means mono, else it is stereo
      if (frame shr 6) and 3 = 3 then nChannels := 1 else nChannels := 2;

      if (frame and (1 shl 20)) <> 0 then
      begin
        if (frame and (1 shl 19)) = 0 then
          nSamplesPerSec := SamplingFreq[(frame shr 10) and 3 + 3]
        else
          nSamplesPerSec := SamplingFreq[(frame shr 10) and 3];
      end
      else
        nSamplesPerSec := SamplingFreq[(frame shr 10) and 3 + 6];

      nAvgBytesPerSec := (BitRates[(frame shr 12) and $F] * 1000) shr 3;
      nBlockAlign := 1;
      wBitsPerSample := 0;

      if nSamplesPerSec >= 32000 then
        nBlockSize := 1152 * nAvgBytesPerSec div nSamplesPerSec
      else
        nBlockSize := 576 * nAvgBytesPerSec div nSamplesPerSec;
    end;
    wID := MPEGLAYER3_ID_MPEG;
    nCodecDelay := 0;//$0571;
    nFramesPerBlock := 1;
    if ((frame shr 9) and 1) <> 0 then
      fdwFlags := MPEGLAYER3_FLAG_PADDING_ON
    else
      fdwFlags := MPEGLAYER3_FLAG_PADDING_OFF;
  end;

end;

procedure TMP3.initbuffer;
var
  inFormat: TMPEGLAYER3WAVEFORMAT;
  outFormat: TWaveFormatEx;
  r: Cardinal;
begin
  fStreamHeader.cbSrcLength := inBufferlen;
  acmStreamUnprepareHeader(fHandle, fStreamHeader, 0);
  acmStreamClose(fHandle, 0);

  if not FillinFormat(inFormat) then RaiseError('lol');

  with outFormat do
  begin
    wFormatTag := WAVE_FORMAT_PCM;
    nChannels := inFormat.wfx.nChannels;
    wBitsPerSample := 16;
    nSamplesPerSec := inFormat.wfx.nSamplesPerSec;
    nBlockAlign := nChannels * 2;
    nAvgBytesPerSec := nSamplesPerSec * nBlockAlign;
    cbSize := 0;
  end;

  r := acmStreamOpen(@fHandle, 0, inFormat.wfx, outFormat, nil, 0, 0, 0);
  if r <> 0 then RaiseError(IntToStr(r));

  with fStreamHeader do
  begin
    cbStruct := SizeOf(TACMSTREAMHEADER);
    pbSrc := @inBuffer;
    cbSrcLength := inBufferlen;
    pbDst := @outBuffer;
    cbDstLength := outBufferlen;
  end;

  acmStreamPrepareHeader(fHandle, fStreamHeader, 0);
  if r <> 0 then RaiseError(IntToStr(r));

  {acmStreamSize(fHandle,inBufferlen,r, ACM_STREAMSIZEF_SOURCE);
  Writeln(r);}

  Fhalfbuffersize := fDS.InitializeBuffer(outFormat.nSamplesPerSec, outFormat.nChannels);
end;

function TMP3.Open(const url: string): LongBool;
begin
  Result := fStream.open(url);
  if not Result then
  begin
    Terminate;
    Resume;
  end;  
end;

function TMP3.prebuffer(): LongBool;
begin
  Result := False;
  // WAIT TO PREBUFFER!
  repeat
    Sleep(64);
    if Terminated then Exit;
  until FStream.BuffFilled > BUFFPRE;
  initbuffer();
  Result := True;
end;

procedure TMP3.updatebuffer(const offset: Cardinal);
var
  dsbuf: PByteArray;
  r, done, dssize, Decoded: Cardinal;
begin
  DSERROR(fDS.SoundBuffer.Lock(offset, Fhalfbuffersize, @dsbuf, @dssize, nil, nil, 0), 'locking buffer');

  r := 0;
  Decoded := 0;

  if outFilled <> 0 then
  begin
    {if outFilled < dssize then
    begin}
      Move(outBuffer[outPos], dsbuf[Decoded], outFilled);
      Inc(Decoded, outFilled);
      outPos := 0;
      outFilled := 0;
    {end
    else
    begin
      Move(outBuffer[outPos], dsbuf[Decoded], dssize);
      Inc(Decoded, dssize);
      Inc(outPos, dssize);
      Dec(outFilled, dssize);
    end;}  
  end;

  //while decoded < dssize do
  //begin
  repeat
    if Terminated then Exit;
    // Repeat code that fills the DS buffer
    if (FStream.BuffFilled > 0) then
    begin
      if inFilled <> 0 then // buffer have some data, we have to put it at the begin
      begin
        Move(inBuffer[inPos], inBuffer, inFilled);
        inPos := 0;
      end;
      //while (inBufferLen - inFilled >= BUFFPACKET) and (fStream.BuffFilled <> 0) do // buffer needs more data
      if inFilled < BUFFPACKET then
      begin
        Move(fStream.GetBuffer()^, inBuffer[inFilled], BUFFPACKET);
        FStream.NextBuffer();
        Inc(inFilled, BUFFPACKET);
      end;

      fStreamHeader.cbSrcLength := inFilled;
      r := acmStreamConvert(fHandle, fStreamHeader, ACM_STREAMCONVERTF_BLOCKALIGN);
      if r <> 0 then Break;
      Dec(inFilled, fStreamHeader.cbSrcLengthUsed);

      done := fStreamHeader.cbDstLengthUsed;
      if Decoded + done > dssize then
        done := dssize - Decoded;
      Move(outBuffer, dsbuf[Decoded], done);
      Inc(Decoded, done);

      outFilled := fStreamHeader.cbDstLengthUsed - done;
      outPos := done;
    end
    else
    begin
      NotifyForm(NOTIFY_BUFFER, BUFFER_RECOVERING);
      fDS.Stop;
      repeat
        Sleep(64);
        if Terminated then Exit;
      until FStream.BuffFilled > BUFFRESTORE;
      fDS.Play;
      NotifyForm(NOTIFY_BUFFER, BUFFER_OK);
    end;
  //end;
  until (Decoded >= dssize);

  if (r = 0) then
    fDS.SoundBuffer.Unlock(dsbuf, dssize, nil, 0)
  else
  begin
    fDS.Stop;
    initbuffer();
    fDS.Play;
  end;

end;

constructor TMP3.Create();
begin
  inherited;
  fStream := THTTPSTREAM.Create('audio/mpeg');
end;

end.

