unit DSOutput;

interface

uses
  SysUtils,
  Classes,
  Windows,
  MMSystem,
  _DirectSound;

{$MINENUMSIZE 4}


const
  DSBUFFSIZE = 64 * 1024;

type
  TDSOutput = class
  private
    fDS: IDirectSound;
    fPrimary: IDirectSoundBuffer;
    fSecondary: IDirectSoundBuffer;
    fVolume: Integer;
    function GetPlayCursorPos: Cardinal;
  public
    property PlayCursorPos: Cardinal read GetPlayCursorPos;
    property SoundBuffer: IDirectSoundBuffer read FSecondary write FSecondary;
    function Volume(value: Integer): Integer;
    procedure Play;
    procedure Stop;
    function InitializeBuffer(const Arate, Achannels: Cardinal): Cardinal;
    constructor Create(WndHandle: HWND);
    destructor Destroy; override;
  end;

type
  TRadioStatus = (rsStoped, rsPrebuffering, rsPlaying, rsRecovering);

type
  TRadioPlayer = class(TThread)
  private
    procedure SetStatus(const Value: TRadioStatus);
  protected
    fDS : TDSOutput;
    fRate: Integer;
    fChannels: Integer;
    fHalfbuffersize: Cardinal;
    fStatus: TRadioStatus;
    procedure updatebuffer(const offset: Cardinal); virtual; abstract;
    procedure prebuffer; virtual; abstract;
    procedure Execute; override;
  public
    property Status: TRadioStatus read FStatus write SetStatus;
    function GetProgress(): Integer; virtual; abstract;
    procedure GetInfo(out Atitle, Aquality: string); virtual; abstract;
    function Open(const url: string): LongBool; virtual; abstract;
    constructor Create();
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

constructor TDSOutput.Create(WndHandle: HWND);
var
  Fpwfm: TWAVEFORMATEX;
  Fpdesc: TDSBUFFERDESC;
begin
  fVolume := INITIALVOL;

  DSERROR(DirectSoundCreate(nil, fDS, nil), 'Creating DS device');
  DSERROR(FDS.SetCooperativeLevel(WndHandle, DSSCL_PRIORITY), 'Setting the coop level');

  FillChar(Fpdesc, SizeOf(TDSBUFFERDESC), 0);
  with Fpdesc do
  begin
    dwSize := SizeOf(TDSBUFFERDESC);
    dwFlags := DSBCAPS_PRIMARYBUFFER;
    lpwfxFormat := nil;
    dwBufferBytes := 0;
  end;

  DSERROR(FDS.CreateSoundBuffer(Fpdesc, Fprimary, nil), 'Creating P buffer');

  //FillChar(Fpwfm, SizeOf(TWAVEFORMATEX), 0);
  with Fpwfm do
  begin
    wFormatTag := WAVE_FORMAT_PCM;
    nChannels := 2;
    nSamplesPerSec := 44100;
    nBlockAlign := 4;
    wBitsPerSample := 16;
    nAvgBytesPerSec := 44100 * 4;
    cbSize := 0;
  end;

  DSERROR(fPrimary.SetFormat(@Fpwfm), 'Changing P buffer format');
end;

destructor TDSOutput.Destroy;
begin
  fSecondary := nil;
  fPrimary := nil;
  fDS := nil;
  inherited;
end;

function TDSOutput.GetPlayCursorPos: Cardinal;
begin
  fSecondary.GetCurrentPosition(@Result, nil);
end;

function TDSOutput.Volume(value: Integer): Integer;
begin
  if value >= 100 then
  begin
    fVolume := 100;
    value := DSBVOLUME_MAX;
  end
  else
    if value <= 0 then
    begin
      fVolume := 0;
      value := DSBVOLUME_MIN;
    end
    else
    begin
      fVolume := value;
      value := (100 - value) * (DSBVOLUME_MIN div 500);
      //value := -Round(1000 * Log10(1 / (value / 100)));
    end;

  if fSecondary <> nil then
    fSecondary.SetVolume(value);

  Result := fVolume;
end;

function TDSOutput.InitializeBuffer(const Arate, Achannels: Cardinal): Cardinal;
var
  Fswfm: TWAVEFORMATEX;
  Fsdesc: TDSBUFFERDESC;
begin
  FSecondary := nil;

  //FillChar(Fswfm, SizeOf(TWAVEFORMATEX), 0);
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
    dwFlags :=
      DSBCAPS_GETCURRENTPOSITION2 or
      DSBCAPS_CTRLVOLUME or
      DSBCAPS_GLOBALFOCUS;
    lpwfxFormat := @Fswfm;
    dwBufferBytes := 64 * 1024;
  end;

  DSERROR(fDS.CreateSoundBuffer(Fsdesc, fSecondary, nil), 'Creating S buffer');

  Volume(fVolume);

  Result := Fsdesc.dwBufferBytes div 2;
end;

procedure TDSOutput.Play;
begin
  if fSecondary <> nil then
    fSecondary.Play(0, 0, DSBPLAY_LOOPING);
end;

procedure TDSOutput.Stop;
begin
  if fSecondary <> nil then
    fSecondary.Stop;
end;

{ TRadioPlayer }

constructor TRadioPlayer.Create();
begin
  // CREATE TRHEAD, SUSPENDED
  fDS := _DS;
  inherited Create(True);
  Priority := tpTimeCritical;
  fStatus := rsStoped;
end;

destructor TRadioPlayer.Destroy;
begin
  fStatus := rsStoped;
  fDS.Stop;
  inherited;
  fDS.SoundBuffer := nil;
end;

procedure TRadioPlayer.Execute;
var
  offset, lastoffset: Cardinal;
begin
  prebuffer();
  // if terminated while prebuffering Exit
  if Terminated then Exit;
  // Debug('prebuffered');
  // Fill buffer at offset 0
  updatebuffer(0);
  // Debug('our 1º buffer update');
  lastoffset := 0;
  fDS.Play;
  Status := rsPlaying;
  repeat
    if fDS.GetPlayCursorPos() > Fhalfbuffersize then
      offset := 0
    else
      offset := Fhalfbuffersize;

    if offset <> lastoffset then
    begin
      UpdateBuffer(offset);
      lastoffset := offset;
    end;
    Sleep(32);
  until Terminated;
end;

procedure TRadioPlayer.SetStatus(const Value: TRadioStatus);
begin
  FStatus := Value;
  NotifyForm(1);
end;

end.

