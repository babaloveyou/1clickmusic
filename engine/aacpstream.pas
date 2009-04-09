unit aacpstream;

interface

uses
  SysUtils,
  Windows,
  Classes,
  neaacdec,
  DSoutput,
  httpstream;

const
  inBufferlen = BUFFPACKET * 2;
  outBufferlen = 32 * 1024; // NOT SAFE, BUT ENOUGH
type
  TAACP = class(TRadioPlayer)
  private
    Fhandle: PNeAACDecHandle;
    inBuffer: array[0..inBufferlen - 1] of Byte;
    inPos, inFilled: Cardinal;
    outBuffer: array[0..outBufferlen - 1] of Byte;
    outFilled: Cardinal;
    fStream: THTTPSTREAM;
  protected
    procedure updatebuffer(const offset: Cardinal); override;
    procedure initbuffer;
    procedure prebuffer; override;
  public
    function GetProgress(): Integer; override;
    //function GetTrack(): string; override;
    procedure GetInfo(out Atitle, Aquality: string); override;
    function Open(const url: string): LongBool; override;
    constructor Create();
    destructor Destroy; override;
  end;

implementation

uses
  utils;

{ TMP3 }


function sync(buffer: PByte; len: Integer): Integer;
var
  i: Integer;
begin
  i := 0;
  Dec(len, 4);
  while (i < len) do
  begin
    // buffer : PByteArray
    //if ((buffer[i] = $FF) and ((buffer[i+1] and $F6) = $F0)) or
    // ((buffer[i] = Ord('A')) and (buffer[i+1] = Ord('D')) and (buffer[i+2] = Ord('I')) and (buffer[i+3] = Ord('F'))) then
    if ((buffer^ = $FF) and ((PByte(Cardinal(buffer) + 1)^ and $F6) = $F0)) or
      (PInteger(buffer)^ = (Ord('A') shl 24) or (Ord('D') shl 16) or (Ord('I') shl 8) or Ord('F')) then
    begin
      Result := i;
      Exit;
    end;
    Inc(i);
    Inc(buffer);
  end;
  Result := -1;
end;

{function sync(buffer : PByteArray; len : Integer): Integer;
var
  i : Integer;
begin
  i := 0;
  while (i <= len - 4) do
  begin
    if ((buffer[i] = $FF) and ((buffer[i+1] and $F6) = $F0)) or
     ((buffer[i] = Ord('A')) and (buffer[i+1] = Ord('D')) and (buffer[i+2] = Ord('I')) and (buffer[i+3] = Ord('F'))) then
    begin
      Result := i;
      Exit;
    end;
    Inc(i);
  end;
  Result := -1;
end;}

function TAACP.GetProgress(): Integer;
begin
  Result := fStream.BuffFilled;
end;

procedure TAACP.GetInfo(out Atitle, Aquality: string);
begin
  fStream.GetMetaInfo(Atitle, Aquality);
  Aquality := Aquality + 'k aac+';
end;

destructor TAACP.Destroy;
begin
  inherited;
  if Fhandle <> nil then
    NeAACDecClose(Fhandle);
  fStream.Free;
end;

procedure TAACP.initbuffer;
var
  r, i: Integer;
  c: Byte;
begin
  if Fhandle <> nil then
    NeAACDecClose(Fhandle);

  Fhandle := NeAACDecOpen();

  r := -1;
  repeat
    if inFilled = 0 then
    begin
      i := sync(fStream.GetBuffer(), BUFFPACKET);
      if i = -1 then
      begin
        fStream.NextBuffer();
        Continue;
      end;
      inFilled := BUFFPACKET - i;
      inPos := 0;
      Move(Pointer(Integer(fStream.GetBuffer()) + i)^, inBuffer, inFilled);
      fStream.NextBuffer();
    end
    else
    begin
      if inPos = 0 then
      begin
        Inc(inPos);
        Dec(inFilled);
      end;
      Move(inBuffer[inPos], inBuffer, inFilled);
      inPos := 0;
      i := sync(@inBuffer, inFilled);
      if i = -1 then
      begin
        inFilled := 0;
        Continue;
      end;
      Inc(inPos, i);
      Dec(inFilled, i);
    end;

    r := NeAACDecInit(Fhandle, @inBuffer[inPos], inFilled, @fRate, @c);
    if r < 0 then
    begin
      inFilled := 0;
      Continue;
    end;  
    Dec(inFilled, r);
    Inc(inPos, r);
  until (r >= 0) or (FStream.BuffFilled = 0);
  if (r < 0) then
    RaiseError('discovering audio format');

  FChannels := c;

  FHalfbuffersize := fDS.InitializeBuffer(Frate, Fchannels);
end;

function TAACP.Open(const url: string): LongBool;
begin
  Result := FStream.open(url);
  if Result then
  begin
    Status := rsPrebuffering;
    Resume;
  end;
end;

procedure TAACP.prebuffer;
begin
  // WAIT TO PREBUFFER!
  repeat
    Sleep(64);
    if Terminated then Exit;
  until FStream.BuffFilled > BUFFPRE;
  initbuffer();
end;

procedure TAACP.updatebuffer(const offset: Cardinal);
var
  frameinf: TNeAACDecFrameInfo;
  outbuf, dsbuf: PByteArray;
  dssize, Decoded, done: Cardinal;
begin
  DSERROR(fDS.SoundBuffer.Lock(offset, fHalfbuffersize, @dsbuf, @dssize, nil, nil, 0), 'locking buffer');

  Decoded := 0;
  if outFilled <> 0 then
  begin
    Move(outBuffer, dsbuf^, outFilled);
    Inc(Decoded, outFilled);
    outFilled := 0;
  end;  

  repeat
    if Terminated then Exit;
    // Repeat code that fills the DS buffer
    if (FStream.BuffFilled > 0) then
    begin
      if inFilled < BUFFPACKET then
      begin
        if inFilled <> 0 then
        begin
          Move(inBuffer[inPos], inBuffer, inFilled);
          inPos := 0;
        end;
        Move(FStream.GetBuffer()^, inBuffer[inFilled], BUFFPACKET);
        FStream.NextBuffer();
        Inc(inFilled, BUFFPACKET);
      end;

      outbuf := NeAACDecDecode(Fhandle, @frameinf, @inBuffer[inPos], inFilled);
      Dec(inFilled, frameinf.bytesconsumed);
      Inc(inPos, frameinf.bytesconsumed);
      if frameinf.error <> 0 then
      begin
        fDS.Stop;
        initbuffer();
        fDS.Play;
        Exit;
      end;

      if frameinf.samples = 0 then Continue;
      done := 2 * frameinf.samples;
      if Decoded + done > dssize then
      begin
        done := dssize - Decoded;
        Move(outbuf^, dsbuf[Decoded], done);
        outFilled := (2 * frameinf.samples) - done;
        Move(outbuf[done], outBuffer, outFilled);
      end
      else
      begin
        Move(outbuf^, dsbuf[Decoded], done);
        Inc(Decoded, done);
      end;
    end
    else
    begin
      Status := rsRecovering;
      fDS.Stop;
      repeat
        Sleep(64);
        if Terminated then Exit;
      until FStream.BuffFilled > BUFFRESTORE;
      fDS.Play;
      Status := rsPlaying;
    end;
  until (Decoded >= dssize);

  fDS.SoundBuffer.Unlock(dsbuf, dssize, nil, 0)

end;

constructor TAACP.Create();
begin
  inherited;
  fStream := THTTPSTREAM.Create('audio/aacp');
end;

end.

