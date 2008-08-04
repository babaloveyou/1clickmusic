unit themeengine;

interface

//{$DEFINE LOADFROMFILE}
//{$DEFINE GENERATE}

{  channeltree.Perform(TVM_SETLINECOLOR, 0, clRed);
  channeltree.Perform(TVM_SETTEXTCOLOR, 0, clWhite);
  channeltree.Perform(TVM_SETBKCOLOR, 0, clBlack);}

uses
  Windows,
  KOL;

type
  TThemeControlState = (stUP, stOVER, stDOWN);
  TThemeControl = record
    State: TThemeControlState;
    Rect: TRect;
  end;

type
  PTheme = ^TTheme;
  TTheme = object(TObj)
  private
    Owner: PControl;
    FupImg,
      FoverImg,
      FdownImg: PBitmap;

    FRGNDATASIZE: Cardinal;
    FRGNDATA: PRGNDATA;
    FRGN: HRGN;

    needPaint: LongBool;

    mouse: TPoint;
    controls: array of TThemeControl;
    controlcount: Cardinal;

    procedure ControlState(const controlID: Integer; const value: TThemeControlState);
    procedure Paint;
  public
    //property MousePos: TPoint read mouse write mouse;
    procedure MouseLeave();
    procedure MouseMove(const Amouse: TMouseEventData);
    procedure MouseDown(const Amouse: TMouseEventData);
    procedure MouseUp(const Amouse: TMouseEventData);
    procedure RePaint;
    constructor Create(AOwner: PControl);
    destructor Destroy; virtual;
  end;

procedure NewTheme(var Theme: PTheme; const AOwner: PControl);

{$IFDEF GENERATE}
procedure SaveRects(const rects: array of TRect);
procedure SaveRegion;
{$ENDIF}

implementation

{$IFDEF GENERATE}
procedure SaveRects(const rects: array of TRect);
var
  i: Integer;
  data: PStream;
  dummy: TThemeControl;
begin
  data := NewWriteFileStream('res/RECTS.dat');
  i := High(rects) + 1;
  data.Write(i, 4);
  dummy.State := stUP;
  for i := 0 to High(rects) do
  begin
    dummy.Rect := rects[i];
    data.Write(dummy, SizeOf(TThemeControl));
  end;
  data.Free;
end;

procedure SaveRegion;
var
  Bmp: PBitmap;
  i, j: Integer;
  transColor: TColor;
  Left, right: Integer;
  rectRgn, resultRgn: HRGN;
  data: PStream;
  resultRgnData: PRGNDATA;
  RgnDataSize: Cardinal;
begin
  resultRgn := 0;
  Bmp := NewBitmap(0, 0);
  Bmp.LoadFromFile('res/up.bmp');

  transColor := Bmp.Pixels[0, 0];

  for i := 0 to bmp.Height - 1 do
  begin
    left := -1;
    for j := 0 to bmp.width - 1 do
    begin
      if left < 0 then
      begin
        if bmp.Canvas.Pixels[j, i] <> transColor then
          left := j;
      end
      else
        if bmp.Canvas.Pixels[j, i] = transColor then
        begin
          right := j;
          rectRgn := CreateRectRgn(left, i, right, i + 1);
          if resultRgn = 0 then
            resultRgn := rectRgn
          else
          begin
            CombineRgn(resultRgn, resultRgn, rectRgn, RGN_OR);
            DeleteObject(rectRgn);
          end;
          left := -1;
        end;
    end;
    if left >= 0 then
    begin
      rectRgn := CreateRectRgn(left, i, bmp.width, i + 1);
      if resultRgn = 0 then
        resultRgn := rectRgn
      else
      begin
        CombineRgn(resultRgn, resultRgn, rectRgn, RGN_OR);
        DeleteObject(rectRgn);
      end;
    end;
  end;

  Bmp.Free;


  RgnDataSize := GetRegionData(resultRgn, 0, nil);
  resultRgnData := GetMemory(RgnDataSize);
  GetRegionData(resultRgn, RgnDataSize, resultRgnData);
  DeleteObject(resultRgn);


  data := NewWriteFileStream('res/RGN.dat');
  data.Write(RgnDataSize, 4);
  data.Write(resultRgnData^, RgnDataSize);
  data.Free;
  FreeMem(resultRgnData);
end;


//http://www.delphi3000.com/articles/article_1009.asp

    {
procedure SaveRegion;
var
  Bmp: PBitmap;
  i, j: Integer;
  transColor: TColor;
  Left, right: Integer;
  resultRgn: HRGN;
  data: PStream;
  resultRgnData: PRGNDATA;
  RgnDataSize: Cardinal;

  procedure AddRegion(const x1, x2, y: Integer);
  var
    Aux: HRgn;
  begin
    if resultRgn = 0 then
      resultRgn := CreateRectRgn(x1, y, x2 + 1, y + 1)
    else
    begin
      Aux := CreateRectRgn(x1, y, x2 + 1, y + 1);
      CombineRgn(resultRgn, resultRgn, Aux, RGN_OR);
      DeleteObject(Aux);
    end;
  end;

begin
  resultRgn := 0;
  Bmp := NewBitmap(0, 0);
  Bmp.LoadFromFile('res/up.bmp');

  transColor := Bmp.Pixels[0, 0];

  for j := 0 to bmp.Height - 1 do
  begin
    Left := -1;
    right := -1;
    for i := 0 to bmp.Width - 1 do
    begin
      if ((Bmp.Canvas.Pixels[i, j] <> transColor) or
        (i = bmp.Width - 1)) and
        (Left = -1) then
        Left := i;
      if ((Bmp.Canvas.Pixels[i, j] = transColor) or
        (i = Bmp.Width - 1)) and
        (Left <> -1) then
      begin
        right := i - 1;
        AddRegion(Left, right, j);
        Left := -1;
      end;
    end;
  end;

  Bmp.Free;


  RgnDataSize := GetRegionData(resultRgn, 0, nil);
  resultRgnData := GetMemory(RgnDataSize);
  GetRegionData(resultRgn, RgnDataSize, resultRgnData);
  DeleteObject(resultRgn);


  data := NewWriteFileStream('res/RGN.dat');
  data.Write(RgnDataSize, 4);
  data.Write(resultRgnData^, RgnDataSize);
  data.Free;
  FreeMem(resultRgnData);
end;
         }
{$ENDIF}

procedure NewTheme(var Theme: PTheme; const AOwner: PControl);
begin
  New(Theme, Create(AOwner));
end;

{ TTheme }

procedure TTheme.ControlState(const controlID: Integer;
  const value: TThemeControlState);
begin
  if controls[controlID].State <> value then
  begin
    needPaint := True;
    controls[controlID].State := value;
  end;
end;

constructor TTheme.Create(AOwner: PControl);
var
  data: PStream;
begin
  Owner := AOwner;
  Owner.Add2AutoFree(@Self);

  FupImg := NewBitmap(0, 0);
{$IFDEF LOADFROMFILE}
  FupImg.LoadFromFile('res/up.bmp');
{$ELSE}
  FupImg.LoadFromResourceName(HInstance, 'UP');
{$ENDIF}

  FdownImg := NewBitmap(0, 0);
{$IFDEF LOADFROMFILE}
  FdownImg.LoadFromFile('res/down.bmp');
{$ELSE}
  FdownImg.LoadFromResourceName(HInstance, 'DOWN');
{$ENDIF}

  FoverImg := NewBitmap(0, 0);
{$IFDEF LOADFROMFILE}
  FoverImg.LoadFromFile('res/over.bmp');
{$ELSE}
  FoverImg.LoadFromResourceName(HInstance, 'OVER');
{$ENDIF}

{$IFDEF LOADFROMFILE}
  data := NewReadFileStream('res/RECTS.dat');
{$ELSE}
  data := NewMemoryStream;
  Resource2Stream(data, HInstance, 'RECTS', RT_RCDATA);
{$ENDIF}
  data.Position := 0;
  data.Read(controlcount, 4);
  SetLength(controls, controlcount);
  data.Read(controls[0], SizeOf(TThemeControl) * controlcount);
  data.Free;

{$IFDEF LOADFROMFILE}
  data := NewReadFileStream('res/RGN.dat');
{$ELSE}
  data := NewMemoryStream;
  Resource2Stream(data, HInstance, 'RGN', RT_RCDATA);
{$ENDIF}
  data.Position := 0;
  data.Read(FRGNDATASIZE, 4);
  GetMem(FRGNDATA, FRGNDATASIZE);
  data.Read(FRGNDATA^, FRGNDATASIZE);
  data.Free;

  FRGN := ExtCreateRegion(nil, FRGNDATASIZE, FRGNDATA^);
  SetWindowRgn(owner.Handle, FRGN, True);
end;

destructor TTheme.Destroy;
begin
  FreeMem(FRGNDATA);
  DeleteObject(FRGN);
  FupImg.Free;
  FdownImg.Free;
  FoverImg.Free;
end;

procedure TTheme.MouseDown(const AMouse: TMouseEventData);
var
  i: Integer;
begin
  for i := 0 to controlcount - 1 do
    if PointInRect(mouse, controls[i].Rect) then
      ControlState(i, stDOWN)
    else
      ControlState(i, stUP);
  Paint();
end;

procedure TTheme.MouseLeave;
var
  i : Integer;
begin
  for i := 0 to controlcount -1 do
    ControlState(i,stUP);
end;

procedure TTheme.MouseMove(const AMouse: TMouseEventData);
var
  i: Integer;
begin
  mouse := MakePoint(Amouse.x, Amouse.y);
  for i := 0 to controlcount - 1 do
    if controls[i].State <> stDOWN then
      if PointInRect(mouse, controls[i].Rect) then
        ControlState(i, stOVER)
      else
        ControlState(i, stUP);
  Paint();
end;

procedure TTheme.MouseUp(const Amouse: TMouseEventData);
var
  i: Integer;
begin
  for i := 0 to controlcount - 1 do
    if controls[i].State = stDOWN then
      ControlState(i, stUP);
  Paint();
end;

procedure TTheme.Paint;
var
  i: Integer;
begin
  if not needPaint then Exit;
  needPaint := False;
  FupImg.Draw(Owner.Canvas.Handle, 0, 0);
  for i := 0 to controlcount - 1 do
    if controls[i].State = stOVER then //# OVER
      Owner.Canvas.CopyRect(
        controls[i].Rect,
        FOverImg.Canvas,
        controls[i].Rect)
    else
      if controls[i].State = stDOWN then //# DOWN
        Owner.Canvas.CopyRect(
          controls[i].Rect,
          FDownImg.Canvas,
          controls[i].Rect);
end;

procedure TTheme.RePaint;
begin
  needPaint := True;
  Paint();
end;

{$IFDEF GENERATE}
initialization
  begin
    SaveRegion();
    SaveRects([MakeRect(514, 260, 514 + 117, 260 + 24)]);
  end;
{$ENDIF}

end.

