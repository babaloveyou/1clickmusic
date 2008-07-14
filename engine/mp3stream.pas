unit mp3stream;

interface

uses
  SysUtils,
  Windows,
  Classes,
  mpg123,
  DSoutput,
  httpstream;

type
  TMP3 = class(TRadioPlayer)
  private
    Fhandle: Pmpg123_handle;
    FStream: THTTPSTREAM;
  protected
    procedure updatebuffer(const offset: Cardinal); override;
    procedure initdecoder; override;
    procedure initbuffer; override;
    procedure prebuffer; override;
  public
    procedure GetProgress(out ABuffPercentage: Cardinal); override;
    procedure GetInfo(out Atitle: string; out Aquality: Cardinal); override;
    function Open(const url: string): Boolean; override;
    destructor Destroy; override;
  end;

implementation

uses
  utils;

{ TMP3 }

procedure TMP3.GetProgress(out ABuffPercentage: Cardinal);
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
  mpg123_close(Fhandle);
  FStream.Free;
end;

procedure TMP3.initbuffer;
var
  r: Integer;
begin
  mpg123_close(Fhandle);
  mpg123_open_feed(Fhandle);

  repeat
    r := mpg123_decode(Fhandle, FStream.GetBuffer(), BUFFSIZE, nil, 0, nil);
    FStream.NextBuffer();
  until (r = MPG123_NEW_FORMAT) or (FStream.BuffFilled < 50);

  mpg123_getformat(Fhandle, @Frate, @Fchannels, @Fencoding);
  if Fchannels = 0 then
    RaiseError('discovering audio format');

  Fhalfbuffersize := DS.InitializeBuffer(Frate, Fchannels);
end;

procedure TMP3.initdecoder;
begin
  FStream := THTTPSTREAM.Create;
  Fhandle := mpg123_new('i586', nil); //i586
  if Fhandle = nil then
    RaiseError('creating MPEG decoder');
end;

function TMP3.Open(const url: string): Boolean;
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
end;

procedure TMP3.updatebuffer(const offset: Cardinal);
var
  buffer, bufferPos: PByte;
  Size, SizeDecoded, TotalDecoded: Cardinal;
  r: Integer;
begin
  DSERROR(DS.SoundBuffer.Lock(offset, Fhalfbuffersize, @buffer, @Size, nil, nil, 0), 'ERRO, locking buffer');

  SizeDecoded := 0;
  TotalDecoded := 0;
  bufferPos := buffer;
  r := MPG123_NEED_MORE;

  repeat
  // Repeat code that fills the DS buffer
    if (FStream.BuffFilled > 0) then
    begin
      r := mpg123_decode(Fhandle, FStream.GetBuffer(), BUFFSIZE, bufferPos, Size - TotalDecoded, @SizeDecoded);
      FStream.NextBuffer();
      Inc(bufferPos, SizeDecoded);
      Inc(TotalDecoded, SizeDecoded);
    end
    else
    begin
      Status := rsRecovering;
      DS.Stop;
      repeat
        Sleep(99);
        if Terminated then Exit;
      until FStream.BuffFilled > BUFFRESTORE;
      DS.Play;
      Status := rsPlaying;
    end;
  until (r <> MPG123_NEED_MORE) or (Terminated);


  if (r = MPG123_OK) then
    DS.SoundBuffer.Unlock(buffer, Size, nil, 0)
  else
    if (r = MPG123_DONE) then
    // Some streams give us MPG123_DONE
    // after initial messages, lets try re-open
    begin
      initbuffer();
      DS.Play;
    end;

end;

initialization
  if mpg123_init() <> MPG123_OK then
    RaiseError('initing MPEG decoder');

finalization
  mpg123_exit();

end.

