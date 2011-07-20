{ KOL MCK }// Do not remove this line!
{$DEFINE KOL_MCK}
unit Unit1;

interface

{$IFDEF KOL_MCK}
uses Windows, Messages, KOL, KOLBAPTrayIcon{$IFNDEF KOL_MCK}, mirror, Classes, Controls, mckControls, mckObjs, Graphics, mckCtrls, mckBAPTrayIcon{$ENDIF (place your units here->)}, SysUtils;
{$ELSE}
{$I uses.inc}
Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, Dialogs;
{$ENDIF}

type
{$IFDEF KOL_MCK}
{$I MCKfakeClasses.inc}
  {$IFDEF KOLCLASSES} {$I TForm1class.inc} {$ELSE OBJECTS} PForm1 = ^TForm1; {$ENDIF CLASSES/OBJECTS}
  {$IFDEF KOLCLASSES}{$I TForm1.inc}{$ELSE} TForm1 = object(TObj) {$ENDIF}
    Form: PControl;
{$ELSE not_KOL_MCK}
  TForm1 = class(TForm)
{$ENDIF KOL_MCK}
    KOLProject1: TKOLProject;
    lbltrack: TKOLLabel;
    lblbuffer: TKOLLabel;
    lblstatus: TKOLLabel;
    channeltree: TKOLTreeView;
    lblhelp: TKOLLabel;
    lblradio: TKOLLabel;
    KOLForm1: TKOLForm;
    btplay: TKOLButton;
    pgrbuffer: TKOLProgressBar;
    Tray: TKOLBAPTrayIcon;
    treeimagelist: TKOLImageList;
    procedure KOLForm1FormCreate(Sender: PObj);
    procedure channeltreeMouseUp(Sender: PControl;
      var Mouse: TMouseEventData);
    procedure TrayMouseUp(Sender: PControl; var Mouse: TMouseEventData);
    procedure btplayClick(Sender: PObj);
    procedure channeltreeSelChange(Sender: PObj);
    procedure KOLForm1Destroy(Sender: PObj);
    function KOLForm1Message(var Msg: TMsg; var Rslt: Integer): Boolean;
  private

  public
    ITRAY, ITrayBlue, ITrayGreen, ITrayRed, ITrayPause: HICON;
    treemenu, traymenu: PMenu;
    procedure ProgressExecute(Force: LongBool = False);
    procedure UpdateExecute();
    function LastFMThreadExecute(Sender: PThread): Integer;
    procedure ChangeTrayIcon(NewIcon: HICON; Force: LongBool = False);
    procedure traypopup(const Atitle, Atext: AnsiString; const IconType: Integer);
    procedure PlayChannel;
    procedure StopChannel;
    procedure treemenuproc(Sender: PMenu; Item: Integer);
    procedure traymenuproc(sender: PMenu; Item: Integer);
    procedure LoadConfig;
    procedure SaveConfig;
  end;

var
  Form1{$IFDEF KOL_MCK}: PForm1{$ELSE}: TForm1{$ENDIF};

{$IFDEF KOL_MCK}procedure NewForm1(var Result: PForm1; AParent: PControl); {$ENDIF}

implementation

uses
  InputQuery,
  DSoutput,
  radioopener,
  obj_list,
  obj_scrobbler,
  main,
  utils,
  synacode,
  synautil,
  obj_db;

{$IFNDEF KOL_MCK}{$R *.DFM}{$ENDIF}

{$IFDEF KOL_MCK}{$I Unit1_1.inc}{$ENDIF}

const
  TRAYMENU_RADIOS = 1;
  TRAYMENU_PLAYSTOP = 28;
  TRAYMENU_ABOUT = 29;
  TRAYMENU_EXIT = 30;
  TRAYMENU_TRAYPOPUP = 14;
  TRAYMENU_TRAYCOLOR = 15;
  TRAYMENU_MSNNOWPLAYING = 17;
  TRAYMENU_SAVETRACKLIST = 19;
  TRAYMENU_SAVETRACKCLIPBOARD = 21;
  TRAYMENU_LASTFM = 22;
  TRAYMENU_AUTORUN = 24;
  TRAYMENU_PLAYONSTART = 25;
  TRAYMENU_USEPROXY = 26;

procedure TForm1.LoadConfig;
var
  i: Integer;
begin
  with OpenIniFile('oneclickmusic.ini')^ do
  begin
    Mode := ifmRead;
    Section := 'options';
    curVolume := ValueInteger('volume', INITIALVOL);
    traycolor_enabled := ValueBoolean('traycolor_enabled', True);
    traypopup_enabled := ValueBoolean('traypopup_enabled', True);
    firstrun_enabled := ValueBoolean('firstrun_enabled', True);
    msn_enabled := ValueBoolean('msn_enabled', False);
    list_enabled := ValueBoolean('list_enabled', False);
    list_file := ValueString('list_file', 'list.txt');
    clipboard_enabled := ValueBoolean('clipboard_enabled', False);
    lastfm_enabled := ValueBoolean('lastfm_enabled', False);
    lastfm_user := ValueString('lastfm_user', '');
    lastfm_pass := ValueString('lastfm_pass', '');
    autorun_enabled := ValueBoolean('autorun_enabled', False);
    playonstart_enabled := ValueBoolean('playonstart_enabled', False);
    proxy_enabled := ValueBoolean('proxy_enabled', False);
    proxy_proxy := ValueString('proxy_proxy', '');

    Section := 'hotkeys';
    for i := 0 to 11 do
    begin
      hotkeys[i] := radiolist.getpos(ValueString(Int2Str(i + 1), ''));
      treemenu.ItemText[i] := 'Ctrl+F' + Int2Str(i + 1) + ' :' + #9 + radiolist.getname(hotkeys[i]);
    end;
    Free;
  end;

  with traymenu^ do
  begin
    for i := 0 to 11 do
      if hotkeys[i] = 0 then
        ItemVisible[i + TRAYMENU_RADIOS] := False
      else
        ItemText[i + TRAYMENU_RADIOS] := treemenu.ItemText[i];

    ItemChecked[TRAYMENU_TRAYPOPUP] := traypopup_enabled;
    ItemChecked[TRAYMENU_TRAYCOLOR] := traycolor_enabled;
    ItemChecked[TRAYMENU_MSNNOWPLAYING] := msn_enabled;
    ItemChecked[TRAYMENU_SAVETRACKLIST] := list_enabled;
    ItemChecked[TRAYMENU_SAVETRACKCLIPBOARD] := clipboard_enabled;
    ItemChecked[TRAYMENU_LASTFM] := lastfm_enabled;
    ItemChecked[TRAYMENU_AUTORUN] := autorun_enabled;
    ItemChecked[TRAYMENU_PLAYONSTART] := playonstart_enabled;
    ItemChecked[TRAYMENU_USEPROXY] := proxy_enabled;
  end;
end;

procedure TForm1.SaveConfig;
var
  i: Integer;
begin
  with OpenIniFile('oneclickmusic.ini')^ do
  begin
    Mode := ifmWrite;
    Section := 'options';
    ValueInteger('volume', curVolume);
    ValueBoolean('traycolor_enabled', traycolor_enabled);
    ValueBoolean('traypopup_enabled', traypopup_enabled);
    ValueBoolean('firstrun_enabled', False);
    ValueBoolean('msn_enabled', msn_enabled);
    ValueBoolean('list_enabled', list_enabled);
    ValueString('list_file', list_file);
    ValueBoolean('clipboard_enabled', clipboard_enabled);
    ValueBoolean('lastfm_enabled', lastfm_enabled);
    ValueString('lastfm_user', lastfm_user);
    ValueString('lastfm_pass', StrToHex(MD5(lastfm_pass)));
    ValueBoolean('autorun_enabled', autorun_enabled);
    ValueBoolean('playonstart_enabled', playonstart_enabled);
    ValueBoolean('proxy_enabled', proxy_enabled);
    ValueString('proxy_proxy', proxy_proxy);

    Section := 'hotkeys';
    for i := 0 to 11 do
      ValueString(Int2Str(i + 1), radiolist.getname(hotkeys[i]));

    Free;
  end;
end;

procedure TForm1.ProgressExecute(Force: LongBool = False);
var
  progress: Integer;
  newicon: HICON;
begin
  // # GET INFO
  progress := Chn.GetProgress();
  if (progress = curProgress) and (not Force) then Exit;

  case progress of
    0..40:
      begin
        newicon := ITrayRed;
      end;
    41..75:
      begin
        newicon := ITrayGreen;
      end;
  else
    begin
      newicon := ITrayBlue;
    end;
  end;


  pgrbuffer.Progress := progress;

  if curStatus = stPLAYING then
    ChangeTrayIcon(newicon);

  curProgress := progress;
end;

procedure TForm1.UpdateExecute();
begin
  if Chn = nil then Exit;
  Chn.GetInfo(curTitle, curBitrate);

  //# Trow events when track changes
  if curTitle <> lastTitle then
    if curTitle = '' then
      Form.Caption := '1ClickMusic'
    else
    begin
      Tray.Tooltip := curTitle;
      Form.caption := curTitle;
      lastTitle := curTitle;

      if curStatus = stPLAYING then
        traypopup('Track change', curTitle, NIIF_INFO);

      if msn_enabled then
        UpdateMsn(True);

      if list_enabled then
        WriteToFile(list_file, curTitle);

      if clipboard_enabled then
        Text2Clipboard(curTitle);

      if lastfm_enabled and (GetTickCount() >= lastfm_nextscrobb) then
        lastfm_thread := NewThreadAutoFree(LastFMThreadExecute);
    end;

  // # REFRESH GUI INFORMATION
  lbltrack.caption := curTitle;

  if curStatus = stPLAYING then
    lblbuffer.Caption := curBitrate + #13 + 'vol:' + Int2Str(curVolume)
  else
    lblbuffer.Caption := curBitrate + #13 + 'Paused';
end;

procedure TForm1.PlayChannel;
var
  pls: string;
begin
  pls := radiolist.getpls(channeltree.TVSelected);
  if pls <> '' then
  begin
    StopChannel();

    curRadio := channeltree.TVSelected;
    lblradio.Caption := channeltree.TVItemText[curRadio];

    traymenu.ItemText[TRAYMENU_PLAYSTOP] := 'Stop';
    btplay.Caption := 'Stop';

    // init timer
    SetTimer(appwinHANDLE, 1, 500, nil);

    pgrbuffer.Visible := True;

    lblstatus.Caption := 'Searching...';

    traypopup('Connecting', lblradio.Caption, NIIF_INFO);

    ChnOpener := TRadioOpener.Create(pls);
  end;
end;

procedure TForm1.StopChannel;
begin
  if ChnOpener <> nil then
  begin
    ChnOpener.Terminate;
    ChnOpener := nil;
  end;

  if Chn <> nil then
  begin
    Chn.Terminate;
    Chn := nil;
  end;

  curStatus := stSTOPED;

  KillTimer(appwinHANDLE, 1);

  pgrbuffer.Visible := False;
  curProgress := 0;
  curBitrate := '';
  pgrbuffer.Progress := 0;
  btplay.Caption := 'Play';
  curTitle := '';
  lastTitle := '';
  lblbuffer.Caption := '';
  lblstatus.Caption := '';
  lbltrack.Caption := '';
  Tray.ToolTip := '';
  Form.Caption := '1ClickMusic';
  traymenu.ItemText[TRAYMENU_PLAYSTOP] := 'Play';
  ChangeTrayIcon(ITRAY);
  if msn_enabled then
    UpdateMsn(False);
end;

procedure TForm1.KOLForm1FormCreate(Sender: PObj);
var
  i: Integer;
begin
  appwinHANDLE := form.Handle;
  //# Inicializa o SOM
{$IFDEF DEBUG}
  Debug('DS init');
{$ENDIF}
  _DS := TDSoutput.Create(appwinHANDLE);
{$IFDEF DEBUG}
  Debug('DS init ok');
{$ENDIF}

  ITRAY := LoadIcon(HInstance, 'TRAY'); // gray icon
  ITrayBlue := LoadIcon(HInstance, 'TRAYBLUE');
  ITrayGreen := LoadIcon(HInstance, 'TRAYGREEN');
  ITrayRed := LoadIcon(HInstance, 'TRAYRED');
  ITrayPause := LoadIcon(HInstance, 'TRAYPAUSE');

  Tray.Icon := ITRAY;
  Tray.Active := True;

  //# HOTKEYS
  RegisterHotKey(appwinHANDLE, 2, MOD_CONTROL, VK_UP);
  RegisterHotKey(appwinHANDLE, -2, MOD_CONTROL, VK_DOWN);
  RegisterHotKey(appwinHANDLE, 1003, MOD_CONTROL, VK_END);
  RegisterHotKey(appwinHANDLE, 1004, MOD_CONTROL, VK_HOME);
  RegisterHotKey(appwinHANDLE, 1005, MOD_CONTROL, VK_PAGE_DOWN);
  RegisterHotKey(appwinHANDLE, 1006, MOD_CONTROL, VK_PAGE_UP);
  for i := 0 to 11 do
    RegisterHotKey(appwinHANDLE, 2001 + i, MOD_CONTROL, VK_F1 + i);

  // MENUS!
  NewMenu(Form, 0, [], nil);

  treemenu := NewMenu(channeltree, 0, [' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'Clear Hotkeys'], treemenuproc);
  channeltree.SetAutoPopupMenu(treemenu);

  traymenu := NewMenu(Form, 0, [
    'Favorites', '(', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ')',
      'Options', '(',
      'Tray popups', 'Tray colors', '-', 'Messenger Now Playing', '-', 'Save track list', 'Copy track to clipboard', '-', 'Last.fm Scrobbler', '-', 'Autorun with windows', 'Play fav-1 automaticaly', 'Use Proxy',
      ')',
      '-',
      'Play', 'About', 'Exit'
      ], traymenuproc);

  Tray.PopupMenu := traymenu.Handle;
{$IFDEF DEBUG}
  Debug('radio list init');
{$ENDIF}
  //# Cria lista de radios
  Radiolist := TRadioList.Create;
  //# inicializa os canais e o message handler
{$IFDEF DEBUG}
  Debug('radio list load internal');
{$ENDIF}
  LoadDb(channeltree, radiolist);
{$IFDEF DEBUG}
  Debug('radio list load external');
{$ENDIF}
  LoadCustomDb(channeltree, radiolist, 'userradios.txt');
  LoadCustomDb(channeltree, radiolist, 'C:\userradios.txt');
  //channeltree.AttachProc(TreeListWndProc);
  //# close the treeview
{$IFDEF DEBUG}
  Debug('radio list ok');
{$ENDIF}
  channeltree.TVSelected := channeltree.TVRoot;
  channeltree.TVExpand(channeltree.TVRoot, TVE_COLLAPSE);

{$IFDEF DEBUG}
  Debug('load config');
{$ENDIF}
  //# Load .INI Config
  LoadConfig();
  _DS.Volume(curVolume);
{$IFDEF DEBUG}
  Debug('load config ok');
{$ENDIF}

{$IFDEF DEBUG}
  Debug('last inits...');
{$ENDIF}
  //# Show About box if first run or just updated!
  if firstrun_enabled then showaboutbox;

  if ParamStr(1) = '-h' then Form.Hide();

  if playonstart_enabled then channeltree.TVSelected := hotkeys[0];
{$IFDEF DEBUG}
  Debug('last inits ok');
{$ENDIF}
end;

procedure TForm1.treemenuproc(Sender: PMenu; Item: Integer);
const
  _ClearHotkeys = 12;
begin
  if Item = _ClearHotkeys then
  begin
    for Item := 0 to 11 do
    begin
      hotkeys[Item] := 0;
      treemenu.ItemText[Item] := 'Ctrl+F' + Int2Str(Item + 1);
      traymenu.ItemVisible[Item + TRAYMENU_RADIOS] := False;
    end;
  end
  else
    if not channeltree.TVItemHasChildren[undermouse] then
    begin
      if hotkeys[Item] = undermouse then
      begin
        hotkeys[Item] := 0;
        treemenu.ItemText[Item] := 'Ctrl+F' + Int2Str(Item + 1);
        traymenu.ItemVisible[Item + TRAYMENU_RADIOS] := False;
      end
      else
      begin
        hotkeys[Item] := undermouse;
        treemenu.ItemText[Item] := 'Ctrl+F' + Int2Str(Item + 1) + ' :' + #9 + channeltree.TVItemText[undermouse];
        traymenu.ItemText[Item + TRAYMENU_RADIOS] := treemenu.ItemText[Item];
        traymenu.ItemVisible[Item + TRAYMENU_RADIOS] := True;
      end;
    end;
  SaveConfig();
end;

procedure TForm1.traymenuproc(Sender: PMenu; Item: Integer);
begin
  case Item of
    TRAYMENU_TRAYPOPUP:
      begin
        traypopup_enabled := not traypopup_enabled;
        Sender.ItemChecked[TRAYMENU_TRAYPOPUP] := traypopup_enabled;
      end;

    TRAYMENU_TRAYCOLOR:
      begin
        traycolor_enabled := not traycolor_enabled;
        Sender.ItemChecked[TRAYMENU_TRAYCOLOR] := traycolor_enabled;
        if not traycolor_enabled then
          ChangeTrayIcon(ITRAY, True);
      end;

    TRAYMENU_MSNNOWPLAYING:
      begin
        msn_enabled := not msn_enabled;
        UpdateMsn(msn_enabled);
        Sender.ItemChecked[TRAYMENU_MSNNOWPLAYING] := msn_enabled;
      end;

    TRAYMENU_SAVETRACKLIST:
      begin
        list_enabled := not list_enabled;
        if list_enabled then
          list_enabled := InputBox('filename for the track list:', list_file);
        sender.ItemChecked[TRAYMENU_SAVETRACKLIST] := list_enabled;
      end;

    TRAYMENU_SAVETRACKCLIPBOARD:
      begin
        clipboard_enabled := not clipboard_enabled;
        sender.ItemChecked[TRAYMENU_SAVETRACKCLIPBOARD] := clipboard_enabled;
      end;

    TRAYMENU_LASTFM:
      begin
        lastfm_enabled := not lastfm_enabled;
        if lastfm_enabled then
          lastfm_enabled := (
            InputBox('Last.fm username:', lastfm_user) and
            InputBox('Last.fm password:', lastfm_pass, [eoPassword])
            );

        sender.ItemChecked[TRAYMENU_LASTFM] := lastfm_enabled;
      end;

    TRAYMENU_AUTORUN:
      begin
        autorun_enabled := not autorun_enabled;
        sender.ItemChecked[TRAYMENU_AUTORUN] := autorun_enabled;
        SetAutoRun();
      end;

    TRAYMENU_PLAYONSTART:
      begin
        playonstart_enabled := not playonstart_enabled;
        sender.ItemChecked[TRAYMENU_PLAYONSTART] := playonstart_enabled;
      end;

    TRAYMENU_USEPROXY:
      begin
        proxy_enabled := not proxy_enabled;
        if proxy_enabled then
          proxy_enabled := InputBox('Proxy (ip:port)', proxy_proxy);
        sender.ItemChecked[TRAYMENU_USEPROXY] := proxy_enabled;
      end;

    TRAYMENU_RADIOS..TRAYMENU_RADIOS + 11:
      begin
        Item := Item - TRAYMENU_RADIOS;
        if hotkeys[Item] <> 0 then channeltree.TVSelected := hotkeys[Item];
        Exit;
      end;

    TRAYMENU_PLAYSTOP:
      begin
        if Chn = nil then
          PlayChannel()
        else
          StopChannel();
      end;

    TRAYMENU_ABOUT:
      begin
        ShowAboutbox();
        Exit;
      end;

    TRAYMENU_EXIT:
      begin
        Form.Close();
      end;
  end;

  SaveConfig();
end;

procedure TForm1.channeltreeMouseUp(Sender: PControl;
  var Mouse: TMouseEventData);
var
  where: Cardinal;
begin
  //# Store where the mouse is for popupmenu
  if Mouse.Button = mbright then
    undermouse := channeltree.TVItemAtPos(Mouse.X, Mouse.Y, where);
end;

function TForm1.LastFMThreadExecute(Sender: PThread): Integer;
begin
  Result := 0;
  with TScrobbler.Create do
  begin
    case Execute(lastTitle) of
      0:
        begin
          traymenu.ItemChecked[TRAYMENU_LASTFM] := False;
          lastfm_enabled := False;
          RaiseError(ErrorStr, False);
        end;
      -1:
        begin
          lastfm_nextscrobb := GetTickCount() + 60000;
        end;
    end;

    Free;
  end;
  lastfm_thread := nil;
end;

procedure TForm1.TrayMouseUp(Sender: PControl; var Mouse: TMouseEventData);
begin
  if (Mouse.Button = mbLeft) then
  begin
    if Form.Visible then
      Form.Hide()
    else
      Form.Show();
  end;
end;

procedure TForm1.btplayClick(Sender: PObj);
begin
  if (Chn = nil) and (ChnOpener = nil) then
    PlayChannel()
  else
    StopChannel();
end;

procedure TForm1.ChangeTrayIcon(NewIcon: HICON; Force: LongBool = False);
begin
  if (traycolor_enabled or Force) and (Tray.Icon <> NewIcon) then
    Tray.Icon := NewIcon;
end;

procedure TForm1.channeltreeSelChange(Sender: PObj);
begin
  PlayChannel();
end;

procedure TForm1.traypopup(const Atitle, Atext: AnsiString;
  const IconType: Integer);
begin
  if traypopup_enabled then
    with Tray^ do
    begin
      BalloonTitle := Atitle;
      BalloonText := Atext;
      ShowBalloon(IconType, 10);
    end;
end;

procedure TForm1.KOLForm1Destroy(Sender: PObj);
begin
  SaveConfig();
  if msn_enabled then
    UpdateMsn(False);

  if lastfm_thread <> nil then
    lastfm_thread.Free;

  if ChnOpener <> nil then
  begin
    ChnOpener.Terminate;
    WaitForSingleObject(ChnOpener.Handle, 1000);
  end;

  if Chn <> nil then
  begin
    Chn.Terminate;
    WaitForSingleObject(Chn.Handle, 1000);
  end;

  radiolist.Free;
  _DS.Free;
end;

function TForm1.KOLForm1Message(var Msg: TMsg; var Rslt: Integer): Boolean;
var
  n: Cardinal;
begin
  Result := False;

  case Msg.message of
    WM_TIMER:
      if Chn <> nil then ProgressExecute();

    WM_HOTKEY:
      case Msg.wParam of
        -2, 2:
          begin
            if curStatus = stPAUSED then
            begin
              curStatus := stPLAYING;
              ProgressExecute(True);
            end;
            curVolume := _DS.Volume(curVolume + Msg.wParam);
            UpdateExecute();
            traypopup('', 'Volume ' + Int2Str(curVolume), NIIF_NONE);
          end;
        1003:
          StopChannel();
        1004:
          if Chn = nil then
          begin
            channeltree.TVSelected := channeltree.TVRoot;
            channeltree.TVSelected := curRadio;
          end
          else
            if curStatus = stPAUSED then
            begin
              curStatus := stPLAYING;
              UpdateExecute();
              ProgressExecute(True);
              _DS.Volume(curVolume);
              traypopup('', 'Resumed', NIIF_NONE);
            end
            else
            begin
              curStatus := stPAUSED;
              UpdateExecute();
              ChangeTrayIcon(ITrayPause, True);
              _DS.Volume(0, False);
              traypopup('', 'Paused', NIIF_NONE);
            end;
        1005, 1006:
          begin
            if Msg.wParam = 1005 then
              n := channeltree.TVItemNext[curRadio]
            else
              n := channeltree.TVItemPrevious[curRadio];
            if n = 0 then
              n := channeltree.TVItemChild[channeltree.TVItemParent[curRadio]];
            channeltree.TVSelected := n;
          end;
        2001..2012:
          if hotkeys[Msg.wParam - 2001] <> 0 then
          begin
            channeltree.TVSelected := channeltree.TVRoot; //# reset selection
            channeltree.TVSelected := hotkeys[Msg.wParam - 2001];
          end;
      end;

    WM_SYSCOMMAND:
      if Msg.wParam = SC_MINIMIZE then
      begin
        Form.Hide;
        Result := True;
      end;

    WM_NOTIFY:
      case Msg.wParam of
        NOTIFY_BUFFER:
          case Msg.lParam of
            BUFFER_OK:
              lblstatus.Caption := 'Connected!';
            BUFFER_RECOVERING:
              lblstatus.Caption := 'Recovering';
          end;

        NOTIFY_CONNECTED:
          begin
            Chn := TRadioPlayer(Msg.lParam);
            curStatus := stPLAYING;
            ChnOpener := nil;
            lblstatus.Caption := 'Prebufering';
            UpdateExecute();
          end;

        NOTIFY_NEWINFO: UpdateExecute();

        NOTIFY_DISCONECT: PlayChannel();

        NOTIFY_OPENERROR:
          begin
            traypopup('Error Connecting', lblradio.Caption, NIIF_ERROR);
            StopChannel();
            lblstatus.caption := 'Error Connecting';
          end;
      end;
  end;
end;

end.



