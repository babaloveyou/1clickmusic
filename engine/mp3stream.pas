unit mp3stream;

interface

uses
  SysUtils, Windows, Classes, DSoutput, mpg123, httpstream, _DirectSound;

type
  TMP3 = class(TRadioPlayer)
  private
    Fhandle: Pmpg123_handle;
    FStream: THTTPSTREAM;
  protected
    procedure updatebuffer; override;
    procedure initdecoder; override;
    procedure initbuffer; override;
    procedure Execute; override;
  public
    procedure GetPlayInfo(var Atitle: string; var Aquality: Cardinal); override;
    function GetBufferPercentage: Integer; override;
    function open(const url: string): Boolean; override;
    procedure Play; override;
    destructor Destroy; override;
  end;

implementation

{ TMP3 }

procedure TMP3.GetPlayInfo(var Atitle: string; var Aquality: Cardinal);
begin
  Atitle := FStream.MetaTitle;
  Aquality := FStream.MetaBitrate;
end;

function TMP3.GetBufferPercentage: Integer;
begin
  Result := Round(FStream.bufffilled / BUFFCOUNT * 100);
end;

destructor TMP3.Destroy;
begin
  DS.Stop;
  Terminate;
  inherited;
  FStream.Free;
  mpg123_close(Fhandle);
  mpg123_exit;
end;

procedure TMP3.Execute;
var
  cs: TRTLCriticalSection;
begin
  InitializeCriticalSection(cs);
  repeat
    EnterCriticalSection(cs);
    UpdateBuffer;
    LeaveCriticalSection(cs);
    sleep(50);
  until Terminated;
  DeleteCriticalSection(cs);
end;

procedure TMP3.initbuffer;
begin
  mpg123_decode(Fhandle, @FStream.inbuffer[0], BUFFSIZE, nil, 0, nil);
  mpg123_getformat(Fhandle, @Frate, @Fchannels, @Fencoding);
  FStream.Cursor := 1;
  if Fchannels = 0 then
  begin
    mpg123_decode(Fhandle, @FStream.inbuffer[1], BUFFSIZE, nil, 0, nil);
    mpg123_getformat(Fhandle, @Frate, @Fchannels, @Fencoding);
    FStream.Cursor := 2;
    if Fchannels = 0 then
      raise Exception.Create('ERRO, tentando descobrir o formato do audio');
  end;
  mpg123_format_none(Fhandle);
  mpg123_format(Fhandle, Frate, Fchannels, Fencoding);

  Fbuffersize := DS.InitializeBuffer(Frate, Fchannels);
end;

procedure TMP3.initdecoder;
begin
  if mpg123_init <> 0 then
    raise Exception.Create('ERRO, criando instancia do decodificador MPEG');

  Fhandle := mpg123_new(nil, nil);
  if Fhandle = nil then
    raise Exception.Create('ERRO, inicializando o decodificador MPEG');

  mpg123_open_feed(Fhandle);

  FStream := THTTPSTREAM.Create;
end;

function TMP3.open(const url: string): Boolean;
begin
  Result := FStream.open(url);
end;

procedure TMP3.Play;
begin
  initbuffer();

  Flastsection := MaxInt;
  DS.SoundBuffer.SetCurrentPosition((Fbuffersize div 2) *3);
  updatebuffer();
  DS.SoundBuffer.SetCurrentPosition(0);

  Resume;
  FStream.Resume;
  DS.Play;
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
    section := 1;

  if section = Flastsection then Exit;

  DS.SoundBuffer.Lock(section * Fbuffersize, Fbuffersize, @buffer, @Size, nil, nil, 0);

  if (GetBufferPercentage > BUFFMIN) then
  begin
    SizeDecoded := 0;
    TotalDecoded := 0;
    bufferPos := buffer;

    r := -10;
    while r = -10 do
    begin
      r := mpg123_decode(Fhandle, @FStream.inbuffer[FStream.Cursor], BUFFSIZE, bufferPos, Size - TotalDecoded, @SizeDecoded);
      Inc(bufferPos, SizeDecoded);
      Inc(TotalDecoded, SizeDecoded);
      if FStream.Cursor = BUFFCOUNT - 1 then FStream.Cursor := 0 else Inc(FStream.Cursor);
      Dec(FStream.bufffilled);
    end;
  end
  else
    FillChar(buffer^, Size, 0);

  DS.SoundBuffer.Unlock(buffer, Size, nil, 0);

  Flastsection := section;
end;

end.

