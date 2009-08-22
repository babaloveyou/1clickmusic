unit main;

interface

uses
  KOL,
  SysUtils,
  Classes,
  Windows,
  Messages,
  DSoutput,
  obj_list,
  httpsend;

const
  APPVERSION = 1920;
  APPVERSIONSTR = '1.9.2';
  INITIALVOL = 80;
  WM_NOTIFY = WM_USER + 1;
  stSTOPED = 0;
  stPLAYING = 1;
  stPAUSED = 2;

  // GLOBAL VARS, IF NECESSARY INITIALIZED
var
  //# needed cuz of the KOL windows is Free with no control..
  appwinHANDLE: HWND;

  //# Core Global Variables
  _DS: TDSoutput;
  Chn: TRadioPlayer = nil;
  ChnOpener : TThread;
  curStatus : Cardinal = stSTOPED;
  curRadio : Cardinal = Cardinal(-1);
  curProgress: Integer;
  curVolume: Integer;
  //
  curBitrate: string;
  lastTitle, curTitle: string;
  //
  undermouse: Cardinal;
  radiolist: TRadioList;

  //# OPTIONS
  //# autorun
  autorun_enabled: LongBool;
  playonstart_enabled: LongBool;
  //# Tray
  traycolor_enabled: LongBool;
  traypopup_enabled: LongBool;
  firstrun_enabled: LongBool;
  //# MSN NOW PLAYING FEATURE
  msn_enabled: LongBool;
  //# Hotkeys
  hotkeys: array[0..11] of Cardinal;
  //# list
  list_enabled: LongBool;
  list_file: string;
  clipboard_enabled: LongBool;
  //# lastfm plugin
  lastfm_thread: PThread = nil;
  lastfm_enabled: LongBool;
  lastfm_user, lastfm_pass: string;
  lastfm_nextscrobb: Cardinal = 0;

procedure SetAutoRun();
procedure UpdateMsn(write: LongBool);
procedure ShowAboutbox();
function AutoUpdate(): LongBool;
procedure NotifyForm(wParam, lParam: Integer);

const
  NOTIFY_OPENERROR = -1;
  NOTIFY_NEWINFO = 11;
  NOTIFY_DISCONECT = 10;
  NOTIFY_BUFFER = 9;
  NOTIFY_CONNECTED = 8;
  BUFFER_OK = 0;
  BUFFER_RECOVERING = 1;
  BUFFER_PREBUFFERING = 2;

implementation

uses utils;

procedure SetAutoRun();
const
  AutoRunRegistryKey = 'SOFTWARE\Microsoft\Windows\CurrentVersion\Run';
var
  key: HKEY;
begin
  if autorun_enabled then
  begin
    RegCreateKey(HKEY_LOCAL_MACHINE, AutoRunRegistryKey, key);
    RegSetValueEx(key, 'oneclick', 0, REG_SZ, PChar('"' + ParamStr(0) + '" -h'), Length(ParamStr(0)) + 3);
  end
  else
  begin
    RegOpenKey(HKEY_LOCAL_MACHINE, AutoRunRegistryKey, key);
    RegDeleteValue(key, 'oneclick');
  end;
  RegCloseKey(key);
end;

procedure NotifyForm(wParam, lParam: Integer);
begin
  PostMessage(appwinHANDLE, WM_NOTIFY , wParam, lParam);
end;

procedure UpdateMsn(write: LongBool);
var
  msndata: CopyDataStruct;
  msnwindow: HWND;
  buffer: WideString;
begin
  buffer := WideFormat('1ClickMusic\0Music\0%d\0{0}\0%s\0\0\0\0\0', [Ord(write), curTitle]);
  msndata.dwData := $547;
  msndata.cbData := (Length(buffer) * 2) + 2;
  msndata.lpData := Pointer(buffer);

  msnwindow := 0;
  repeat
    msnwindow := FindWindowEx(0, msnwindow, 'MsnMsgrUIManager', nil);
    if msnwindow = 0 then Break;
    SendMessage(msnwindow, WM_COPYDATA, 0, Integer(@msndata));
  until False;
end;

procedure ShowAboutbox();
begin
  MessageBox(0, '1ClickMusic ' + APPVERSIONSTR + #13 +
    'www.1clickmusic.net' + #13 +
    'by arthurprs (arthurprs@gmail.com)' + #13#13 +
    'thanks to:' + #13 +
    'freak_insane, Blizzy, Kintoun Rlz, Paperback Writer,' + #13 +
    'kamikazze, BomGaroto, SnowHill, Ricardo, Greel, The_Terminator,' + #13 +
    'jotaeme, Mouse Pad, Lokinhow, Mario Bros, Blurkness, -dnb-,' + #13 +
    'Gouveia_Net, Gilson Junior­, BlueX, Warrior of Shadows and for all who have encouraged me.',
    '1ClickMusic ' + APPVERSIONSTR, MB_OK or MB_ICONINFORMATION or MB_TOPMOST);
end;

function AutoUpdate(): LongBool;
const
  updateurl = '1clickmusic.net/update/update';
var
  Text: TStringList;
  newfile: TFileStream;
  batpath, tempfilepath: string;
begin
  Text := TStringList.Create;
  Result := HttpGetText(updateurl, Text);
  if Result then
    if StrToIntDef(Text[0], 0) > APPVERSION then
    begin
      if MessageBox(0,
        PChar(Format('Version %s is avaliable, download and update?', [Text[1]])),
        '1ClickMusic update avaliable', MB_YESNO + MB_ICONQUESTION) = IDYES then
      begin
        tempfilepath := GetTempDir + 'oneclick.exe';
        newfile := TFileStream.Create(tempfilepath, fmCreate);
        Result := HttpGetBinary(Text[2], newfile);
        newfile.Free;
        if Result then
        begin
          batpath := GetTempDir + 'oneclick.bat';
          Text.Clear;
          Text.Add(':Label1');
          Text.Add('del "' + ParamStr(0) + '"');
          Text.Add('if Exist "' + ParamStr(0) + '" goto Label1');
          Text.Add('Move "' + tempfilepath + '" "' + ParamStr(0) + '"');
          Text.Add('Call "' + ParamStr(0) + '"');
          Text.Add('del "' + batpath + '"');
          Text.SaveToFile(batpath);
          Result := WinExec(PChar(batpath), SW_HIDE) > 31;
        end
        else
        begin
          RaiseError('Downloading update file', False);
        end;
      end
      else
        Result := False;
    end
    else
    begin
      Result := False;
    end;

  Text.Free;
end;

end.

