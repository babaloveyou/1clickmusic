//
// purpose: Level indidator
//  author: KOL version © 2005, Thaddy de Koning
// Remarks:
//
(*
    TIndicator Properties:
     Background       The controls background color or main if link = true
     Foreground       The indicator color
     Shadow           The Indicator shadowcolor
     Height           Control height
     Width            Control widht
     PositionL        Left Indicator level (range 0-100) or main if link = true
     PositionR        Right Indicator
     Link             Links L+R to give 'mono' indicator

*)
unit Kolindicator;

interface

uses
  Windows, messages, kol;

type
  PIndicatorData = ^TIndicatorData;
  TIndicatorData = object(TObj)
    FLink: Boolean;
    FDrawBuffer: PBitmap;
    FShadow,
      FForeground,
      FBackground: TColor;
    FPositionL: Integer;
    FPositionR: Integer;
    destructor Destroy; virtual;
  end;

  PIndicator = ^TIndicator;
  TIndicator = object(Tcontrol)
  private
    function Getlink: Boolean;
    procedure setlink(const Value: Boolean);
  protected
    function getshadow: TColor;
    procedure setshadow(const Value: TColor);
    function GetBackground: TColor;
    function GetForeground: TColor;
    function GetPositionL: integer;
    procedure SetPositionL(value: integer);
    function GetPositionR: integer;
    procedure SetPositionR(value: integer);
    procedure SetForeground(value: TColor);
    procedure SetBackground(value: TColor);
    procedure Paint(sender: Pcontrol; dc: hdc);
    procedure SetBoundsRect(ALeft, ATop, AWidth, AHeight: Integer); virtual;
  public
    procedure UpdateDrawBuffer;
    property PositionL: integer read GetPositionL write SetPositionL;
    property PositionR: integer read GetPositionR write SetPositionR;
    property Background: TColor read GetBackground write SetBackground;
    property Foreground: TColor read GetForeground write SetForeground;
    property Shadow: TColor read getshadow write setshadow;
    property link: Boolean read Getlink write setlink;
  end;

function NewIndicator(anOwner: PControl): PIndicator;


implementation

{ --- TINDICATOR ------------------------------------------------------------- }

function WndProcIndicator(Sender: PControl; var Msg: TMsg;
  var Rslt: Integer): Boolean;
var
  p: TPaintstruct;
begin
  Result := False;
  if msg.Message = WM_PAINT then
  begin
    beginpaint(sender.handle, p);
    PIndicator(sender).Paint(sender, sender.canvas.handle);
    endpaint(sender.handle, p);
    Result := true;
    Rslt := 0;
  end else
    if msg.message = WM_SIZE then
    begin
      PIndicatordata(sender.customObj).fDrawBuffer.width := sender.clientwidth;
      PIndicatordata(sender.customObj).fDrawBuffer.height := sender.clientheight;
      PIndicator(sender).Updatedrawbuffer;
      sender.invalidate;
      result := true;
    end;
end;

function NewIndicator(anOwner: PControl): PIndicator;
var
  Data: PIndicatorData;
begin
  Result := PIndicator(Newpanel(anOwner, esnone));
  Result.Attachproc(wndprocIndicator);
  New(Data, Create);
  with Result^ do
  begin
    Height := 128;
    Width := 32;
    Data.FPositionL := 40;
    Data.FPositionR := -1; //sync
    Data.FForeground := clLime;
    Data.fBackGround := clBlack;
    Data.fShadow := clgreen;
    Data.fDrawBuffer := Newbitmap(width, Height);
    CustomObj := Data;
    Color := clRed;
    Updatedrawbuffer;
  end;
end;



procedure TIndicator.SetBoundsRect(ALeft, ATop, AWidth, AHeight: Integer);
begin
  inherited SetBoundsRect(MakeRect(aLeft, aTop, aWidth, aHeight));
  if PIndicatordata(CustomObj).FDrawBuffer <> nil then begin
    PIndicatordata(CustomObj).FDrawBuffer.free;
    PIndicatordata(CustomObj).FDrawBuffer := NewBitmap(aWidth, aHeight);
  end;
end;

procedure TIndicator.UpdateDrawBuffer;
var
  a, b, c, d1, d2, n: integer;
begin
  with PIndicatordata(CustomObj)^ do
  begin
    FDrawBuffer.canvas.Brush.Color := FBackground;
    FDrawBuffer.canvas.Pen.Color := FBackground;
    FDrawBuffer.Canvas.Rectangle(0, 0, width, height);
    n := (height) div 3 - 2;
    b := (width div 2);
    d1 := round(n / 100 * (100 - fpositionL));
    if flink then
      d2 := d1
    else
      d2 := round(n / 100 * (100 - fpositionR));
    FDrawBuffer.Canvas.Pen.Color := FShadow;

    for a := 0 to n do
    begin
      if a >= d1 then
        FDrawBuffer.Canvas.pen.Color := FForeground;
      c := 3 * a + 2;
      FDrawBuffer.Canvas.MoveTo(b - 1, c);
      FDrawBuffer.Canvas.LineTo(4, c);
    end;

    FDrawBuffer.Canvas.pen.Color := Fshadow;

    for a := 0 to n do
    begin
      if a >= d2 then
        FDrawBuffer.Canvas.pen.Color := FForeground;
      c := 3 * a + 3;
      FDrawBuffer.Canvas.MoveTo(b + 1, c);
      FDrawBuffer.Canvas.LineTo(Width - 5, c);
    end;
    FDrawBuffer.Canvas.pen.Color := Fshadow;
  end;
end;

procedure TIndicator.Paint(sender: Pcontrol; dc: hdc);
begin
  PIndicatordata(CustomObj).FDrawbuffer.Draw(dc, 0, 0);
end;

procedure TIndicator.SetForeground(value: TColor);
begin
  PIndicatordata(CustomObj).FForeground := value;
  UpdateDrawBuffer;
  Invalidate;
end;

procedure TIndicator.SetBackground(value: TColor);
begin
  PIndicatordata(CustomObj).FBackground := value;
  UpdateDrawBuffer;
  Invalidate;
end;

procedure TIndicator.SetPositionL(value: integer);
begin
  if value > 100 then value := 100;
  if value < 0 then value := 0;
  PIndicatordata(CustomObj).FPositionL := Value;
  UpdateDrawBuffer;
  Invalidate;
end;

procedure TIndicator.SetPositionR(value: integer);
begin
  // synchronize if mono
  if PIndicatordata(CustomObj).flink = true then
    Value := PIndicatorData(Customobj).fPositionL;
  if value > 100 then value := 100;
  if value < 0 then value := 0;
  PIndicatordata(CustomObj).FPositionR := Value;
  UpdateDrawBuffer;
  Invalidate;
end;


destructor TIndicatorData.Destroy;
begin
  fDrawBuffer.free;
  inherited;
end;

function TIndicator.GetBackground: TColor;
begin
  Result := PIndicatordata(CustomObj).fBackGround;
end;

function TIndicator.GetForeground: TColor;
begin
  Result := PIndicatordata(CustomObj).fForeground;
end;

function TIndicator.GetPositionL: integer;
begin
  Result := PIndicatordata(CustomObj).fPositionL;
end;

function TIndicator.GetPositionR: integer;
begin
  Result := PIndicatordata(CustomObj).fPositionR;
end;

function TIndicator.getshadow: TColor;
begin
  Result := PIndicatordata(CustomObj).fshadow;
end;

procedure TIndicator.setshadow(const Value: TColor);
begin
  PIndicatordata(CustomObj).FShadow := value;
  UpdateDrawBuffer;
  Invalidate;
end;

function TIndicator.Getlink: Boolean;
begin
  Result := PIndicatordata(CustomObj).FLink;
end;

procedure TIndicator.setlink(const Value: Boolean);
begin
  PIndicatordata(CustomObj).flink := value;
end;

end.

