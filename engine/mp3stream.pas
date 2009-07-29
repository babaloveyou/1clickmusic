unit mp3stream;

interface

uses
  SysUtils,
  Windows,
  Classes,
  mpg123,
  DSoutput,
  httpstream,
  main,
  utils;

type
  TMP3 = class(TRadioPlayer)
  private
    fHandle: Pmpg123_handle;
    fStream: THTTPSTREAM;
  protected
    procedure updatebuffer(const offset: Cardinal); override;
    function initbuffer: LongBool;
    function prebuffer: LongBool; override;
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
  fStream.Free;
  mpg123_delete(fHandle);
end;

function TMP3.initbuffer: LongBool;
var
  r: Integer;
begin
  Result := False;
  mpg123_open_feed(fHandle);
  repeat
    r := mpg123_decode(fHandle, fStream.GetBuffer(), BUFFPACKET, nil, 0, nil);
    fStream.NextBuffer();
  until (r = MPG123_NEW_FORMAT) or (fStream.BuffFilled = 0);

  mpg123_getformat(Fhandle, @Frate, @Fchannels, nil);
  
  if Fchannels = 0 then
  begin
    //RaiseError('discovering audio format', False);
    Exit;
  end;

  fHalfbuffersize := fDS.InitializeBuffer(fRate, fChannels);
  Result := True;
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

function TMP3.prebuffer: LongBool;
begin
  Result := False;
  // WAIT TO PREBUFFER!
  repeat
    Sleep(64);
    if Terminated then Exit;
  until fStream.BuffFilled > BUFFPRE;
  Result := initbuffer();
end;

procedure TMP3.updatebuffer(const offset: Cardinal);
var
  dsbuf: PByteArray;
  dssize, Decoded, done : Cardinal;
  r: Integer;
begin
  DSERROR(fDS.SoundBuffer.Lock(offset, Fhalfbuffersize, @dsbuf, @dssize, nil, nil, 0), 'locking buffer');

  Decoded := 0;
  r := MPG123_NEED_MORE;
  repeat
    if Terminated then Exit;
    // Repeat code that fills the DS buffer
    if (fStream.BuffFilled > 0) then
    begin
      if r = MPG123_NEED_MORE then
      begin
        r := mpg123_decode(Fhandle, fStream.GetBuffer(), BUFFPACKET, @dsbuf[Decoded], dssize - Decoded, @done);
        fStream.NextBuffer();
      end
      else
        r := mpg123_decode(Fhandle, nil, 0, @dsbuf[Decoded], dssize - Decoded, @done);
      Inc(Decoded, done);
    end
    else
    begin
      NotifyForm(NOTIFY_BUFFER, BUFFER_RECOVERING);
      fDS.Stop;
      repeat
        Sleep(64);
        if Terminated then Exit;
      until fStream.BuffFilled > BUFFRESTORE;
      fDS.Play;
      NotifyForm(NOTIFY_BUFFER, BUFFER_OK);
    end;
  until (r <> MPG123_NEED_MORE);


  if (r = MPG123_OK) then
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
  fHandle := mpg123_parnew(nil, nil, nil); //i586 :|
  if Fhandle = nil then
    RaiseError('creating MPEG decoder');
end;

initialization
  mpg123_init();

//finalization
//  mpg123_exit();

end.

