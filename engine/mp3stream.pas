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
  inherited;
  mpg123_close(Fhandle);
  mpg123_exit;
  FStream.Free;
end;

procedure TMP3.initbuffer;
begin
  while (Fchannels = 0) and (FStream.GetBuffPercentage > 50) do
  begin
    mpg123_decode(Fhandle, FStream.GetBuffer ,BUFFSIZE, nil, 0, nil);
    FStream.NextBuffer;
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
  if mpg123_init <> MPG123_OK then
    RaiseError('ERRO, criando instancia do decodificador MPEG');
  Fhandle := mpg123_new('mmx', nil);
  if Fhandle = nil then
    RaiseError('ERRO, inicializando o decodificador MPEG');
  if mpg123_open_feed(Fhandle) <> MPG123_OK then
    RaiseError('ERRO, abrindo feed de audio');
  FStream := THTTPSTREAM.Create;
end;

function TMP3.Open(const url: string): Boolean;
begin
  Result := FStream.open(url);
  if Result then
  begin
    Status := rsPrebuffering;
    FStream.PreBuffer();
    FStream.Cursor := 0;
  end;
end;

procedure TMP3.Play;
begin
  initbuffer();

  Flastsection := MaxInt;
  updatebuffer();

  Resume;
  FStream.Resume;
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

  DS.SoundBuffer.Lock(section, Fbuffersize, @buffer, @Size, nil, nil, 0);

  if (FStream.GetBuffPercentage > BUFFMIN) then
  begin
    SizeDecoded := 0;
    TotalDecoded := 0;
    bufferPos := buffer;
    repeat
      r := mpg123_decode(Fhandle,FStream.GetBuffer, BUFFSIZE, bufferPos, Size - TotalDecoded, @SizeDecoded);
      FStream.NextBuffer;
      Inc(bufferPos, SizeDecoded);
      Inc(TotalDecoded, SizeDecoded);
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
end;

end.

