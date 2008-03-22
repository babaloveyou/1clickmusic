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
  ckbxmsnenabled.Checked := msn_enabled;
  cmbxmsnicon.CurIndex := msn_iconi;
  //
  ckbxlistenabled.Checked := list_enabled;
  edtlistname.Text := list_file;
  //
  ckbxclipboard.Checked := clipboard_enabled;
  //
  ckbxlastfm.Checked := lastfm_enabled;
  edtuser.Text := lastfm_user;
  edtpass.Text := lastfm_pass;

  // configure controls acording to config
  edtlistname.Enabled := ckbxlistenabled.Checked;
  cmbxmsnicon.Enabled := ckbxmsnenabled.Checked;
  edtuser.Enabled := ckbxlastfm.Checked;
  edtpass.Enabled := ckbxlastfm.Checked;
  //
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
end;

procedure TForm2.btupdateClick(Sender: PObj);
begin
  btupdate.Enabled := False;
  if AutoUpdate(Form) then
  begin
    firstrun_enabled := True;
    Form2.Free;
    Form1.Free;
    Halt;
  end;
  btupdate.Enabled := True;
end;

end.



