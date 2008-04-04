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
    function GetPlayCursorPos: Cardinal;
  public
    property PlayCursorPos: Cardinal read GetPlayCursorPos;
    property SoundBuffer: IDirectSoundBuffer read FSecondary;
    procedure ChangeVolume(const value: Integer);
    procedure GetVolume(out AVolume: Cardinal);
    procedure Play;
    procedure Stop;
    function InitializeBuffer(const Arate, Achannels: Cardinal): Cardinal;
    constructor Create(const wndHandle: HWND);
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
    Fbuffersize: Cardinal;
    Flastsection: Cardinal;
    procedure updatebuffer; virtual; abstract;
    procedure initbuffer; virtual; abstract;
    procedure initdecoder; virtual; abstract;
    procedure Execute; override;
  public
    Status: TRadioStatus;
    property DS: TDSoutput read FDevice write FDevice;
    procedure GetPlayInfo(out Atitle: string; out Aquality, ABuffPercentage: Cardinal); virtual; abstract;
    function open(const url: string): Boolean; virtual; abstract;
    procedure Play; virtual; abstract;
    constructor Create(ADevice: TDSoutput);
    destructor Destroy; override;
  end;

procedure DSERROR(const value: HResult; const Error: string);

implementation

uses
  utils;

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
  else ErrorStr := 'Unrecognized DS Error';
  end;
  RaiseError('DIRECTSOUND ERROR, [' + ErrorStr + '] : ' + Error);
end;


/// GET THE FIRST REAL DEVICE

function DSEnumOutputCallback(lpGuid: PGUID; lpcstrDescription: PChar;
  lpcstrModule: PChar; lpContext: Pointer): BOOL; stdcall;
begin
  if Assigned(lpGuid) then
  begin
    CopyMemory(lpContext, lpGuid, SizeOf(TGUID));
    Result := False;
  end
  else
    Result := True;
end;

constructor TDSoutput.Create(const wndHandle: HWND);
var
  Fpwfm: TWAVEFORMATEX;
  Fpdesc: TDSBUFFERDESC;
  DeviceGUID: PGUID;
begin
  New(DeviceGUID);
  DirectSoundEnumerate(DSEnumOutputCallback, DeviceGUID);
  DSERROR(DirectSoundCreate(DeviceGUID, FDS, nil), 'Creating DS device');
  Dispose(DeviceGUID);
  DSERROR(FDS.SetCooperativeLevel(wndHandle, DSSCL_PRIORITY), 'Setting the cooperative level');

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
  if Assigned(FSecondary) then
    FSecondary.GetCurrentPosition(@Result, nil);
end;

procedure TDSoutput.ChangeVolume(const value: Integer);
var
  volume: Integer;
begin
  if not Assigned(FSecondary) then Exit;
  FSecondary.GetVolume(volume);
  Inc(volume, value);
  FSecondary.SetVolume(volume);
end;

procedure TDSoutput.GetVolume(out AVolume: Cardinal);
var
  volume: Integer;
begin
  if not Assigned(FSecondary) then Exit;
  FSecondary.GetVolume(volume);
  AVolume := 100 - Round((volume / DSBVOLUME_MIN) * 100);
end;

function TDSoutput.InitializeBuffer(const Arate, Achannels: Cardinal): Cardinal;
var
  Fswfm: TWAVEFORMATEX;
  Fsdesc: TDSBUFFERDESC;
  lastvolume: Integer;
  Buffer: PByte;
  Size: Cardinal;
begin
  lastvolume := 0;
  if Assigned(FSecondary) then
    FSecondary.GetVolume(lastvolume);
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
    cbSize := 0;
  end;


  // set up the buffer
  FillChar(Fsdesc, SizeOf(TDSBUFFERDESC), 0);
  with Fsdesc do
  begin
    dwSize := SizeOf(TDSBUFFERDESC);
    dwReserved := 0;
    dwFlags :=
      DSBCAPS_GETCURRENTPOSITION2 or
      DSBCAPS_CTRLVOLUME or
      DSBCAPS_GLOBALFOCUS;
    lpwfxFormat := @Fswfm;
    dwBufferBytes := 64 * 1024;
  end;

  DSERROR(FDS.CreateSoundBuffer(Fsdesc, Fsecondary, nil), 'ERRO, criando o buffer secundario');

  Result := Fsdesc.dwBufferBytes div 2;

  FSecondary.SetVolume(lastvolume);

  FSecondary.Lock(0, Fsdesc.dwBufferBytes, @Buffer, @Size, nil, nil, DSBLOCK_ENTIREBUFFER);
  FillChar(Buffer^, Size, 0);
  FSecondary.Unlock(Buffer, Size, nil, 0);

end;

procedure TDSoutput.Play;
begin
  if Assigned(FSecondary) then
    FSecondary.Play(0, 0, DSBPLAY_LOOPING);
end;

procedure TDSoutput.Stop;
begin
  if Assigned(FSecondary) then
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
  // DESTROY THREAD
  inherited;
end;

procedure TRadioPlayer.Execute;
begin
  repeat
    UpdateBuffer();
    Sleep(25);
  until Terminated;
end;

end.

