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
    procedure Play; override;
    destructor Destroy; override;
  end;

implementation

uses
  utils;

{ TMP3 }

procedure TMP3.GetPlayInfo(out Atitle: string; out Aquality, ABuffPercentage: Cardinal);
begin
  ABuffPercentage := FStream.GetBuffPercentage;
  FStream.GetMetaInfo(Atitle,Aquality);
end;

destructor TMP3.Destroy;
begin
  DS.Stop;
  Terminate;
  inherited;
  mpg123_close(Fhandle);
  mpg123_exit;
  FStream.Free;
end;

procedure TMP3.initbuffer;
begin
  FStream.Cursor := 0;
  while (FStream.Cursor < 3) and (Fchannels = 0) do
  begin
    mpg123_decode(Fhandle, FStream.ReadBuffer ,BUFFSIZE, nil, 0, nil);
    mpg123_getformat(Fhandle, @Frate, @Fchannels, @Fencoding);
  end;
  if Fchannels = 0 then
    RaiseError('ERRO, tentando descobrir o formato do audio');
  mpg123_format_none(Fhandle);
  mpg123_format(Fhandle, Frate, Fchannels, Fencoding);
  Fbuffersize := DS.InitializeBuffer(Frate, Fchannels);
end;

procedure TMP3.initdecoder;
begin
{$IFDEF _LOG_}Log('initing MPG DECODER'); {$ENDIF}
  if mpg123_init <> MPG123_OK then
    RaiseError('ERRO, criando instancia do decodificador MPEG');
  Fhandle := mpg123_new('mmx', nil);
  if Fhandle = nil then
    RaiseError('ERRO, inicializando o decodificador MPEG');
  if mpg123_open_feed(Fhandle) <> MPG123_OK then
    RaiseError('ERRO, abrindo feed de audio');
{$IFDEF _LOG_}Log('inited MPG DECODER'); {$ENDIF}

{$IFDEF _LOG_}Log('creating httpfeeder'); {$ENDIF}
  FStream := THTTPSTREAM.Create;
{$IFDEF _LOG_}Log('created httpfeeder'); {$ENDIF}
end;

function TMP3.Open(const url: string): Boolean;
begin
{$IFDEF _LOG_}Log('Opening Stream'); {$ENDIF}
  Result := FStream.open(url);
  if Result then
  begin
    Status := rsPrebuffering;
{$IFDEF _LOG_}Log('Prebuffering Stream'); {$ENDIF}
    FStream.PreBuffer();
  end;
{$IFDEF _LOG_}Log('Stream Opened'); {$ENDIF}
end;

procedure TMP3.Play;
begin
{$IFDEF _LOG_}Log('Play mp3'); {$ENDIF}
  initbuffer();

  Flastsection := MaxInt;
  updatebuffer();

{$IFDEF _LOG_}Log('resuming Threads'); {$ENDIF}
  Resume;
  FStream.Resume;
  DS.Play;
  Status := rsPlaying;
{$IFDEF _LOG_}Log(Format('Play mp3 returned .%s .%s', [BoolToStr(not Suspended, True), BoolToStr(not FStream.Suspended, True)])); {$ENDIF}
end;

procedure TMP3.updatebuffer;
var
  buffer, bufferPos: PByte;
  Size, SizeDecoded, TotalDecoded: Cardinal;
  section: Cardinal;
  r: Integer;
begin
{$IFDEF _LOG_}Log('cursor. called'); r := MaxInt; {$ENDIF}
  if DS.PlayCursorPos > Fbuffersize then
    section := 0
  else
    section := Fbuffersize;

  if section = Flastsection then Exit;
{$IFDEF _LOG_}Log(Format('updatebuffer trigered %d, locking buffer', [section])); {$ENDIF}

  DSERROR(DS.SoundBuffer.Lock(section, Fbuffersize, @buffer, @Size, nil, nil, 0), 'ERRO, Locking buffer');
{$IFDEF _LOG_}Log(Format('buffer locked, %p %d', [buffer, Size])); {$ENDIF}
  if (FStream.GetBuffPercentage > BUFFMIN) then
  begin
    SizeDecoded := 0;
    TotalDecoded := 0;
    bufferPos := buffer;
    repeat
      r := mpg123_decode(Fhandle,FStream.ReadBuffer , BUFFSIZE, bufferPos, Size - TotalDecoded, @SizeDecoded);
      Inc(bufferPos, SizeDecoded);
      Inc(TotalDecoded, SizeDecoded);
{$IFDEF _LOG_}Log(Format('decoder returned, %d', [r])); {$ENDIF}
    until r <> MPG123_NEED_MORE;
  end
  else
  begin
    Status := rsRecovering;
    DS.Stop;
    repeat
      Sleep(50);
    until (FStream.GetBuffPercentage > BUFFRESTORE) or Terminated;
    if not Terminated then
      DS.Play;
    Status := rsPlaying;
  end;

  DS.SoundBuffer.Unlock(buffer, Size, nil, 0);

  Flastsection := section;
{$IFDEF _LOG_}Log(Format('cursor. %d', [r])); {$ENDIF}
end;

end.

