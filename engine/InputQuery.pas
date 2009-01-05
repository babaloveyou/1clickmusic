unit InputQuery;

interface

uses
  KOL,
  Windows;

function InputBox(const APrompt: string; var Value: string; options : TEditOptions = []): Boolean;

implementation

procedure OKClick(Dialog, Btn: PControl);
begin
  if Btn.CancelBtn then
    Dialog.ModalResult := idCancel
  else
    Dialog.ModalResult := idOK;
  Dialog.Close;
end;

procedure KeyClick(Dialog, Btn: PControl; var Key: Longint; Shift: DWORD);
begin
  if (Key = VK_RETURN) or (Key = VK_ESCAPE) then
    OKClick(Dialog, Btn);
end;

function GetAveCharSize(Handle : HDC): TPoint;
var
  I: Integer;
  Buffer: array[0..51] of Char;
begin
  for I := 0 to 25 do Buffer[I] := Chr(I + Ord('A'));
  for I := 0 to 25 do Buffer[I + 26] := Chr(I + Ord('a'));
  GetTextExtentPoint32(Handle, Buffer, 52, TSize(Result));
  Result.X := Result.X div 52;
end;

function InputBox(const APrompt: string; var Value: string; options : TEditOptions = []): Boolean;
var
  Dialog, Prompt, Edit: PControl;
  DialogUnits: TPoint;
  ButtonTop, ButtonWidth, ButtonHeight: Integer;
begin
  Result := False; // Return "Clicked Cancel" If Anything Goes Wrong

  Dialog := NewForm(Applet, '1ClickMusic');

  Dialog.Visible := False; // Hide until everything is not created
  Dialog.CreateWindow; // Until not created, access to canvas is not possible

  Dialog.Font.FontHeight := 8;
  DialogUnits := GetAveCharSize(Dialog.Canvas.Handle);
  Dialog.Icon := LoadIcon(0, IDI_INFORMATION);
  Dialog.Style := Dialog.Style and not (WS_MINIMIZEBOX or WS_MAXIMIZEBOX);
  Dialog.ClientWidth := MulDiv(180, DialogUnits.X, 4);

  Prompt := NewLabel(Dialog, APrompt);
  with Prompt^ do
  begin
    Color := clBtnFace;
    Left := MulDiv(8, DialogUnits.X, 4);
    Top := MulDiv(8, DialogUnits.Y, 8);
    MaxWidth := MulDiv(164, DialogUnits.X, 4);
     //Wordwrap := True;
    CreateWindow;
    Height := Prompt.Canvas.TextHeight(Text);
    Width := Prompt.Canvas.TextWidth(Text);
  end;

  Edit := NewEditbox(Dialog, options);
  with Edit^ do
  begin
    Caption := APrompt;
    Color := clWindow;
    Left := Prompt.Left;
    Top := Prompt.Top + Prompt.Height + 5;
    Width := MulDiv(164, DialogUnits.X, 4);
     //MaxTextSize := 255;
    OnKeyDown := TOnKey(MakeMethod(Dialog, @KeyClick));
    Text := Value;
    SelectAll;
  end;
  ButtonTop := Edit.Top + Edit.Height + 15;
  ButtonWidth := MulDiv(50, DialogUnits.X, 4);
  ButtonHeight := MulDiv(14, DialogUnits.Y, 8);

  with NewButton(Dialog, 'OK')^ do
  begin
    DefaultBtn := True;
    Left := MulDiv(38, DialogUnits.X, 4);
    Top := ButtonTop;
    Width := ButtonWidth;
    Height := ButtonHeight;
    OnClick := TOnEvent(MakeMethod(Dialog, @OKClick));
    OnKeyDown := TOnKey(MakeMethod(Dialog, @KeyClick));
  end;

  with NewButton(Dialog, 'Cancel')^ do
  begin
    CancelBtn := True;
    Left := MulDiv(92, DialogUnits.X, 4);
    Top := Edit.Top + Edit.Height + 15;
    Width := ButtonWidth;
    Height := ButtonHeight;
    Dialog.ClientHeight := Top + Height + 13;
    OnClick := TOnEvent(MakeMethod(Dialog, @OKClick));
    OnKeyDown := TOnKey(MakeMethod(Dialog, @KeyClick));
  end;

  Dialog.CenterOnParent.Tabulate.CanResize := FALSE;
  Dialog.Visible := True;

  Dialog.ShowModal;
  if Dialog.ModalResult = idOK then
  begin
    Value := Edit.Text;
    Result := True;
  end;

  Dialog.Free;
end;

end.

