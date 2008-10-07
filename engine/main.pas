unit main;

interface

uses
  KOL,
  SysUtils,
  Classes,
  Windows,
  Messages,
  DSoutput,
  radioopener,
  mp3stream,
  obj_scrobber,
  obj_list,
  obj_playlist,
  httpsend;

const
  APPVERSION = 187;
  APPVERSIONSTR = '1.8.7';

  // GLOBAL VARS, IF NECESSARY INITIALIZED
var
  //# needed cuz of the KOL windows is Free with no control..
  appwinHANDLE: HWND;

  //# Core Global Variables
  DS: TDSoutput;
  Chn: TRadioPlayer = nil;
  curProgress: Integer;
  curVolume: Integer = 100;
  //
  curBitrate: Cardinal;
  lastTitle, curTitle: string;
  //
  undermouse: Cardinal;
  radiolist: TRadioList;

  //# OPTIONS
  trayiconcolor_enabled: LongBool;
  traypopups_enabled: LongBool;
  firstrun_enabled: LongBool;
  //# MSN NOW PLAYING FEATURE
  msn_enabled: LongBool;
  msn_iconi: Integer;
  msn_icons: string;
  //# Hotkeys
  hotkeys: array[1..12] of Cardinal;
  //# list
  list_enabled: LongBool;
  list_file: string;
  //
  clipboard_enabled: LongBool;
  // lastfm plugin
  lastfm_enabled: LongBool;
  lastfm_user, lastfm_pass: string;
  lastfm_nextscrobb: Cardinal = 0;
  // proxy
  proxy_enabled: LongBool;
  proxy_host, proxy_port, proxy_pass: string;

procedure updateMSN(write: LongBool);
procedure ShowAboutbox();
function AutoUpdate(): LongBool;
procedure NotifyForm(const lParam: Integer);

implementation

uses utils;

procedure NotifyForm(const lParam: Integer);
begin
  PostMessage(appwinHANDLE, WM_USER, Integer(Chn), lParam);
end;

procedure updateMSN(write: LongBool);
var
  msndata: CopyDataStruct;
  msnwindow: HWND;
  buffer: WideString;
begin

  buffer := WideFormat('1ClickMusic\0%s\0%d\0{0}\0%s\0\0\0\0\0', [msn_icons, Ord(write), curTitle]);
  msndata.dwData := $547;
  msndata.cbData := (Length(buffer) * 2) + 2;
  msndata.lpData := Pointer(buffer);

  msnwindow := FindWindowEx(0, 0, 'MsnMsgrUIManager', nil); ;
  while msnwindow <> 0 do
  begin
    SendMessage(msnwindow, WM_COPYDATA, 0, Integer(@msndata));
    msnwindow := FindWindowEx(0, msnwindow, 'MsnMsgrUIManager', nil);
  end;
end;

procedure ShowAboutbox();
begin
  MessageBox(0, '1ClickMusic ' + APPVERSIONSTR + #13#10 +
    'by arthurprs (arthurprs@gmail.com)' + #13#10#13#10 +
    'Agradecimentos a:' + #13#10 +
    'freak_insane, Blizzy, Kintoun Rlz, Paperback Writer,' + #13#10 +
    'kamikazze, BomGaroto, SnowHill, Ricardo, Greel, The_Terminator,' + #13#10
    + 'jotaeme, Mouse Pad, Lokinhow, Mario Bros, Blurkness, -dnb-,' + #13#10 +
    'e a toda a galera que tem me incentivado.',
    '1ClickMusic ' + APPVERSIONSTR, MB_OK + MB_ICONINFORMATION + MB_TOPMOST);
end;

function AutoUpdate(): LongBool;
const
  updateurl = 'http://arthurprs.srcom.org/update.txt';
  updatefile = 'http://arthurprs.srcom.org/oneclick.exe';
var
  Text: TStringList;
  newfile: TFileStream;
  batpath, tempfilepath: string;
begin
  Text := TStringList.Create;
  Result := HttpGetText(updateurl, Text);
  if Result then
    if StrToIntDef(Text[0],-1) > APPVERSION then
    begin
      if MessageBox(0,
        PChar(Format('Version %s is avaliable, download and update?', [Text[0]])),
        '1ClickMusic update avaliable', MB_YESNO + MB_ICONQUESTION) = IDYES then
      begin
        tempfilepath := GetTempDir + 'oneclick.exe';
        newfile := TFileStream.Create(tempfilepath, fmCreate);
        Result := HttpGetBinary(updatefile, newfile);
        if Result then
        begin
          batpath := GetTempDir + 'oneclickupdate.bat';
          Text.Clear;
          Text.Add(':Label1');
          Text.Add('del "' + ParamStr(0) + '"');
          Text.Add('if Exist "' + ParamStr(0) + '" goto Label1');
          Text.Add('Move "' + tempfilepath + '" "' + ParamStr(0) + '"');
          Text.Add('Call "' + ParamStr(0) + '"');
          Text.Add('del "' + batpath + '"');
          Text.SaveToFile(batpath);
          Result := WinExec(PChar(batpath), SW_HIDE) > 0;
        end
        else
          RaiseError('DOWNLOADING THE UPDATE FILE', False);

        newfile.Free;
      end
    end
    else
    begin
      Result := False;
      MessageBox(0, 'Your version is up-to-date', '1ClickMusic', MB_ICONINFORMATION);
    end
  else
    RaiseError('DOWNLOADING THE UPDATE FILE', False);

  Text.Free;
end;

end.

