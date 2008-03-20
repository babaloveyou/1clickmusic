unit themeengine;

interface

uses Windows, KOL, SysUtils, Classes;

function SkinIt(Handle: HWND): PBitmap;


var
  skinbmp : PBitmap;

implementation

function SkinIt(Handle: HWND):PBitmap;
var
  Bmp: PBitmap;
  i, j: Integer;
  transColor: TColor;
  Left, right: Integer;
  rectRgn, resultRgn: HRGN;
begin
  resultRgn := 0;
  Bmp := NewBitmap(0, 0);
  Bmp.LoadFromFile('2.bmp');
  transColor := Bmp.Pixels[0, 0];

  for i := 0 to Bmp.Height - 1 do
  begin
    Left := -1;
    for j := 0 to Bmp.Width - 1 do
    begin
      if Left < 0 then
      begin
        if Bmp.Canvas.Pixels[j, i] <> transColor then
          Left := j;
      end
      else
        if Bmp.Canvas.Pixels[j, i] = transColor then
        begin
          right := j;
          rectRgn := CreateRectRgn(Left, i, right, i + 1);
          if resultRgn = 0 then
            resultRgn := rectRgn
          else
          begin
            CombineRgn(resultRgn, resultRgn, rectRgn, RGN_OR);
            DeleteObject(rectRgn);
          end;
          Left := -1;
        end;
    end;
    if Left >= 0 then
    begin
      rectRgn := CreateRectRgn(Left, i, Bmp.Width - Left, i + 1);
      if resultRgn = 0 then
        resultRgn := rectRgn
      else
      begin
        CombineRgn(resultRgn, resultRgn, rectRgn, RGN_OR);
        DeleteObject(rectRgn);
      end;
    end;
  end;
  SetWindowRgn(Handle, resultRgn,False);

  Bmp.Add2AutoFree(Applet);
  Result := Bmp;
end;

end.

