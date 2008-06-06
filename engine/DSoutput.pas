unit DSoutput;

interface

uses
  SysUtils,
  Classes,
  Windows,
  MMSystem,
  _DirectSound;

{$MINENUMSIZE 4}

type
  TDSoutput = class
  private
    FDS: IDirectSound;
    FPrimary: IDirectSoundBuffer;
    FSecondary: IDirectSoundBuffer;
    Fvolume: Integer;
    function GetPlayCursorPos: Cardinal;
  public
    property PlayCursorPos: Cardinal read GetPlayCursorPos;
    property SoundBuffer: IDirectSoundBuffer read FSecondary write FSecondary;
    function Volume(const value: Integer): Cardinal;
    procedure Play;
    procedure Stop;
    function InitializeBuffer(const Arate, Achannels: Cardinal): Cardinal;
    constructor Create;
    destructor Destroy; override;
  end;

  // ESQUELETO PARA OS PLAYERS

type
  TRadioStatus = (rsStoped, rsPrebuffering, rsPlaying, rsRecovering);

type
  TRadioPlayer = class(TThread)
  private
    FDevice: TDSoutput;
  protected
    Frate: Integer;
    Fchannels: Integer;
    Fencoding: Integer;
    Fhalfbuffersize: Cardinal;
    procedure updatebuffer(const offset: Cardinal); virtual; abstract;
    procedure initbuffer; virtual; abstract;
    procedure initdecoder; virtual; abstract;
    procedure prebuffer; virtual; abstract;
    procedure Execute; override;
  public
    Status: TRadioStatus;
    property DS: TDSoutput read FDevice write FDevice;
    procedure GetPlayInfo(out Atitle: string; out Aquality, ABuffPercentage: Cardinal); virtual; abstract;
    function Open(const url: string): Boolean; virtual; abstract;
    constructor Create(ADevice: TDSoutput);
    destructor Destroy; override;
  end;

procedure DSERROR(const value: HResult; const Error: string);

implementation

uses
  main, utils;

{ TDSoutput }


procedure DSERROR(const value: HResult; const Error: string);
var
  ErrorStr: string;
begin
  if value = DS_OK then Exit;
  case Value of
    DSERR_ALLOCATED: ErrorStr := 'DSERR_ALLOCATED';
    DSERR_ALREADYINITIALIZED: ErrorStr := 'DSERR_ALREADYINITIALIZED';
    DSERR_BADFORMAT: ErrorStr := 'DSERR_BADFORMAT';
    DSERR_BUFFERLOST: ErrorStr := 'DSERR_BUFFERLOST';
    DSERR_CONTROLUNAVAIL: ErrorStr := 'DSERR_CONTROLUNAVAIL';
    DSERR_GENERIC: ErrorStr := 'DSERR_GENERIC';
    DSERR_INVALIDCALL: ErrorStr := 'DSERR_INVALIDCALL';
    DSERR_INVALIDPARAM: ErrorStr := 'DSERR_INVALIDPARAM';
    DSERR_NOAGGREGATION: ErrorStr := 'DSERR_NOAGGREGATION';
    DSERR_NODRIVER: ErrorStr := 'DSERR_NODRIVER';
    DSERR_NOINTERFACE: ErrorStr := 'DSERR_NOINTERFACE';
    DSERR_OTHERAPPHASPRIO: ErrorStr := 'DSERR_OTHERAPPHASPRIO';
    DSERR_OUTOFMEMORY: ErrorStr := 'DSERR_OUTOFMEMORY';
    DSERR_PRIOLEVELNEEDED: ErrorStr := 'DSERR_PRIOLEVELNEEDED';
    DSERR_UNINITIALIZED: ErrorStr := 'DSERR_UNINITIALIZED';
    DSERR_UNSUPPORTED: ErrorStr := 'DSERR_UNSUPPORTED';
  else ErrorStr := 'DSERR_UNKNOW';
  end;
  RaiseError('DIRECTSOUND ERROR, [' + ErrorStr + '] : ' + Error);
end;

constructor TDSoutput.Create;
var
  Fpwfm: TWAVEFORMATEX;
  Fpdesc: TDSBUFFERDESC;
begin
  DSERROR(DirectSoundCreate(nil, FDS, nil), 'Creating DS device');
  DSERROR(FDS.SetCooperativeLevel(appwinHANDLE, DSSCL_PRIORITY), 'Setting the cooperative level');

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

function TDSoutput.Volume(const value: Integer): Cardinal;
begin
  Result := Fvolume;
  if FSecondary = nil then Exit;

  if value >= 100 then
  begin
    Fvolume := DSBVOLUME_MAX;
    Result := 100;
  end
  else
    if value <= 0 then
    begin
      Fvolume := DSBVOLUME_MIN;
      Result := 0;
    end
    else
    begin
      Fvolume := Round(
        ((100 - value) * DSBVOLUME_MIN) / 500
        );
      Result := value;
    end;

  FSecondary.SetVolume(Fvolume);
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
  Status := rsStoped;
  initdecoder();
end;

destructor TRadioPlayer.Destroy;
begin
  Status := rsStoped;
  DS.Stop;
  Terminate;
  inherited;
  DS.SoundBuffer := nil;
end;

procedure TRadioPlayer.Execute;
var
  section, lastsection: Cardinal;
begin
  prebuffer();
  if Terminated then Exit;

  initbuffer();
  updatebuffer(0);
  lastsection := 0;
  Resume;
  DS.Play;
  Status := rsPlaying;
  while not Terminated do
  begin
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
  end;
end;

end.

