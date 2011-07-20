unit DSOutput;

interface

uses
  SysUtils,
  Classes,
  Windows,
  MMSystem,
  _DirectSound;

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
    property SoundBuffer: IDirectSoundBuffer read fSecondary write fSecondary;
    function Volume(value: Integer; store : LongBool = True): Integer;
    procedure Play;
    procedure Stop;
    function InitializeBuffer(const Arate, Achannels: Cardinal): Cardinal;
    constructor Create(WndHandle: HWND);
    destructor Destroy; override;
  end;

type
  TRadioPlayer = class(TThread)
  protected
    fDS: TDSOutput;
    fRate: Integer;
    fChannels: Integer;
    fHalfbuffersize: Cardinal;
    procedure updatebuffer(const offset: Cardinal); virtual; abstract;
    function prebuffer: LongBool; virtual; abstract;
    procedure Execute; override;
  public
    function GetProgress(): Integer; virtual; abstract;
    procedure GetInfo(var Atitle, Aquality: string); virtual; abstract;
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

function TDSOutput.Volume(value: Integer; store : LongBool = True): Integer;
begin
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
      value := (40 * value) - 4000;
      //value := -25 * (100 - value);
      //value := 50 * value - 5000;
      //value := Round(1085.73 * Ln(Value)) - 5000;
    end;

  if fSecondary <> nil then
    fSecondary.SetVolume(value);

  if store then
    fVolume := Result;
end;

function TDSOutput.InitializeBuffer(const Arate, Achannels: Cardinal): Cardinal;
var
  Fswfm: TWAVEFORMATEX;
  Fsdesc: TDSBUFFERDESC;
begin
  fSecondary := nil;

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
    dwBufferBytes := 64*1024;
  end;

  DSERROR(fDS.CreateSoundBuffer(Fsdesc, fSecondary, nil), 'Creating S buffer');

  Volume(fVolume);

  Result := Fsdesc.dwBufferBytes div 2;
end;

procedure TDSOutput.Play;
begin
  fSecondary.Play(0, 0, DSBPLAY_LOOPING);
end;

procedure TDSOutput.Stop;
begin
  fSecondary.Stop;
end;

{ TRadioPlayer }

constructor TRadioPlayer.Create();
begin
  // CREATE TRHEAD, SUSPENDED
  fDS := _DS;
  inherited Create(True);
  Priority := tpTimeCritical;
  FreeOnTerminate := True;
end;

destructor TRadioPlayer.Destroy;
begin
  if fHalfbuffersize <> 0 then
  begin
    fDS.Stop;
    inherited;
    fDS.SoundBuffer := nil;
  end
  else
    inherited;
end;

procedure TRadioPlayer.Execute;
var
  offset, lastoffset: Cardinal;
  vfade, vtarget: Integer;
  //aa , bb : Int64;
begin
  if Terminated then Exit;
  if not prebuffer() then Exit;

  vtarget := fDS.fVolume;
  if vtarget = 0 then
    vfade := 0
  else
  begin
    vfade := 2;
    fDS.Volume(vfade);
  end;

  updatebuffer(0);
  lastoffset := 0;
  fDS.Play;
  NotifyForm(NOTIFY_BUFFER, BUFFER_OK);

  repeat
    if fDS.GetPlayCursorPos() > Fhalfbuffersize then
      offset := 0
    else
      offset := Fhalfbuffersize;

    if offset <> lastoffset then
    begin
      //QueryPerformanceCounter(aa);
      UpdateBuffer(offset);
      //QueryPerformanceCounter(bb);
      //Writeln(bb-aa);
      lastoffset := offset;
    end;

    Sleep(32);

    if vfade <> 0 then
      if (vfade >= vtarget) or (fDS.fVolume <> vfade) then
        vfade := 0
      else
        vfade := fDS.Volume(vfade + 2);

  until Terminated;

  if vfade <> 0 then
    fDS.fVolume := vtarget;
end;

end.

