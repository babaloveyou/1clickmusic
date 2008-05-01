unit mp3stream;

interface

uses
  SysUtils,
  Windows,
  Classes,
  DSoutput,
  mpg123,
  httpstream,
  _DirectSound;

type
  TMP3 = class(TRadioPlayer)
  private
    Fhandle: Pmpg123_handle;
    FStream: THTTPSTREAM;
  protected
    procedure updatebuffer; override;
    procedure initdecoder; override;
    procedure initbuffer; override;
  public
    procedure GetPlayInfo(out Atitle: string; out Aquality, ABuffPercentage: Cardinal); override;
    function Open(const url: string): Boolean; override;
    procedure StartPlay; override;
    destructor Destroy; override;
  end;

implementation

uses
  utils;

{ TMP3 }

procedure TMP3.GetPlayInfo(out Atitle: string; out Aquality, ABuffPercentage: Cardinal);
begin
  ABuffPercentage := FStream.BuffFilled;
  FStream.GetMetaInfo(Atitle, Aquality);
end;

destructor TMP3.Destroy;
begin
  inherited;
  mpg123_close(Fhandle);
  mpg123_exit;
  FStream.Free;
end;

procedure TMP3.initbuffer;
begin
  repeat
    mpg123_decode(Fhandle, FStream.GetBuffer, BUFFSIZE, nil, 0, nil);
    FStream.NextBuffer;
    mpg123_getformat(Fhandle, @Frate, @Fchannels, @Fencoding);
  until (Fchannels <> 0) or (FStream.BuffFilled < 50);

  if Fchannels = 0 then
    RaiseError('ERRO, tentando descobrir o formato do audio');
  {$IFDEF LOG}
  Log('buffers remaining '+IntToStr(FStream.BuffFilled));
  {$ENDIF}
  mpg123_format_none(Fhandle);
  mpg123_format(Fhandle, Frate, Fchannels, Fencoding);

  Fbuffersize := DS.InitializeBuffer(Frate, Fchannels);
end;

procedure TMP3.initdecoder;
begin
  if mpg123_init <> MPG123_OK then
    RaiseError('ERRO, criando instancia do decodificador MPEG');
  Fhandle := mpg123_new('mmx', nil);
  if Fhandle = nil then
    RaiseError('ERRO, inicializando o decodificador MPEG');
  mpg123_open_feed(Fhandle);
  FStream := THTTPSTREAM.Create;
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

procedure TMP3.StartPlay;
begin
  // WAIT TO PREBUFFER!
  repeat
    Sleep(50);
    if Terminated then Exit;
  until FStream.BuffFilled > BUFFPRE;
  FStream.Cursor := 0;
  initbuffer();

  updatebuffer();

  Resume;
  DS.Play;
  Status := rsPlaying;
end;

procedure TMP3.updatebuffer;
var
  buffer, bufferPos: PByte;
  Size, SizeDecoded, TotalDecoded: Cardinal;
  section: Cardinal;
  r: Integer;
begin
  if DS.PlayCursorPos > Fbuffersize then
    section := 0
  else
    section := Fbuffersize;

  if section = Flastsection then Exit;
  {$IFDEF LOG}
  Log('lock->buffer');
  {$ENDIF}
  DS.SoundBuffer.Lock(section, Fbuffersize, @buffer, @Size, nil, nil, 0);

  if (FStream.BuffFilled > BUFFMIN) then
  begin
    {$IFDEF LOG}
    Log('filling->buffer ' + IntToStr(Integer(buffer^)) + ' ' + IntToStr(Integer(Pointer(Integer(buffer)+300)^)));
    {$ENDIF}
    SizeDecoded := 0;
    TotalDecoded := 0;
    bufferPos := buffer;
    repeat
      {$IFDEF LOG}
      Log('decoding-> ' + IntToStr(Integer(FStream.GetBuffer)));
      {$ENDIF}
      r := mpg123_decode(Fhandle, FStream.GetBuffer, BUFFSIZE, bufferPos, Size - TotalDecoded, @SizeDecoded);
      FStream.NextBuffer;
      {$IFDEF LOG}
      Log('decoded-> ' + IntToStr(SizeDecoded) + ' ' + IntToStr(r));
      {$ENDIF}
      Inc(bufferPos, SizeDecoded);
      Inc(TotalDecoded, SizeDecoded);
    until r <> MPG123_NEED_MORE;
  end
  else
  begin
    {$IFDEF LOG}
    Log('recovering');
    {$ENDIF}
    Status := rsRecovering;
    DS.Stop;
    repeat
      Sleep(50);
      if Terminated then Exit;
    until FStream.BuffFilled > BUFFRESTORE;
    DS.Play;
    Status := rsPlaying;
  end;
  {$IFDEF LOG}
  Log('lock->buffer');
  {$ENDIF}

  DS.SoundBuffer.Unlock(buffer, Size, nil, 0);

  Flastsection := section;
end;

end.

