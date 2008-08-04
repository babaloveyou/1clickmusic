unit DSoutput;

interface

uses
  SysUtils,
  Classes,
  Windows,
  Messages,
  MMSystem,
  _DirectSound;

{$MINENUMSIZE 4}

type
  TDSoutput = class
  private
    FDS: IDirectSound;
    FPrimary: IDirectSoundBuffer;
    FSecondary: IDirectSoundBuffer;
    Fvolume: Cardinal;
    function GetPlayCursorPos: Cardinal;
  public
    property PlayCursorPos: Cardinal read GetPlayCursorPos;
    property SoundBuffer: IDirectSoundBuffer read FSecondary write FSecondary;
    function Volume(value: Integer): Cardinal;
    procedure Play;
    procedure Stop;
    function InitializeBuffer(const Arate, Achannels: Cardinal): Cardinal;
    constructor Create(const WndHandle: HWND);
    destructor Destroy; override;
  end;

type
  TRadioStatus = (rsStoped, rsPrebuffering, rsPlaying, rsRecovering);

type
  TRadioPlayer = class(TThread)
  private
    FDevice: TDSoutput;
    procedure SetStatus(const Value: TRadioStatus);
  protected
    Frate: Integer;
    Fchannels: Integer;
    Fencoding: Integer;
    Fhalfbuffersize: Cardinal;
    FStatus: TRadioStatus;
    procedure updatebuffer(const offset: Cardinal); virtual; abstract;
    procedure initbuffer; virtual; abstract;
    procedure initdecoder; virtual; abstract;
    procedure prebuffer; virtual; abstract;
    procedure Execute; override;
  public
    property Status : TRadioStatus read FStatus write SetStatus;
    property DS: TDSoutput read FDevice write FDevice;
    procedure GetProgress(out ABuffPercentage : Cardinal); virtual; abstract;
    procedure GetInfo(out Atitle: string; out Aquality: Cardinal); virtual; abstract;
    function Open(const url: string): LongBool; virtual; abstract;
    constructor Create(ADevice: TDSoutput);
    destructor Destroy; override;
  end;

procedure DSERROR(const value: HResult; const Error: string);

implementation

uses
  utils, main;

{ TDSoutput }


procedure DSERROR(const value: HResult; const Error: string);
begin
  if value <> DS_OK then
    RaiseError('DIRECTSOUND, [' + IntToStr(value) + '] : ' + Error);
end;

constructor TDSoutput.Create(const WndHandle: HWND);
var
  Fpwfm: TWAVEFORMATEX;
  Fpdesc: TDSBUFFERDESC;
begin
  Fvolume := 100;

  DSERROR(DirectSoundCreate(nil, FDS, nil), 'Creating DS device');
  DSERROR(FDS.SetCooperativeLevel(WndHandle, DSSCL_PRIORITY), 'Setting the cooperative level');

  FillChar(Fpdesc, SizeOf(TDSBUFFERDESC), 0);
  with Fpdesc do
  begin
    dwSize := SizeOf(TDSBUFFERDESC);
    dwFlags := DSBCAPS_PRIMARYBUFFER;
    lpwfxFormat := nil;
    dwBufferBytes := 0;
  end;

  DSERROR(FDS.CreateSoundBuffer(Fpdesc, Fprimary, nil), 'Creating Primary buffer');

  FillChar(Fpwfm, SizeOf(TWAVEFORMATEX), 0);
  with Fpwfm do
  begin
    wFormatTag := WAVE_FORMAT_PCM;
    nChannels := 2;
    nSamplesPerSec := 44100;
    nBlockAlign := 4;
    wBitsPerSample := 16;
    cbSize := 0;
    nAvgBytesPerSec := 44100 * 4;
  end;

  DSERROR(FPrimary.SetFormat(@Fpwfm), 'Changing Primary buffer format');
end;

destructor TDSoutput.Destroy;
begin
  FPrimary := nil;
  FSecondary := nil;
  FDS := nil;
  inherited;
end;

function TDSoutput.GetPlayCursorPos: Cardinal;
begin
  if FSecondary <> nil then
    FSecondary.GetCurrentPosition(@Result, nil);
end;

function TDSoutput.Volume(value: Integer): Cardinal;
begin
  Result := Fvolume;
  if FSecondary = nil then Exit;

  if value >= 100 then
  begin
    Result := 100;
    value := DSBVOLUME_MAX;
  end
  else
    if value <= 0 then
    begin
      Result := 0;
      value := DSBVOLUME_MIN;
    end
    else
    begin
      Result := value;
      value := Round(
        ((100 - value) * DSBVOLUME_MIN) / 500
        );

    end;

  FSecondary.SetVolume(value);
end;

function TDSoutput.InitializeBuffer(const Arate, Achannels: Cardinal): Cardinal;
var
  Fswfm: TWAVEFORMATEX;
  Fsdesc: TDSBUFFERDESC;
begin
  FSecondary := nil;

  FillChar(Fswfm, SizeOf(TWAVEFORMATEX), 0);
  with Fswfm do
  begin
    wFormatTag := WAVE_FORMAT_PCM;
    nChannels := Achannels;
    wBitsPerSample := 16;
    nSamplesPerSec := Arate;
    nBlockAlign := Achannels * 2;
    nAvgBytesPerSec := Arate * nBlockAlign;
  end;

  // set up the buffer
  FillChar(Fsdesc, SizeOf(TDSBUFFERDESC), 0);
  with Fsdesc do
  begin
    dwSize := SizeOf(TDSBUFFERDESC);
    dwFlags :=
      DSBCAPS_GETCURRENTPOSITION2 or
      DSBCAPS_CTRLVOLUME or
      DSBCAPS_GLOBALFOCUS;
    lpwfxFormat := @Fswfm;
    dwBufferBytes := 64 * 1024;
  end;

  DSERROR(FDS.CreateSoundBuffer(Fsdesc, Fsecondary, nil), 'ERRO, criando o buffer secundario');

  FSecondary.SetVolume(Fvolume);

  Result := Fsdesc.dwBufferBytes div 2;
end;

procedure TDSoutput.Play;
begin
  if FSecondary <> nil then
    FSecondary.Play(0, 0, DSBPLAY_LOOPING);
end;

procedure TDSoutput.Stop;
begin
  if FSecondary <> nil then
    FSecondary.Stop;
end;

{ TRadioPlayer }

constructor TRadioPlayer.Create(ADevice: TDSoutput);
begin
  // CREATE TRHEAD, SUSPENDED
  FDevice := ADevice;
  inherited Create(True);
  Priority := tpTimeCritical;
  FStatus := rsStoped;
  initdecoder();
end;

destructor TRadioPlayer.Destroy;
begin
  FStatus := rsStoped;
  DS.Stop;
  inherited;
  DS.SoundBuffer := nil;
end;

procedure TRadioPlayer.Execute;
var
  section, lastsection: Cardinal;
begin
  prebuffer();
  // If terminated while prebuffering Exit
  if Terminated then Exit;

  initbuffer();
  // Fill buffer at offset 0
  updatebuffer(0);
  lastsection := 0;
  DS.Play;
  Status := rsPlaying;
  repeat
    if DS.GetPlayCursorPos > Fhalfbuffersize then
      section := 0
    else
      section := Fhalfbuffersize;

    if section <> lastsection then
    begin
      UpdateBuffer(section);
      lastsection := section;
    end;
    Sleep(50);
  until Terminated;
end;

procedure TRadioPlayer.SetStatus(const Value: TRadioStatus);
begin
  FStatus := Value;
  NotifyForm(1);
end;

end.

