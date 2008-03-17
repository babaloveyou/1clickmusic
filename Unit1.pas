{ KOL MCK }// Do not remove this line!
{$DEFINE KOL_MCK}
unit Unit1;

interface

{$IFDEF KOL_MCK}
uses Windows, Messages, KOL, KOLBAPTrayIcon{$IFNDEF KOL_MCK}, mirror, Classes, Controls, mckControls, mckObjs, Graphics, mckCtrls,
  mckBAPTrayIcon{$ENDIF (place your units here->)};
{$ELSE}
{$I uses.inc}
Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
Dialogs;
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
    Timer: TKOLTimer;
    lbltrack: TKOLLabel;
    lblbuffer: TKOLLabel;
    lblstatus: TKOLLabel;
    channeltree: TKOLTreeView;
    lblhelp: TKOLLabel;
    lblradio: TKOLLabel;
    PopupMenu: TKOLPopupMenu;
    btoptions: TKOLButton;
    KOLForm1: TKOLForm;
    Tray: TKOLBAPTrayIcon;
    procedure TimerTimer(Sender: PObj);
    procedure KOLForm1Destroy(Sender: PObj);
    procedure KOLForm1FormCreate(Sender: PObj);
    function KOLForm1Message(var Msg: tagMSG; var Rslt: Integer): Boolean;
    procedure channeltreeSelChange(Sender: PObj);
    procedure channeltreeMouseUp(Sender: PControl;
      var Mouse: TMouseEventData);
    procedure btoptionsClick(Sender: PObj);
    procedure TrayMouseUp(Sender: PControl; var Mouse: TMouseEventData);
  private
    { Private declarations }
  public
    Thread: PThread;
    LastFMThread: PThread;
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

uses SysUtils, Unit2, DSoutput, radioplayer, radios, obj_list, obj_playlist, main, EncryptIt;

var
  // Core
  DS: TDSoutput;
  chn: TRadioPlayer;
  vol: Cardinal = 100;
  progress: Cardinal;

  {$IFNDEF KOL_MCK}{$R *.DFM}{$ENDIF}

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
  firstrun_enabled := ini.ValueBoolean('firstrun_enabled', True);
  msn_enabled := ini.ValueBoolean('msn_enabled', False);
  msn_iconi := ini.ValueInteger('msn_iconi', 0);
  msn_icons := ini.ValueString('msn_icons', 'Music');
  list_enabled := ini.ValueBoolean('list_enabled', False);
  list_file := ini.ValueString('list_file', 'lista.txt');
  clipboard_enabled := ini.ValueBoolean('clipboard_enabled', False);
  lastfm_enabled := ini.ValueBoolean('lastfm_enabled', False);
  lastfm_user := ini.ValueString('lastfm_user', '');
  lastfm_pass := Decrypt(ini.ValueString('lastfm_pass', ''), KEYCODE);

  ini.Section := 'hotkeys';
  ini.Mode := ifmRead;
  for i := 1 to 12 do
  begin
    hotkeys[i] := radiolist.getpos(ini.ValueString(Int2Str(i), ''));
    PopupMenu.ItemText[i - 1] := 'Ctrl+F' + Int2Str(i) + ' :' + #9 + channeltree.TVItemText[hotkeys[i]];
    //PopupMenu.ItemText[i - 1] := 'Ctrl+F' + Int2Str(i) + ' :' + #9 + radiolist.getname(hotkeys[i]);
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
  ini.ValueBoolean('firstrun_enabled', False);
  ini.ValueBoolean('msn_enabled', msn_enabled);
  ini.ValueInteger('msn_iconi', msn_iconi);
  ini.ValueString('msn_icons', msn_icons);
  ini.ValueBoolean('list_enabled', list_enabled);
  ini.ValueString('list_file', list_file);
  ini.ValueBoolean('clipboard_enabled', False);
  ini.ValueBoolean('lastfm_enabled', lastfm_enabled);
  ini.ValueString('lastfm_user', lastfm_user);
  ini.ValueString('lastfm_pass', Encrypt(lastfm_pass, KEYCODE));

  ini.Section := 'hotkeys';
  for i := 1 to 12 do
    ini.ValueString(Int2Str(i), radiolist.getname(hotkeys[i]));
  ini.Free;
end;

procedure TForm1.TimerTimer(Sender: PObj);
begin
  if (not Assigned(chn)) or
    (chn.Status = rsStoped) then
    Exit;


  // # EVENTS & TRAY ICON CONTROL
  chn.GetPlayInfo(curTitle, curBitrate);

  Tray.Tooltip := curTitle;

  if curTitle = '' then
    Form.Caption := '1ClickMusic'
  else
  begin
    Form.caption := curTitle;
    // Trow events when track changes
    if curTitle <> lastTitle then
    begin
      lastTitle := curTitle;

      Tray.BalloonTitle := 'Track change';
      Tray.BalloonText := curTitle;
      Tray.ShowBalloon(_NIIF_INFO);

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

  if not form.Visible then Exit;
  // # REFRESH GUI INFORMATION
  
  lbltrack.caption := curTitle;
  
  progress := chn.GetBufferPercentage;
  
  case progress of
    0..45:
      lblbuffer.Font.Color := clRed;
    46..70:
      lblbuffer.Font.Color := clGreen;
  else
    lblbuffer.Font.Color := clBlue;
  end;

  lblbuffer.Caption :=
    UInt2Str(curBitrate) + 'kbps @ buffer:. ' + UInt2Str(progress) + '%';

  case chn.Status of
    rsPlaying: lblstatus.Caption := 'Connected';
    rsPrebuffering: lblstatus.Caption := 'Prebufering..';
    rsRecovering: lblstatus.Caption := 'Recovering buffer..';
  end;
end;

function TForm1.ThreadExecute(Sender: PThread): Integer;
begin
  Result := 1;
  repeat
    channeltree.Enabled := False;
    progress := 0;
    curTitle := '';

    StopChannel;

    lblstatus.Caption := 'Searching...';

    if not OpenRadio(radiolist.getpls(channeltree.TVItemText[channeltree.TVSelected]), chn, DS) then
    begin
      StopChannel;
      lblstatus.caption := 'error.: try another channel'
    end
    else
    begin
      TimerTimer(nil);
      chn.Play();
    end;
    channeltree.Enabled := True;
    Thread.Suspend;
  until Thread.Terminated;
end;

procedure TForm1.PlayChannel;
begin
  lblradio.Caption := channeltree.TVItemText[channeltree.TVSelected];
  Form.Caption := '1ClickMusic';
  Thread.Resume;
end;

procedure TForm1.StopChannel;
begin
  if msn_enabled then
    updateMSN(False);
  if Assigned(chn) then
    FreeAndNil(chn);
  curBitrate := 0;
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
  if (Msg.Message = WM_HOTKEY) and (Thread.Suspended) then
  begin
    case Msg.wParam of
      1001, 3001: if Assigned(chn) then chn.Volume(100);
      1002, 3002: if Assigned(chn) then chn.Volume(-100);
      1003, 3003:
        StopChannel;
      1004, 3004:
        if not Assigned(chn) then
          PlayChannel;
      2001..2012:
        if hotkeys[Msg.wParam - 2000] > 0 then
        begin
          channeltree.TVSelected := hotkeys[Msg.wParam - 2000];
          PlayChannel;
        end;
    end;
  end
  else
    if (Msg.Message = WM_SYSCOMMAND) and (Msg.wParam = SC_MINIMIZE) then
    begin
      form.Hide;
      timer.Interval := 1000;
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

  Thread.Terminate;
  Thread.Free;

  if Assigned(chn) then
    chn.Free;
  DS.Free;
  //
  SaveConfig;
  channeltree.Free;
  pls.Free;
  radiolist.Free;
end;

procedure TForm1.KOLForm1FormCreate(Sender: PObj);
var
  i: Integer;
  loading, lbl: PControl;
begin

  loading := NewForm(Form, '');
  loading.HasBorder := False;
  loading.BoundsRect := form.BoundsRect;
  loading.Color := clBlack;
  loading.AlphaBlend := 220;
  lbl := NewLabel(loading, 'LOADING -> RADIO LIBRARY!');
  lbl.Align := caClient;
  lbl.TextAlign := taCenter;
  lbl.VerticalAlign := vaCenter;
  lbl.Font.FontHeight := 32;
  lbl.Font.Color := clWhite;
  lbl.Color := clBlack;
  loading.CreateWindow;
  lbl.Update;

  Tray.Icon := form.Icon;
  Tray.AddIcon;

  //HOTKEYS
  RegisterHotKey(form.Handle, 1001, MOD_CONTROL, VK_UP);
  RegisterHotKey(form.Handle, 3001, MOD_CONTROL, $AF);
  RegisterHotKey(form.Handle, 1002, MOD_CONTROL, VK_DOWN);
  RegisterHotKey(form.Handle, 3002, MOD_CONTROL, $AE);
  RegisterHotKey(form.Handle, 1003, MOD_CONTROL, VK_END);
  RegisterHotKey(form.Handle, 3003, MOD_CONTROL, $B2);
  RegisterHotKey(form.Handle, 1004, MOD_CONTROL, VK_HOME);
  RegisterHotKey(form.Handle, 3004, MOD_CONTROL, $B3);
  RegisterHotKey(form.Handle, 2001, MOD_CONTROL, VK_F1);
  RegisterHotKey(form.Handle, 2002, MOD_CONTROL, VK_F2);
  RegisterHotKey(form.Handle, 2003, MOD_CONTROL, VK_F3);
  RegisterHotKey(form.Handle, 2004, MOD_CONTROL, VK_F4);
  RegisterHotKey(form.Handle, 2005, MOD_CONTROL, VK_F5);
  RegisterHotKey(form.Handle, 2006, MOD_CONTROL, VK_F6);
  RegisterHotKey(form.Handle, 2007, MOD_CONTROL, VK_F7);
  RegisterHotKey(form.Handle, 2008, MOD_CONTROL, VK_F8);
  RegisterHotKey(form.Handle, 2009, MOD_CONTROL, VK_F9);
  RegisterHotKey(form.Handle, 2010, MOD_CONTROL, VK_F10);
  RegisterHotKey(form.Handle, 2011, MOD_CONTROL, VK_F11);
  RegisterHotKey(form.Handle, 2012, MOD_CONTROL, VK_F12);

  // Cria thread
  Thread := NewThread;
  Thread.OnExecute := ThreadExecute;

  // Cria playlist
  pls := TPlaylist.Create;

  // KOL puro jah que a mck nao que funfar
  PopupMenu := NewMenu(Form, 0, ['Ctrl+F1', 'Ctrl+F2', 'Ctrl+F3', 'Ctrl+F4', 'Ctrl+F5', 'Ctrl+F6', 'Ctrl+F7', 'Ctrl+F8', 'Ctrl+F9', 'Ctrl+F10', 'Ctrl+F11', 'Ctrl+F12', 'Clear Hotkeys'], nil);
  for i := 0 to 12 do
    PopupMenu.AssignEvents(i, [popupproc]);
  // define o popup da channeltree
  channeltree.SetAutoPopupMenu(PopupMenu);

  // Cria lista de radios
  Radiolist := NewRadioList;

  // inicializa os canais
  for i := 0 to High(genrelist) do
    genreid[i] := channeltree.TVInsert(0, 0, genrelist[i]);

  for i := 0 to High(chn_eletronic) do
    radiolist.Add(
      channeltree.TVInsert(genreid[ELETRONIC], 0, chn_eletronic[i]),
      chn_eletronic[i],
      pls_eletronic[i]
      );

  for i := 0 to High(chn_rockmetal) do
    radiolist.Add(
      channeltree.TVInsert(genreid[ROCKMETAL], 0, chn_rockmetal[i]),
      chn_rockmetal[i],
      pls_rockmetal[i]
      );

  for i := 0 to High(chn_ecletic) do
    radiolist.Add(
      channeltree.TVInsert(genreid[ECLETIC], 0, chn_ecletic[i]),
      chn_ecletic[i],
      pls_ecletic[i]
      );

  for i := 0 to High(chn_hiphop) do
    radiolist.Add(
      channeltree.TVInsert(genreid[HIPHOP], 0, chn_hiphop[i]),
      chn_hiphop[i],
      pls_hiphop[i]
      );

  for i := 0 to High(chn_oldmusic) do
    radiolist.Add(
      channeltree.TVInsert(genreid[OLDMUSIC], 0, chn_oldmusic[i]),
      chn_oldmusic[i],
      pls_oldmusic[i]
      );

  for i := 0 to High(chn_industrial) do
    radiolist.Add(
      channeltree.TVInsert(genreid[INDUSTRIAL], 0, chn_industrial[i]),
      chn_industrial[i],
      pls_industrial[i]
      );

  for i := 0 to High(chn_misc) do
    radiolist.Add(
      channeltree.TVInsert(genreid[MISC], 0, chn_misc[i]),
      chn_misc[i],
      pls_misc[i]
      );

  for i := 0 to High(chn_brasil) do
    radiolist.Add(
      channeltree.TVInsert(genreid[BRASIL], 0, chn_brasil[i]),
      chn_brasil[i],
      pls_brasil[i]
      );

  for i := 0 to High(genreid) do
    channeltree.TVSort(genreid[i]);

  LoadConfig;

  lbl.Caption := 'LOADING -> SOUND ENGINE!';
  lbl.Update;
  // Inicializa o SOM
  DS := TDSoutput.Create;

  loading.Free;

  if firstrun_enabled then showaboutbox;
end;

procedure TForm1.channeltreeSelChange(Sender: PObj);
begin
  if channeltree.TVItemChildCount[channeltree.TVSelected] = 0 then
    PlayChannel;
end;

procedure TForm1.popupproc(Sender: PMenu; Item: Integer);
begin
  if Item = 12 then
  begin
    for Item := 0 to 11 do
    begin
      hotkeys[Item + 1] := 0;
      PopupMenu.ItemText[Item] := 'Ctrl+F' + Int2Str(Item + 1);
    end;
  end
  else
    if channeltree.TVItemChildCount[undermouse] = 0 then
    begin
      if hotkeys[Item + 1] = undermouse then
      begin
        hotkeys[Item + 1] := 0;
        PopupMenu.ItemText[Item] := 'Ctrl+F' + Int2Str(Item + 1);
      end
      else
      begin
        hotkeys[Item + 1] := undermouse;
        PopupMenu.ItemText[Item] := 'Ctrl+F' + Int2Str(Item + 1) + ' :' + #9 + channeltree.TVItemText[undermouse];
      end;
    end;
end;

procedure TForm1.channeltreeMouseUp(Sender: PControl;
  var Mouse: TMouseEventData);
var
  where: Cardinal;
begin
  if Mouse.Button = mbright then
    undermouse := channeltree.TVItemAtPos(Mouse.X, Mouse.Y, where);
end;

procedure TForm1.btoptionsClick(Sender: PObj);
begin
  // create and show
  Form.AlphaBlend := 180;
  NewForm2(Form2, Form);
  Form2.Form.ShowModal;
  // get rid of it and set alpha back to 255
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
    LastFMThread.Suspend;
  until LastFMThread.Terminated;
end;

procedure TForm1.TrayMouseUp(Sender: PControl; var Mouse: TMouseEventData);
begin
  if (Mouse.Button = mbRight) or (Mouse.Button = mbLeft) then
  begin
    if Form.Visible then
    begin
      Form.Hide;
      Timer.Interval := 1000;
    end
    else
    begin
      Timer.Interval := 250;
      Form.Show;
      TimerTimer(nil); //# Refresh GUI INFO
      Form.Focused := True;
    end;
  end
  else
    showaboutbox;
end;

end.


