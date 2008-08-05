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
      procedure channeltreeMouseUp(Sender: PControl;
        var Mouse: TMouseEventData);
      procedure btoptionsClick(Sender: PObj);
      procedure TrayMouseUp(Sender: PControl; var Mouse: TMouseEventData);
      procedure btplayClick(Sender: PObj);
      function channeltreeTVSelChanging(Sender: PControl; oldItem,
        newItem: Cardinal): Boolean;
      procedure channeltreeSelChange(Sender: PObj);
    private
    { Private declarations }
    public
      ITRAY, ITrayBlue, ITrayGreen, ITrayRed: HICON;
      popupmenu: PMenu;
      Thread: PThread;
      procedure ProgressExecute();
      procedure UpdateExecute();
      function LastFMThreadExecute(Sender: PThread): Integer;
      function ThreadExecute(Sender: PThread): Integer;
      procedure ChangeTrayIcon(const NewIcon: HICON);
      procedure traypopup(const Atitle, Atext: string; const IconType: Integer);
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
  obj_list,
  obj_scrobber,
  main,
  utils,
  obj_db;


{$IF Defined(KOL_MCK)}{$ELSE}{$R *.DFM}{$IFEND}

{$IFDEF KOL_MCK}
{$I Unit1_1.inc}
{$ENDIF}

procedure Tform1.LoadConfig;
var
  i: Integer;
begin
  with OpenIniFile('oneclickmusic.ini')^ do
  begin
    Mode := ifmRead;
    Section := 'options';
    trayiconcolor_enabled := ValueBoolean('trayiconcolor_enabled', True);
    traypopups_enabled := ValueBoolean('traypopups_enabled', True);
    firstrun_enabled := ValueBoolean('firstrun_enabled', True);
    msn_enabled := ValueBoolean('msn_enabled', False);
    msn_iconi := ValueInteger('msn_iconi', 0);
    msn_icons := ValueString('msn_icons', 'Music');
    list_enabled := ValueBoolean('list_enabled', False);
    list_file := ValueString('list_file', 'lista.txt');
    clipboard_enabled := ValueBoolean('clipboard_enabled', False);
    lastfm_enabled := ValueBoolean('lastfm_enabled', False);
    lastfm_user := ValueString('lastfm_user', '');
    lastfm_pass := Crypt(ValueString('lastfm_pass', ''));
    proxy_enabled := ValueBoolean('proxy_enabled', False);
    proxy_host := ValueString('proxy_host', '');
    proxy_port := ValueString('proxy_port', '');

    Section := 'hotkeys';
    for i := 1 to 12 do
    begin
      hotkeys[i] := radiolist.getpos(ValueString(IntToStr(i), ''));
      PopupMenu.ItemText[i - 1] := 'Ctrl+F' + IntToStr(i) + ' :' + #9 + radiolist.getname(hotkeys[i]);
    end;
    Free;
  end;
end;

procedure Tform1.SaveConfig;
var
  i: Integer;
begin
  with OpenIniFile('oneclickmusic.ini')^ do
  begin
    Mode := ifmWrite;
    Section := 'options';
    ValueBoolean('trayiconcolor_enabled', trayiconcolor_enabled);
    ValueBoolean('traypopups_enabled', traypopups_enabled);
    ValueBoolean('firstrun_enabled', False);
    ValueBoolean('msn_enabled', msn_enabled);
    ValueInteger('msn_iconi', msn_iconi);
    ValueString('msn_icons', msn_icons);
    ValueBoolean('list_enabled', list_enabled);
    ValueString('list_file', list_file);
    ValueBoolean('clipboard_enabled', clipboard_enabled);
    ValueBoolean('lastfm_enabled', lastfm_enabled);
    ValueString('lastfm_user', lastfm_user);
    ValueString('lastfm_pass', Crypt(lastfm_pass));
    ValueBoolean('proxy_enabled', proxy_enabled);
    ValueString('proxy_host', proxy_host);
    ValueString('proxy_port', proxy_port);

    Section := 'hotkeys';
    for i := 1 to 12 do
      ValueString(IntToStr(i), radiolist.getname(hotkeys[i]));

    Free;
  end;
end;

procedure TForm1.ProgressExecute();
var
  progress: Integer;
begin
  // # GET INFO
  Chn.GetProgress(progress);
  if progress = curProgress then Exit;

  case progress of
    0..40:
      begin
        ChangeTrayIcon(ITrayRed);
        pgrbuffer.ProgressBkColor := clRed;
      end;
    41..75:
      begin
        ChangeTrayIcon(ITrayGreen);
        pgrbuffer.ProgressBkColor := clGreen;
      end;
  else
    begin
      ChangeTrayIcon(ITrayBlue);
      pgrbuffer.ProgressBkColor := $00E39C5A;
    end;
  end;
  pgrbuffer.Progress := 100 - progress;
  curProgress := progress;
end;

procedure TForm1.UpdateExecute();
begin
  Form.BeginUpdate;

  Chn.GetInfo(curTitle,curBitrate);

  //# Trow events when track changes
  if curTitle <> lastTitle then
    if curTitle = '' then
      Form.Caption := '1ClickMusic'
    else
    begin
      Tray.Tooltip := curTitle;
      Form.caption := curTitle;
      lastTitle := curTitle;

      traypopup('Track change', curTitle, NIIF_INFO);

      if msn_enabled then
        updateMSN(True);

      if list_enabled then
        writeFile(list_file, curTitle);

      if clipboard_enabled then
        Text2Clipboard(curTitle);

      if (lastfm_enabled) and // ENSURE 60sec interval
        (GetTickCount >= lastfm_nextscrobb) then
      begin
        lastfm_nextscrobb := GetTickCount() + 60000;
        NewThreadAutoFree(LastFMThreadExecute);
      end;
    end;

  // # REFRESH GUI INFORMATION
  lbltrack.caption := curTitle;

  lblbuffer.Caption := IntToStr(curBitrate) + 'kbps' +
    #13 + 'vol:' + IntToStr(curVolume) + '%';

  case Chn.Status of
    rsPlaying: lblstatus.Caption := 'Connected!';
    rsPrebuffering: lblstatus.Caption := 'Prebufering';
    rsRecovering: lblstatus.Caption := 'Recovering';
  end;

  Form.EndUpdate;
end;

function TForm1.ThreadExecute(Sender: PThread): Integer;
begin
  Result := 1;
  repeat //# JUST BEFORE TRY PLAY!
    channeltree.Enabled := False;
    btplay.Enabled := False;

    StopChannel;

    btplay.Caption := 'Stop';
    //# Init timer that refresh the progress bar, 500ms interval
    SetTimer(appwinHANDLE, 1, 500, nil);

    pgrbuffer.Progress := 100;
    pgrbuffer.ProgressBkColor := clRed;
    pgrbuffer.Visible := True;

    lblstatus.Caption := 'Searching...';

    traypopup('Connecting', lblradio.Caption, NIIF_INFO);

    //# Lets Try to play
    if not OpenRadio(radiolist.getpls(channeltree.TVSelected), Chn, DS) then
    begin
      traypopup('Error Connecting', lblradio.Caption, NIIF_ERROR);
      StopChannel;
      lblstatus.caption := 'Error Connecting';
    end;
    channeltree.Enabled := True;
    btplay.Enabled := True;
    Sender.Suspend;
  until Sender.Terminated;
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
  if Chn <> nil then
    FreeAndNil(Chn);

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
  ChangeTrayIcon(ITRAY);
end;

function TForm1.KOLForm1Message(var Msg: tagMSG;
  var Rslt: Integer): Boolean;
begin
  Result := False;

  if (Msg.message = WM_TIMER) and (Chn <> nil) then
    ProgressExecute()
  else
    if (Msg.Message = WM_HOTKEY) and (channeltree.Enabled) then
    begin
      case Msg.wParam of
         -2,2:
          if Chn <> nil then
          begin
            curVolume := DS.Volume(curVolume + Msg.wParam);
            UpdateExecute();
            traypopup('', 'Volume ' + IntToStr(curVolume) + '%', NIIF_NONE);
          end;
        1003:
          StopChannel;
        1004:
          if Chn = nil then
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
      end
      else
        if (Msg.message = WM_USER) and (Msg.wParam = Integer(Chn)) then
        begin
          if Msg.lParam <> 0 then // We have something to update!
            UpdateExecute()
          else
          begin
            StopChannel;
            lblstatus.Text := 'Disconected!';
          end;
        end;
end;

procedure TForm1.KOLForm1Destroy(Sender: PObj);
begin
  if msn_enabled then
    updateMSN(False);

  //# Kill the GUI timer, it exists? I don't care!
  KillTimer(appwinHANDLE, 1);

  Thread.Free;

  if Chn <> nil then
    Chn.Free;

  DS.Free;
  //# Save .INI config
  SaveConfig;
  radiolist.Free;
end;

function TreeListWndProc(Sender: PControl; var Msg: TMsg; var Rslt: Integer): Boolean;
type
  TNMTVCUSTOMDRAW = packed record
    nmcd: TNMCustomDraw;
    clrText: COLORREF;
    clrTextBk: COLORREF;
    iLevel: Integer;
  end;
  PNMTVCustomDraw = ^TNMTVCustomDraw;
begin
  Result := False;
  if (Msg.message = WM_NOTIFY) and (PNMHdr(Msg.lParam).code = NM_CUSTOMDRAW) then
  begin
    Result := True;

    case PNMTVCUSTOMDRAW(Msg.lParam).nmcd.dwDrawStage of
      CDDS_PREPAINT:
        begin
          Rslt := CDRF_NOTIFYITEMDRAW;
        end;

      CDDS_ITEMPREPAINT:
        begin
          with PNMTVCUSTOMDRAW(Msg.lParam)^ do
            if (iLevel = 1) and (nmcd.uItemState and CDIS_SELECTED = CDIS_SELECTED) then
            begin
              with Sender^ do
              begin
                Canvas.Brush.Color := clSkyBlue;
                Canvas.Font.Color := clBlue;
                Canvas.Font.FontStyle := [fsBold];
                Canvas.FillRect(nmcd.rc);
                with TVItemRect[nmcd.dwItemSpec, True] do
                  canvas.TextOut(Left + 2, Top + 1, TVItemText[nmcd.dwItemSpec]);
              end;
              Rslt := CDRF_SKIPDEFAULT;
            end
            else rslt := CDRF_DODEFAULT;
        end;
    else
      rslt := CDRF_DODEFAULT;
    end
  end;
end;

procedure TForm1.KOLForm1FormCreate(Sender: PObj);
begin
  appwinHANDLE := form.Handle;
  //# Inicializa o SOM
  DS := TDSoutput.Create(appwinHANDLE);

  ITRAY := LoadIcon(HInstance, 'TRAY'); // gray icon
  ITrayBlue := LoadIcon(HInstance, 'TRAYBLUE');
  ITrayGreen := LoadIcon(HInstance, 'TRAYGREEN');
  ITrayRed := LoadIcon(HInstance, 'TRAYRED');

  Tray.Icon := ITRAY;
  Tray.Active := True;

  //# HOTKEYS
  RegisterHotKey(appwinHANDLE, 2, MOD_CONTROL, VK_UP);
  RegisterHotKey(appwinHANDLE, -2, MOD_CONTROL, VK_DOWN);
  RegisterHotKey(appwinHANDLE, 1003, MOD_CONTROL, VK_END);
  RegisterHotKey(appwinHANDLE, 1004, MOD_CONTROL, VK_HOME);
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

  //# KOL puro Menu
  PopupMenu := NewMenu(channeltree, 0, ['Ctrl+F1', 'Ctrl+F2', 'Ctrl+F3', 'Ctrl+F4', 'Ctrl+F5', 'Ctrl+F6', 'Ctrl+F7', 'Ctrl+F8', 'Ctrl+F9', 'Ctrl+F10', 'Ctrl+F11', 'Ctrl+F12', 'Clear Hotkeys'], popupproc);
  //# define o popup da channeltree
  channeltree.SetAutoPopupMenu(PopupMenu);

  //# Cria lista de radios
  Radiolist := TRadioList.Create;
  //# inicializa os canais e o message handler
  LoadDb(channeltree, radiolist);
  LoadCustomDb(channeltree,radiolist,'c:/userradios.txt');
  channeltree.AttachProc(TreeListWndProc);
  //# close the treeview
  channeltree.TVSelected := channeltree.TVRoot;
  channeltree.TVExpand(channeltree.TVRoot, TVE_COLLAPSE);

  //# Load .INI Config
  LoadConfig;
  //# Show About box if first run or just updated!
  if firstrun_enabled then showaboutbox;
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
  SaveConfig;
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
  Form.AlphaBlend := 255;
  Form2.Form.Free;
  Form2 := nil;
end;

function TForm1.LastFMThreadExecute(Sender: PThread): Integer;
begin
  Result := 1;
  with TScrobber.Create do
  begin
    if not Execute(lastTitle) then
      RaiseError(ErrorStr, False);
    Free;
  end;
end;

procedure TForm1.TrayMouseUp(Sender: PControl; var Mouse: TMouseEventData);
begin
  if (Mouse.Button = mbLeft) then
  begin
    if Form.Visible then
      Form.Hide
    else
    begin
      Form.Show;
      Form.Focused := True;
    end;
  end
  else
    ShowAboutbox;
end;

procedure TForm1.btplayClick(Sender: PObj);
begin
  if Chn = nil then
    PlayChannel
  else
    StopChannel;
end;

procedure TForm1.ChangeTrayIcon(const NewIcon: HICON);
begin
  if (trayiconcolor_enabled) and (Tray.Icon <> NewIcon) then
    Tray.Icon := NewIcon;
end;

function TForm1.channeltreeTVSelChanging(Sender: PControl; oldItem,
  newItem: Cardinal): Boolean;
begin
  Result := channeltree.Enabled;
end;

procedure TForm1.channeltreeSelChange(Sender: PObj);
begin
  PlayChannel;
end;

procedure TForm1.traypopup(const Atitle, Atext: string;
  const IconType: Integer);
begin
  if traypopups_enabled then
  begin
    Tray.BalloonTitle := Atitle;
    Tray.BalloonText := Atext;
    Tray.ShowBalloon(IconType, 3);
  end;
end;

end.

