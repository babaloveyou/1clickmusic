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
    procedure initbuffer;
    procedure prebuffer; override;
  public
    function GetProgress(): Integer; override;
    //function GetTrack(): string; override;
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
  mpg123_delete(Fhandle);
end;

procedure TMP3.initbuffer;
var
  r: Integer;
begin
  mpg123_open_feed(Fhandle);

  repeat
    r := mpg123_decode(Fhandle, FStream.GetBuffer(), BUFFPACKET, nil, 0, nil);
    FStream.NextBuffer();
  until (r = MPG123_NEW_FORMAT) or (FStream.BuffFilled = 0);

  mpg123_getformat(Fhandle, @Frate, @Fchannels, @Fencoding);
  if Fchannels = 0 then
    RaiseError('discovering audio format');

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
  r, outsize, Decoded, done: Integer;
begin
  DSERROR(DS.SoundBuffer.Lock(offset, Fhalfbuffersize, @outbuf, @outsize, nil, nil, 0), 'locking buffer');

  Decoded := 0;
  r := MPG123_NEED_MORE;
  repeat
    if Terminated then Exit;
    // Repeat code that fills the DS buffer
    if (FStream.BuffFilled > 0) then
    begin
      r := mpg123_decode(Fhandle, FStream.GetBuffer(), BUFFPACKET, @outbuf[Decoded], outsize - Decoded, @done);
      FStream.NextBuffer();
      Inc(Decoded, done);
    end
    else
    begin
      Status := rsRecovering;
      DS.Stop;
      repeat
        Sleep(64);
        if Terminated then Exit;
      until FStream.BuffFilled > BUFFRESTORE;
      DS.Play;
      Status := rsPlaying;
    end;
  until (r <> MPG123_NEED_MORE);

  if (r = MPG123_OK) then
    DS.SoundBuffer.Unlock(outbuf, outsize, nil, 0)
  else
  begin
    DS.Stop;
    initbuffer();
    DS.Play;
  end;

end;

constructor TMP3.Create(ADevice: TDSoutput);
begin
  inherited;
  FStream := THTTPSTREAM.Create;
  Fhandle := mpg123_new(nil, nil); //i586 :|
  if Fhandle = nil then
    RaiseError('creating MPEG decoder');
end;

initialization
  if mpg123_init() <> MPG123_OK then
    RaiseError('initing MPEG decoder');

//finalization
//  mpg123_exit();

end.

