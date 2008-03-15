{ KOL MCK }// Do not remove this line!
{$DEFINE KOL_MCK}
unit Unit2;

interface

{$IFDEF KOL_MCK}
uses Windows,
  Messages,
  KOL{$IFNDEF KOL_MCK},
  mirror,
  Classes,
  Controls,
  mckCtrls,
  mckObjs,
  Graphics,
  StdCtrls{$ENDIF (place your units here->)};
{$ELSE}
{$I uses.inc}
Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
Dialogs, mirror;
{$ENDIF}

type
  {$IFDEF KOL_MCK}
  {$I MCKfakeClasses.inc}
  {$IFDEF KOLCLASSES} {$I TForm2class.inc} {$ELSE OBJECTS} PForm2 = ^TForm2; {$ENDIF CLASSES/OBJECTS}
  {$IFDEF KOLCLASSES}{$I TForm2.inc}{$ELSE} TForm2 = object(TObj) {$ENDIF}
    Form: PControl;
    {$ELSE not_KOL_MCK}
  TForm2 = class(TForm)
    {$ENDIF KOL_MCK}
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
    tabcontrol: TKOLTabControl;
    ckbxuseprimary: TKOLCheckBox;
    ckbxpriority: TKOLCheckBox;
    cmbxbuffersize: TKOLComboBox;
    lblbuffersize: TKOLLabel;
    procedure ckbxlistenabledClick(Sender: PObj);
    procedure ckbxmsnenabledClick(Sender: PObj);
    procedure ckbxlastfmClick(Sender: PObj);
    procedure KOLForm1FormCreate(Sender: PObj);
    procedure btapplyClick(Sender: PObj);
    procedure btupdateClick(Sender: PObj);
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

{$IFNDEF KOL_MCK}{$R *.DFM}{$ENDIF}

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
  tabcontrol.TC_Insert(0, 'Extras', 0);
  tabcontrol.TC_Insert(1, 'Advanced', 0);
  //
  ckbxmsnenabled.Parent := tabcontrol.TC_Pages[0];
  ckbxmsnenabled.Checked := msn_enabled;
  cmbxmsnicon.CurIndex := msn_iconi;
  cmbxmsnicon.Parent := tabcontrol.TC_Pages[0];
  //
  ckbxlistenabled.Checked := list_enabled;
  ckbxlistenabled.Parent := tabcontrol.TC_Pages[0];
  edtlistname.Text := list_file;
  edtlistname.Parent := tabcontrol.TC_Pages[0];
  //
  ckbxclipboard.Checked := clipboard_enabled;
  ckbxclipboard.Parent := tabcontrol.TC_Pages[0];
  //
  ckbxlastfm.Checked := lastfm_enabled;
  ckbxlastfm.Parent := tabcontrol.TC_Pages[0];
  lbluser.Parent := tabcontrol.TC_Pages[0];
  edtuser.Text := lastfm_user;
  edtuser.Parent := tabcontrol.TC_Pages[0];
  lblpass.Parent := tabcontrol.TC_Pages[0];
  edtpass.Text := lastfm_pass;
  edtpass.Parent := tabcontrol.TC_Pages[0];

  // configure controls acording to config
  edtlistname.Enabled := ckbxlistenabled.Checked;
  cmbxmsnicon.Enabled := ckbxmsnenabled.Checked;
  edtuser.Enabled := ckbxlastfm.Checked;
  edtpass.Enabled := ckbxlastfm.Checked;
  //

  ckbxuseprimary.Parent := tabcontrol.TC_Pages[1];
  ckbxpriority.Parent := tabcontrol.TC_Pages[1];
  cmbxbuffersize.Parent := tabcontrol.TC_Pages[1];
  lblbuffersize.Parent := tabcontrol.TC_Pages[1];

  ckbxuseprimary.Checked := ds_useprimary;
  ckbxpriority.Checked := ds_cooplevel = 2;
  cmbxbuffersize.CurIndex := ds_buffersize;
end;

procedure TForm2.btapplyClick(Sender: PObj);
begin
  // submit changes
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

  ds_useprimary := ckbxuseprimary.Checked;
  if ckbxpriority.Checked then
    ds_cooplevel := 2
  else
    ds_cooplevel := 1;
  ds_buffersize := cmbxbuffersize.CurIndex;
end;

procedure TForm2.btupdateClick(Sender: PObj);
begin
  btupdate.Enabled := False;
  if AutoUpdate(Form) then
  begin
    firstrun_enabled := True;
    Form1.Form.Free;
    Form2.Form.Free;
    Halt;
  end;
  btupdate.Enabled := True;
end;

end.


