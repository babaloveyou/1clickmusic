{ KOL MCK }// Do not remove this line!
{$DEFINE KOL_MCK}
unit Unit1;

interface

{$IFDEF KOL_MCK}
uses Windows,
  Messages,
  KOL,
  KOLBAPTrayIcon
{$IF Defined(KOL_MCK)}{$ELSE},
mirror,
Classes,
Controls,
mckControls,
mckObjs,
Graphics,
mckCtrls,
mckBAPTrayIcon
{$IFEND (place your units here->)},
SysUtils;
{$ELSE}
{$I uses.inc}
Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
Dialogs;
{$ENDIF}

type
{$IF Defined(KOL_MCK)}
{$I MCKfakeClasses.inc}
  {$IFDEF KOLCLASSES} {$I TForm1class.inc} {$ELSE OBJECTS} PForm1 = ^TForm1; {$ENDIF CLASSES/OBJECTS}
  {$IFDEF KOLCLASSES}{$I TForm1.inc}{$ELSE} TForm1 = object(TObj) {$ENDIF}
    Form: PControl;
{$ELSE not_KOL_MCK}
  TForm1 = class(TForm)
{$IFEND KOL_MCK}
      KOLProject1: TKOLProject;
      lbltrack: TKOLLabel;
      lblbuffer: TKOLLabel;
      lblstatus: TKOLLabel;
      channeltree: TKOLTreeView;
      lblhelp: TKOLLabel;
      lblradio: TKOLLabel;
      btoptions: TKOLButton;
      KOLForm1: TKOLForm;
      Tray: TKOLBAPTrayIcon;
      btplay: TKOLButton;
      pgrbuffer: TKOLProgressBar;
      procedure KOLForm1Destroy(Sender: PObj);
      procedure KOLForm1FormCreate(Sender: PObj);
      function KOLForm1Message(var Msg: tagMSG; var Rslt: Integer): Boolean;
      procedure channeltreeSelChange(Sender: PObj);
      procedure channeltreeMouseUp(Sender: PControl;
        var Mouse: TMouseEventData);
      procedure btoptionsClick(Sender: PObj);
      procedure TrayMouseUp(Sender: PControl; var Mouse: TMouseEventData);
      procedure btplayClick(Sender: PObj);
    private
    { Private declarations }
    public
      popupmenu: PMenu;
      Thread: PThread;
      LastFMThread: PThread;
      procedure TimerExecute();
      function LastFMThreadExecute(Sender: PThread): Integer;
      function ThreadExecute(Sender: PThread): Integer;
      procedure PlayChannel;
      procedure StopChannel;
      procedure popupproc(Sender: PMenu; Item: Integer);
      procedure LoadConfig;
      procedure SaveConfig;
    end;

  var
    Form1{$IFDEF KOL_MCK}: PForm1{$ELSE}: TForm1{$ENDIF};

{$IFDEF KOL_MCK}
procedure NewForm1(var Result: PForm1; AParent: PControl);
{$ENDIF}

implementation

uses
  Unit2,
  DSoutput,
  radioopener,
  radios_,
  obj_list,
  main,
  utils;


{$IF Defined(KOL_MCK)}{$ELSE}{$R *.DFM}{$IFEND}

{$IFDEF KOL_MCK}
{$I Unit1_1.inc}
{$ENDIF}

procedure Tform1.LoadConfig;
var
  ini: PIniFile;
  i: Integer;
begin
  ini := OpenIniFile('oneclickmusic.ini');
  ini.Mode := ifmRead;
  ini.Section := 'options';
  traypopups_enabled := ini.ValueBoolean('traypopups_enabled', True);
  firstrun_enabled := ini.ValueBoolean('firstrun_enabled', True);
  msn_enabled := ini.ValueBoolean('msn_enabled', False);
  msn_iconi := ini.ValueInteger('msn_iconi', 0);
  msn_icons := ini.ValueString('msn_icons', 'Music');
  list_enabled := ini.ValueBoolean('list_enabled', False);
  list_file := ini.ValueString('list_file', 'lista.txt');
  clipboard_enabled := ini.ValueBoolean('clipboard_enabled', False);
  lastfm_enabled := ini.ValueBoolean('lastfm_enabled', False);
  lastfm_user := ini.ValueString('lastfm_user', '');
  lastfm_pass := Crypt(ini.ValueString('lastfm_pass', ''));

  ini.Section := 'hotkeys';
  ini.Mode := ifmRead;
  for i := 1 to 12 do
  begin
    hotkeys[i] := radiolist.getpos(ini.ValueString(IntToStr(i), ''));
    PopupMenu.ItemText[i - 1] := 'Ctrl+F' + IntToStr(i) + ' :' + #9 + channeltree.TVItemText[hotkeys[i]];
    //PopupMenu.ItemText[i - 1] := 'Ctrl+F' + IntToStr(i) + ' :' + #9 + radiolist.getname(hotkeys[i]);
  end;
  ini.Free;
end;

procedure Tform1.SaveConfig;
var
  ini: PIniFile;
  i: Integer;
begin
  ini := OpenIniFile('oneclickmusic.ini');
  ini.Mode := ifmWrite;
  ini.Section := 'options';
  ini.ValueBoolean('traypopups_enabled', traypopups_enabled);
  ini.ValueBoolean('firstrun_enabled', False);
  ini.ValueBoolean('msn_enabled', msn_enabled);
  ini.ValueInteger('msn_iconi', msn_iconi);
  ini.ValueString('msn_icons', msn_icons);
  ini.ValueBoolean('list_enabled', list_enabled);
  ini.ValueString('list_file', list_file);
  ini.ValueBoolean('clipboard_enabled', clipboard_enabled);
  ini.ValueBoolean('lastfm_enabled', lastfm_enabled);
  ini.ValueString('lastfm_user', lastfm_user);
  ini.ValueString('lastfm_pass', Crypt(lastfm_pass));

  ini.Section := 'hotkeys';
  for i := 1 to 12 do
    ini.ValueString(IntToStr(i), radiolist.getname(hotkeys[i]));
  ini.Free;
end;

procedure TimerProc(Wnd: HWnd; Mesg, TimerID, SysTime: Longint); stdcall;
begin
  if (TimerID = 1) then
    Form1.TimerExecute();
end;

procedure TForm1.TimerExecute();
begin
  if (not Assigned(chn)) or
    (chn.Status = rsStoped) then
    Exit;

  Form.BeginUpdate;

  // # GET INFO
  chn.GetPlayInfo(curTitle, curBitrate, curProgress);

  Tray.Tooltip := curTitle;

  if curTitle = '' then
    Form.Caption := '1ClickMusic'
  else
  begin
    Form.caption := curTitle;
    //# Trow events when track changes
    if curTitle <> lastTitle then
    begin
      lastTitle := curTitle;

      if traypopups_enabled then
      begin
        Tray.BalloonTitle := 'Track change';
        Tray.BalloonText := curTitle;
        Tray.ShowBalloon(NIIF_INFO,3);
      end;

      if msn_enabled then
        updateMSN(True);

      if list_enabled then
        writeFile(list_file, curTitle);

      if clipboard_enabled then
        Text2Clipboard(curTitle);

      if lastfm_enabled then
        if Assigned(LastFMThread) then
          LastFMThread.Resume
        else
          LastFMThread := NewThreadEx(LastFMThreadExecute);
    end;
  end;

  // # REFRESH GUI INFORMATION
  lbltrack.caption := curTitle;

  case curProgress of
    //# skip 0 because of the mms streams
    1..45:
      pgrbuffer.ProgressBkColor := clRed;
    46..75:
      pgrbuffer.ProgressBkColor := clGreen;
  else
    pgrbuffer.ProgressBkColor := $00E39C5A;
  end;
  pgrbuffer.Progress := 100 - curProgress;

  lblbuffer.Caption := IntToStr(curBitrate) + 'kbps' +
    #13#10 + 'vol:' + IntToStr(curVolume) + '%';

  case chn.Status of
    rsPlaying: lblstatus.Caption := 'Connected!';
    rsPrebuffering: lblstatus.Caption := 'Prebufering..';
    rsRecovering: lblstatus.Caption := 'Recovering Buffer!';
  end;

  Form.EndUpdate;
end;

function TForm1.ThreadExecute(Sender: PThread): Integer;
begin
  Result := 1;
  repeat //# JUST BEFORE TRY PLAY!
    channeltree.Enabled := False;

    StopChannel;

    btplay.Caption := 'Stop';
    //# Init timer that refresh GUI info, 500ms interval
    SetTimer(appwinHANDLE, 1, 500, @TimerProc);

    pgrbuffer.Progress := 100;
    pgrbuffer.ProgressBkColor := clRed;
    pgrbuffer.Visible := True;

    lblstatus.Caption := 'Searching...';

    if traypopups_enabled then
    begin
      Tray.BalloonTitle := 'Connecting';
      Tray.BalloonText := lblradio.Caption;
      Tray.ShowBalloon(NIIF_INFO,3);
    end;

    //# Lets Try to play
    if OpenRadio(radiolist.getpls(channeltree.TVItemText[channeltree.TVSelected]), chn, DS) then
    begin //# Radio Opened
      TimerExecute(); //# Refresh GUI INFO
      chn.Play();
    end
    else //# Radio not Opened
    begin
      if traypopups_enabled then
      begin
        Tray.BalloonTitle := 'Error Connecting';
        Tray.BalloonText := lblradio.Caption;
        Tray.ShowBalloon(NIIF_ERROR,3);
      end;
      StopChannel;
      lblstatus.caption := 'Error.:';
    end;
    channeltree.Enabled := True;
    Thread.Suspend;
  until Thread.Terminated;
end;

procedure TForm1.PlayChannel;
begin
  if not channeltree.TVItemHasChildren[channeltree.TVSelected] then
  begin
    lblradio.Caption := channeltree.TVItemText[channeltree.TVSelected];
    Thread.Resume;
  end;
end;

procedure TForm1.StopChannel;
begin
  if msn_enabled then
    updateMSN(False);
  if Assigned(chn) then
    FreeAndNil(chn);

  KillTimer(appwinHANDLE, 1);

  pgrbuffer.Visible := False;
  curProgress := 0;
  curBitrate := 0;
  pgrbuffer.Progress := 100;
  btplay.Caption := 'Play';
  curTitle := '';
  lblbuffer.Caption := '';
  lblstatus.Caption := '';
  lbltrack.Caption := '';
  Tray.ToolTip := '';
  Form.Caption := '1ClickMusic';
end;

function TForm1.KOLForm1Message(var Msg: tagMSG;
  var Rslt: Integer): Boolean;
begin
  Result := False;

  if (Msg.Message = WM_HOTKEY) and (channeltree.Enabled) then
  begin
    case Msg.wParam of
      1001, 3001:
        if Assigned(chn) then
          curVolume := DS.Volume(curVolume + 2);
      1002, 3002:
        if Assigned(chn) then
        begin
          curVolume := DS.Volume(curVolume - 2);
        end;
      1003, 3003:
        StopChannel;
      1004, 3004:
        if not Assigned(chn) then
          PlayChannel;
      2001..2012:
        if hotkeys[Msg.wParam - 2000] > 0 then
        begin
          channeltree.TVSelected := channeltree.TVRoot; //# reset selection
          channeltree.TVSelected := hotkeys[Msg.wParam - 2000];
        end;
    end;
  end
  else
    if (Msg.Message = WM_SYSCOMMAND) and (Msg.wParam = SC_MINIMIZE) then
    begin
      form.Hide;
      Result := True;
    end;
end;

procedure TForm1.KOLForm1Destroy(Sender: PObj);
begin
  if msn_enabled then
    updateMSN(False);

  if Assigned(LastFMThread) then
  begin
    LastFMThread.Terminate;
    LastFMThread.Free;
  end;

  //# Kill the GUI timer, it exists? I don't care!
  KillTimer(appwinHANDLE, 1);

  Thread.Terminate;
  Thread.Free;

  if Assigned(chn) then
    chn.Free;

  DS.Free;
  //# Save .INI config
  SaveConfig;
  radiolist.Free;
end;

procedure TForm1.KOLForm1FormCreate(Sender: PObj);
var
  i: Integer;
begin
  appwinHANDLE := form.Handle;
  //# Inicializa o SOM
  curVolume := 100;
  chn := nil;
  DS := TDSoutput.Create(appwinHANDLE);

  Tray.Icon := LoadIcon(HInstance, 'TRAY');
  Tray.Active := True;

  //# HOTKEYS
  RegisterHotKey(appwinHANDLE, 1001, MOD_CONTROL, VK_UP);
  //RegisterHotKey(appwinHANDLE, 3001, 0, $AF);
  RegisterHotKey(appwinHANDLE, 1002, MOD_CONTROL, VK_DOWN);
  //RegisterHotKey(appwinHANDLE, 3002, 0, $AE);
  RegisterHotKey(appwinHANDLE, 1003, MOD_CONTROL, VK_END);
  //RegisterHotKey(appwinHANDLE, 3003, 0, $B2);
  RegisterHotKey(appwinHANDLE, 1004, MOD_CONTROL, VK_HOME);
  //RegisterHotKey(appwinHANDLE, 3004, 0, $B3);
  RegisterHotKey(appwinHANDLE, 2001, MOD_CONTROL, VK_F1);
  RegisterHotKey(appwinHANDLE, 2002, MOD_CONTROL, VK_F2);
  RegisterHotKey(appwinHANDLE, 2003, MOD_CONTROL, VK_F3);
  RegisterHotKey(appwinHANDLE, 2004, MOD_CONTROL, VK_F4);
  RegisterHotKey(appwinHANDLE, 2005, MOD_CONTROL, VK_F5);
  RegisterHotKey(appwinHANDLE, 2006, MOD_CONTROL, VK_F6);
  RegisterHotKey(appwinHANDLE, 2007, MOD_CONTROL, VK_F7);
  RegisterHotKey(appwinHANDLE, 2008, MOD_CONTROL, VK_F8);
  RegisterHotKey(appwinHANDLE, 2009, MOD_CONTROL, VK_F9);
  RegisterHotKey(appwinHANDLE, 2010, MOD_CONTROL, VK_F10);
  RegisterHotKey(appwinHANDLE, 2011, MOD_CONTROL, VK_F11);
  RegisterHotKey(appwinHANDLE, 2012, MOD_CONTROL, VK_F12);

  //# Create the thread that open the radio
  Thread := NewThread;
  Thread.OnExecute := ThreadExecute;

  //# KOL puro jah que a mck nao que funfar
  PopupMenu := NewMenu(channeltree, 0, ['Ctrl+F1', 'Ctrl+F2', 'Ctrl+F3', 'Ctrl+F4', 'Ctrl+F5', 'Ctrl+F6', 'Ctrl+F7', 'Ctrl+F8', 'Ctrl+F9', 'Ctrl+F10', 'Ctrl+F11', 'Ctrl+F12', 'Clear Hotkeys'], nil);
  for i := 0 to 12 do
    PopupMenu.AssignEvents(i, [popupproc]);
  //# define o popup da channeltree
  channeltree.SetAutoPopupMenu(PopupMenu);

  //# Cria lista de radios
  Radiolist := NewRadioList;

  //# inicializa os canais
  for i := 0 to High(genrelist) do
    genreid[i] := channeltree.TVInsert(0, 0, genrelist[i]);

  for i := 0 to High(chn_eletronic) do
    radiolist.Add(
      channeltree.TVInsert(genreid[ELETRONIC], 0, chn_eletronic[i]),
      chn_eletronic[i],
      Crypt(pls_eletronic[i])
      );

  for i := 0 to High(chn_rockmetal) do
    radiolist.Add(
      channeltree.TVInsert(genreid[ROCKMETAL], 0, chn_rockmetal[i]),
      chn_rockmetal[i],
      Crypt(pls_rockmetal[i])
      );

  for i := 0 to High(chn_ecletic) do
    radiolist.Add(
      channeltree.TVInsert(genreid[ECLETIC], 0, chn_ecletic[i]),
      chn_ecletic[i],
      Crypt(pls_ecletic[i])
      );

  for i := 0 to High(chn_hiphop) do
    radiolist.Add(
      channeltree.TVInsert(genreid[HIPHOP], 0, chn_hiphop[i]),
      chn_hiphop[i],
      Crypt(pls_hiphop[i])
      );

  for i := 0 to High(chn_oldmusic) do
    radiolist.Add(
      channeltree.TVInsert(genreid[OLDMUSIC], 0, chn_oldmusic[i]),
      chn_oldmusic[i],
      Crypt(pls_oldmusic[i])
      );

  for i := 0 to High(chn_industrial) do
    radiolist.Add(
      channeltree.TVInsert(genreid[INDUSTRIAL], 0, chn_industrial[i]),
      chn_industrial[i],
      Crypt(pls_industrial[i])
      );

  for i := 0 to High(chn_misc) do
    radiolist.Add(
      channeltree.TVInsert(genreid[MISC], 0, chn_misc[i]),
      chn_misc[i],
      Crypt(pls_misc[i])
      );

  for i := 0 to High(chn_brasil) do
    radiolist.Add(
      channeltree.TVInsert(genreid[BRASIL], 0, chn_brasil[i]),
      chn_brasil[i],
      Crypt(pls_brasil[i])
      );

  //# Sort Radio List
  for i := 0 to High(genreid) do
    channeltree.TVSort(genreid[i]);

  channeltree.TVSelected := channeltree.TVRoot;

  //# Load .INI Config
  LoadConfig;
  //# Show About box if first run or just updated!
  if firstrun_enabled then showaboutbox;
end;

procedure TForm1.channeltreeSelChange(Sender: PObj);
begin
  PlayChannel;
end;

procedure TForm1.popupproc(Sender: PMenu; Item: Integer);
begin
  if Item = 12 then
  begin
    for Item := 0 to 11 do
    begin
      hotkeys[Item + 1] := 0;
      PopupMenu.ItemText[Item] := 'Ctrl+F' + IntToStr(Item + 1);
    end;
  end
  else
    if not channeltree.TVItemHasChildren[undermouse] then
    begin
      if hotkeys[Item + 1] = undermouse then
      begin
        hotkeys[Item + 1] := 0;
        PopupMenu.ItemText[Item] := 'Ctrl+F' + IntToStr(Item + 1);
      end
      else
      begin
        hotkeys[Item + 1] := undermouse;
        PopupMenu.ItemText[Item] := 'Ctrl+F' + IntToStr(Item + 1) + ' :' + #9 + channeltree.TVItemText[undermouse];
      end;
    end;
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

procedure TForm1.btoptionsClick(Sender: PObj);
begin
  //# create and show
  Form.AlphaBlend := 180;
  NewForm2(Form2, Form);
  Form2.Form.ShowModal;
  //# get rid of it and set alpha back to 255
  Form2.Form.Free;
  Form2 := nil;
  Form.AlphaBlend := 255;
end;

function TForm1.LastFMThreadExecute(Sender: PThread): Integer;
begin
  Result := 1;
  repeat
    sleep(35000);
    LastFMexecute;
    Sender.Suspend;
  until LastFMThread.Terminated;
end;

procedure TForm1.TrayMouseUp(Sender: PControl; var Mouse: TMouseEventData);
begin
  if (Mouse.Button = mbRight) or (Mouse.Button = mbLeft) then
  begin
    if Form.Visible then
      Form.Hide
    else
    begin
      Form.Show;
      TimerExecute(); //# Refresh GUI INFO
      Form.Focused := True;
    end;
  end
  else
    showaboutbox;
end;

procedure TForm1.btplayClick(Sender: PObj);
begin
  if channeltree.Enabled then
    if not Assigned(chn) then
      PlayChannel
    else
      StopChannel;
end;

end.

