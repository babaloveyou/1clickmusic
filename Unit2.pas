{ KOL MCK }// Do not remove this line!
{$DEFINE KOL_MCK}
unit Unit2;

interface

{$IFDEF KOL_MCK}
uses Windows,
  Messages,
  KOL{$IF Defined(KOL_MCK)}{$ELSE},
  mirror,
  Classes,
  Controls,
  mckCtrls,
  mckObjs,
  Graphics,
  StdCtrls{$IFEND (place your units here->)};
{$ELSE}
{$I uses.inc}
Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
Dialogs, mirror;
{$ENDIF}

type
  {$IF Defined(KOL_MCK)}
  {$I MCKfakeClasses.inc}
  {$IFDEF KOLCLASSES} {$I TForm2class.inc} {$ELSE OBJECTS} PForm2 = ^TForm2; {$ENDIF CLASSES/OBJECTS}
  {$IFDEF KOLCLASSES}{$I TForm2.inc}{$ELSE} TForm2 = object(TObj) {$ENDIF}
    Form: PControl;
    {$ELSE not_KOL_MCK}
  TForm2 = class(TForm)
  {$IFEND KOL_MCK}
    KOLForm1: TKOLForm;
    ckbxmsnenabled: TKOLCheckBox;
    cmbxmsnicon: TKOLComboBox;
    ckbxlistenabled: TKOLCheckBox;
    edtlistname: TKOLEditBox;
    ckbxclipboard: TKOLCheckBox;
    ckbxlastfm: TKOLCheckBox;
    edtuser: TKOLEditBox;
    edtpass: TKOLEditBox;
    lbluser: TKOLLabel;
    lblpass: TKOLLabel;
    btapply: TKOLButton;
    btupdate: TKOLButton;
    ckbxballons: TKOLCheckBox;
    lblversion: TKOLLabel;
    ckbxtraycolors: TKOLCheckBox;
    tabs: TKOLTabControl;
    edtproxyhost: TKOLEditBox;
    edtproxyport: TKOLEditBox;
    ckbxproxyenabled: TKOLCheckBox;
    lblproxyhost: TKOLLabel;
    lblproxyport: TKOLLabel;
    procedure ckbxlistenabledClick(Sender: PObj);
    procedure ckbxmsnenabledClick(Sender: PObj);
    procedure ckbxlastfmClick(Sender: PObj);
    procedure KOLForm1FormCreate(Sender: PObj);
    procedure btapplyClick(Sender: PObj);
    procedure btupdateClick(Sender: PObj);
    procedure ckbxproxyenabledClick(Sender: PObj);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form2{$IFDEF KOL_MCK}: PForm2{$ELSE}: TForm2{$ENDIF};

  {$IFDEF KOL_MCK}
procedure NewForm2(var Result: PForm2; AParent: PControl);
{$ENDIF}

implementation

uses main, Unit1;

{$IF Defined(KOL_MCK)}{$ELSE}{$R *.DFM}{$IFEND}

{$IFDEF KOL_MCK}
{$I Unit2_1.inc}
{$ENDIF}

procedure TForm2.ckbxlistenabledClick(Sender: PObj);
begin
  edtlistname.Enabled := ckbxlistenabled.Checked;
end;

procedure TForm2.ckbxmsnenabledClick(Sender: PObj);
begin
  cmbxmsnicon.Enabled := ckbxmsnenabled.Checked;
end;

procedure TForm2.ckbxlastfmClick(Sender: PObj);
begin
  edtuser.Enabled := ckbxlastfm.Checked;
  edtpass.Enabled := ckbxlastfm.Checked;
end;

procedure TForm2.KOLForm1FormCreate(Sender: PObj);
begin
  tabs.TC_Insert(0,'Tray',0);
  tabs.TC_Insert(1,'Messenger',0);
  tabs.TC_Insert(2,'Last.FM',0);
  tabs.TC_Insert(3,'Track List',0);
  tabs.TC_Insert(4,'Proxy',0);

  lblversion.Caption := 'version:'+appversionstr+
  #13#10 + 'by arthurprs, arthurprs@gmail.com';
  //
  ckbxballons.Parent := tabs.TC_Pages[0];
  ckbxballons.Checked := traypopups_enabled;
  ckbxtraycolors.Parent := tabs.TC_Pages[0];
  ckbxtraycolors.Checked := trayiconcolor_enabled;
  //
  ckbxmsnenabled.Parent := tabs.TC_Pages[1];
  ckbxmsnenabled.Checked := msn_enabled;
  cmbxmsnicon.Parent := tabs.TC_Pages[1];
  cmbxmsnicon.CurIndex := msn_iconi;
  //
  ckbxlistenabled.Parent := tabs.TC_Pages[3];
  ckbxlistenabled.Checked := list_enabled;
  edtlistname.Parent := tabs.TC_Pages[3];
  edtlistname.Text := list_file;
  //
  ckbxclipboard.Parent := tabs.TC_Pages[3];
  ckbxclipboard.Checked := clipboard_enabled;
  //
  ckbxlastfm.Parent := tabs.TC_Pages[2];
  ckbxlastfm.Checked := lastfm_enabled;
  lbluser.Parent := tabs.TC_Pages[2];
  edtuser.Parent := tabs.TC_Pages[2];
  edtuser.Text := lastfm_user;
  lblpass.Parent := tabs.TC_Pages[2];
  edtpass.Parent := tabs.TC_Pages[2];
  edtpass.Text := lastfm_pass;
  //
  ckbxproxyenabled.Parent := tabs.TC_Pages[4];
  ckbxproxyenabled.Checked := proxy_enabled;
  lblproxyhost.Parent := tabs.TC_Pages[4];
  lblproxyport.Parent := tabs.TC_Pages[4];
  edtproxyhost.Parent := tabs.TC_Pages[4];
  edtproxyhost.Text := proxy_host;
  edtproxyport.Parent := tabs.TC_Pages[4];
  edtproxyport.Text := proxy_port;

  // configure controls acording to config
  edtlistname.Enabled := ckbxlistenabled.Checked;
  cmbxmsnicon.Enabled := ckbxmsnenabled.Checked;
  edtuser.Enabled := ckbxlastfm.Checked;
  edtpass.Enabled := ckbxlastfm.Checked;
  edtproxyhost.Enabled := ckbxproxyenabled.Checked;
  edtproxyport.Enabled := ckbxproxyenabled.Checked;
  //
end;

procedure TForm2.btapplyClick(Sender: PObj);
begin
  // submit changes
  traypopups_enabled := ckbxballons.Checked;
  if not ckbxtraycolors.Checked then
    Form1.ChangeTrayIcon(Form1.Form.Icon);
  trayiconcolor_enabled := ckbxtraycolors.Checked;

  msn_enabled := ckbxmsnenabled.Checked;
  updateMSN(msn_enabled);
  msn_iconi := cmbxmsnicon.CurIndex;
  case msn_iconi of
    0: msn_icons := 'Music';
    1: msn_icons := 'Games';
    2: msn_icons := 'Office';
  end;
  list_enabled := ckbxlistenabled.Checked;
  list_file := edtlistname.Text;
  clipboard_enabled := ckbxclipboard.Checked;
  lastfm_enabled := ckbxlastfm.Checked;
  lastfm_user := edtuser.Text;
  lastfm_pass := edtpass.Text;

  proxy_enabled := ckbxproxyenabled.Checked;
  proxy_host := edtproxyhost.Text;
  proxy_port := edtproxyport.Text;

  Form1.SaveConfig;
end;

procedure TForm2.btupdateClick(Sender: PObj);
begin
  btupdate.Enabled := False;
  if AutoUpdate then
  begin
    firstrun_enabled := True;
    Form1.SaveConfig;
    Halt;
  end;
  btupdate.Enabled := True;
end;

procedure TForm2.ckbxproxyenabledClick(Sender: PObj);
begin
  edtproxyhost.Enabled := ckbxproxyenabled.Checked;
  edtproxyport.Enabled := ckbxproxyenabled.Checked;
end;

end.



