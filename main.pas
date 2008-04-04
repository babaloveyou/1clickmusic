unit main;

interface

uses
  Classes,
  SysUtils,
  Windows,
  Messages,
  KOL,
  DSoutput,
  radioopener,
  obj_scrobber,
  obj_list,
  obj_playlist,
  httpsend;

var
  //# needed cuz of the KOL windows is Free with no control..
  appwinHANDLE: HWND;
  // Core
  DS: TDSoutput;
  chn: TRadioPlayer;
  curProgress: Cardinal;
  curVolume: Cardinal;
  //
  curBitrate: Cardinal;
  lastTitle, curTitle: string;
  //
  undermouse: Cardinal;
  genreid: array[0..7] of Cardinal;
  radiolist: PRadioList;

  // OPTIONS
  traypopups_enabled: Boolean;
  firstrun_enabled: Boolean;
  // MSN NOW PLAYING FEATURE
  msn_enabled: Boolean;
  msn_iconi: Integer;
  msn_icons: string;
  // Hotkeys
  hotkeys: array[1..12] of Cardinal;
  // list
  list_enabled: Boolean;
  list_file: string;
  //
  clipboard_enabled: Boolean;
  // lastfm plugin
  lastfm_enabled: Boolean;
  lastfm_user, lastfm_pass: string;

procedure updateMSN(write: Boolean);
procedure LastFMexecute;
procedure showaboutbox;
function AutoUpdate: Boolean;

implementation

uses utils;

procedure updateMSN(write: Boolean);
var
  msndata: CopyDataStruct;
  msnwindow: HWND;
  utf16buffer: WideString;
begin
  utf16buffer := WideFormat('1ClickMusic\0%s\0%d\0{0}\0%s\0\0\0\0\0', [msn_icons, Integer(write), curTitle]);
  msndata.dwData := $547;
  msndata.cbData := (Length(utf16buffer) * 2) + 2;
  msndata.lpData := Pointer(utf16buffer);
  msnwindow := 0;
  msnwindow := FindWindowEx(0, msnwindow, 'MsnMsgrUIManager', nil);
  if msnwindow <> 0 then
    SendMessage(msnwindow, WM_COPYDATA, 0, Integer(@msndata));
end;

procedure LastFMexecute;
var
  lastfmplugin: TScrobber;
begin
  lastfmplugin := TScrobber.Create;
  if not lastfmplugin.Execute(curtitle) then
    RaiseError('Last.FM plugin error : ' + lastfmplugin.Error, False);
  lastfmplugin.Free;
end;

procedure showaboutbox;
begin
  MessageBox(0, '1ClickMusic 1.8.2' + #13#10 +
    'by arthurprs (arthurprs@gmail.com)' + #13#10#13#10 +
    'Agradecimentos a:' + #13#10 +
    'freak_insane, Blizzy, Kintoun Rlz, Paperback Writer,' + #13#10 +
    'kamikazze, BomGaroto, SnowHill, Ricardo, Greel, The_Terminator,' + #13#10
    + 'jotaeme, Mouse Pad, Lokinhow, Mario Bros.,' + #13#10 +
    'e a toda a galera que tem me incentivado.',
    '1ClickMusic 1.8.2', MB_OK + MB_ICONINFORMATION + MB_TOPMOST);
end;

function AutoUpdate: Boolean;
const
  appversion = 182;
  updateurl1 = 'http://www.thehardwaresxtreme.com/nye/arthurprs/update.txt';
  updateurl2 = 'http://www.freeshells.ch/~arthurpr/update.txt';
  updatefile1 = 'http://www.freeshells.ch/~arthurpr/oneclick.exe';
  updatefile2 = 'http://www.thehardwaresxtreme.com/nye/arthurprs/oneclick.exe';
var
  Text: TStringlist;
  newfile: TFileStream;
  batpath, tempfilepath: string;
begin
  Result := True;
  Text := TStringlist.Create;
  if not (HttpGetText(updateurl1, Text) or
    HttpGetText(updateurl2, Text)) then
  begin
    Result := False;
    RaiseError('ERROR DOWNLOADING THE UPDATE!', False);
  end;

  if Result and (StrToInt(Text[0]) > appversion) then
  begin
    if MessageBox(0,
      PChar(Format('Version %s is avaliable, download and update?', [Text[0]])),
      '1ClickMusic update avaliable', MB_YESNO + MB_ICONQUESTION) = IDYES then
    begin
      tempfilepath := GetTempDir + 'onemusic.exe';
      newfile := TFileStream.Create(tempfilepath, fmCreate);
      if not (HttpGetBinary(updatefile1, newfile) or
        HttpGetBinary(updatefile2, newfile)) then
        Result := False;
      newfile.Free;

      if Result then
      begin
        batpath := GetTempDir + 'oneclickupdate.bat';
{$WARNINGS OFF}
        FileSetAttr(ParamStr(0), 0);
{$WARNINGS ON}
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
      RaiseError('Error Downloading update',False);
    end
    else
      Result := False;
  end
  else
  begin
    Result := False;
    MessageBox(0, 'Your version is up-to-date', '1ClickMusic', MB_ICONINFORMATION);
  end;
  Text.Free;
end;

end.

