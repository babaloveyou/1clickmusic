object Form1: TForm1
  Left = 230
  Top = 261
  Width = 646
  Height = 312
  HorzScrollBar.Visible = False
  VertScrollBar.Visible = False
  Caption = '1ClickMusic'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Scaled = False
  PixelsPerInch = 96
  TextHeight = 13
  object channeltree: TKOLTreeView
    Tag = 0
    Left = 2
    Top = 2
    Width = 231
    Height = 281
    HelpContext = 0
    IgnoreDefault = False
    AnchorLeft = False
    AnchorTop = False
    AnchorRight = False
    AnchorBottom = False
    AcceptChildren = False
    MouseTransparent = False
    TabOrder = 0
    MinWidth = 0
    MinHeight = 0
    MaxWidth = 0
    MaxHeight = 0
    PlaceDown = False
    PlaceRight = False
    PlaceUnder = False
    Visible = True
    Enabled = True
    DoubleBuffered = False
    Align = caLeft
    CenterOnParent = False
    Ctl3D = True
    Color = clBtnFace
    parentColor = True
    Font.Color = clBlack
    Font.FontStyle = [fsBold]
    Font.FontHeight = 0
    Font.FontWidth = 0
    Font.FontWeight = 0
    Font.FontName = 'MS Sans Serif'
    Font.FontOrientation = 0
    Font.FontCharset = 1
    Font.FontPitch = fpFixed
    Font.FontQuality = fqDefault
    parentFont = False
    OnMouseUp = channeltreeMouseUp
    EraseBackground = False
    Localizy = loForm
    Transparent = False
    Options = [tvoLinesRoot, tvoTrackSelect]
    CurIndex = 0
    TVRightClickSelect = False
    OnSelChange = channeltreeSelChange
    TVIndent = 0
    HasBorder = True
    TabStop = True
    Brush.Color = clBtnFace
    Brush.BrushStyle = bsSolid
    Unicode = False
    OverrideScrollbars = True
  end
  object lblstatus: TKOLLabel
    Tag = 0
    Left = 528
    Top = 75
    Width = 105
    Height = 17
    HelpContext = 0
    IgnoreDefault = True
    AnchorLeft = False
    AnchorTop = False
    AnchorRight = False
    AnchorBottom = False
    AcceptChildren = False
    MouseTransparent = False
    TabOrder = -1
    MinWidth = 0
    MinHeight = 0
    MaxWidth = 0
    MaxHeight = 0
    PlaceDown = False
    PlaceRight = False
    PlaceUnder = False
    Visible = True
    Enabled = True
    DoubleBuffered = False
    Align = caNone
    CenterOnParent = False
    Ctl3D = True
    Color = clBtnFace
    parentColor = True
    Font.Color = clDefault
    Font.FontStyle = []
    Font.FontHeight = 0
    Font.FontWidth = 0
    Font.FontWeight = 0
    Font.FontName = 'MS Sans Serif'
    Font.FontOrientation = 0
    Font.FontCharset = 0
    Font.FontPitch = fpFixed
    Font.FontQuality = fqDefault
    parentFont = False
    EraseBackground = False
    Localizy = loForm
    Transparent = False
    TextAlign = taRight
    VerticalAlign = vaTop
    wordWrap = False
    autoSize = False
    Brush.Color = clBtnFace
    Brush.BrushStyle = bsSolid
    ShowAccelChar = False
    windowed = True
  end
  object lblbuffer: TKOLLabel
    Tag = 0
    Left = 457
    Top = 96
    Width = 176
    Height = 20
    HelpContext = 0
    IgnoreDefault = False
    AnchorLeft = False
    AnchorTop = False
    AnchorRight = False
    AnchorBottom = False
    AcceptChildren = False
    MouseTransparent = False
    TabOrder = -1
    MinWidth = 0
    MinHeight = 0
    MaxWidth = 0
    MaxHeight = 0
    PlaceDown = False
    PlaceRight = False
    PlaceUnder = False
    Visible = True
    Enabled = True
    DoubleBuffered = False
    Align = caNone
    CenterOnParent = False
    Ctl3D = True
    Color = clBtnFace
    parentColor = True
    Font.Color = clWindowText
    Font.FontStyle = []
    Font.FontHeight = 0
    Font.FontWidth = 0
    Font.FontWeight = 0
    Font.FontName = 'MS Sans Serif'
    Font.FontOrientation = 0
    Font.FontCharset = 0
    Font.FontPitch = fpFixed
    Font.FontQuality = fqDefault
    parentFont = False
    EraseBackground = False
    Localizy = loForm
    Transparent = False
    TextAlign = taRight
    VerticalAlign = vaCenter
    wordWrap = False
    autoSize = False
    Brush.Color = clBtnFace
    Brush.BrushStyle = bsSolid
    ShowAccelChar = False
    windowed = True
  end
  object lbltrack: TKOLLabel
    Tag = 0
    Left = 248
    Top = 8
    Width = 369
    Height = 49
    HelpContext = 0
    IgnoreDefault = False
    AnchorLeft = False
    AnchorTop = False
    AnchorRight = False
    AnchorBottom = False
    AcceptChildren = False
    MouseTransparent = False
    TabOrder = -1
    MinWidth = 0
    MinHeight = 0
    MaxWidth = 0
    MaxHeight = 0
    PlaceDown = False
    PlaceRight = False
    PlaceUnder = False
    Visible = True
    Enabled = True
    DoubleBuffered = False
    Align = caNone
    CenterOnParent = False
    Ctl3D = True
    Color = clBtnFace
    parentColor = True
    Font.Color = clTeal
    Font.FontStyle = [fsBold]
    Font.FontHeight = 0
    Font.FontWidth = 0
    Font.FontWeight = 0
    Font.FontName = 'Times New Roman'
    Font.FontOrientation = 0
    Font.FontCharset = 0
    Font.FontPitch = fpFixed
    Font.FontQuality = fqDefault
    parentFont = False
    EraseBackground = False
    Localizy = loForm
    Transparent = False
    TextAlign = taCenter
    VerticalAlign = vaCenter
    wordWrap = True
    autoSize = False
    Brush.Color = clBtnFace
    Brush.BrushStyle = bsSolid
    ShowAccelChar = False
    windowed = True
  end
  object lblhelp: TKOLLabel
    Tag = 0
    Left = 241
    Top = 136
    Width = 272
    Height = 137
    HelpContext = 0
    IgnoreDefault = False
    AnchorLeft = False
    AnchorTop = False
    AnchorRight = False
    AnchorBottom = False
    AcceptChildren = False
    MouseTransparent = False
    TabOrder = -1
    MinWidth = 0
    MinHeight = 0
    MaxWidth = 0
    MaxHeight = 0
    PlaceDown = False
    PlaceRight = False
    PlaceUnder = False
    Visible = True
    Enabled = True
    DoubleBuffered = False
    Align = caNone
    CenterOnParent = False
    Caption = 
      'Hotkeys:'#13#10' CTRL + UP  : raise volume'#13#10' CTRL + Down : decrease vo' +
      'lume'#13#10' CTRL + END : Stop'#13#10' CTRL + HOME : Play'#13#10' CTRL + (F1..F12)' +
      ' : Hotkey for Channels'#13#10#13#10'!!! Right click on a channel to bind i' +
      't for a hotkey'#13#10'!!! Left or Right click on TrayIcon to Hide/Show' +
      #13#10'Middle click on TrayIcon to see INFO'
    Ctl3D = True
    Color = clBtnFace
    parentColor = True
    Font.Color = clMaroon
    Font.FontStyle = []
    Font.FontHeight = 15
    Font.FontWidth = 0
    Font.FontWeight = 0
    Font.FontName = 'Arial'
    Font.FontOrientation = 0
    Font.FontCharset = 1
    Font.FontPitch = fpDefault
    Font.FontQuality = fqDefault
    parentFont = False
    EraseBackground = False
    Localizy = loForm
    Transparent = True
    TextAlign = taLeft
    VerticalAlign = vaTop
    wordWrap = False
    autoSize = False
    Brush.Color = clBtnFace
    Brush.BrushStyle = bsSolid
    ShowAccelChar = False
    windowed = True
  end
  object lblradio: TKOLLabel
    Tag = 0
    Left = 245
    Top = 74
    Width = 196
    Height = 22
    HelpContext = 0
    IgnoreDefault = False
    AnchorLeft = False
    AnchorTop = False
    AnchorRight = False
    AnchorBottom = False
    AcceptChildren = False
    MouseTransparent = False
    TabOrder = -1
    MinWidth = 0
    MinHeight = 0
    MaxWidth = 0
    MaxHeight = 0
    PlaceDown = False
    PlaceRight = False
    PlaceUnder = False
    Visible = True
    Enabled = True
    DoubleBuffered = False
    Align = caNone
    CenterOnParent = False
    Ctl3D = True
    Color = clBtnFace
    parentColor = True
    Font.Color = clPurple
    Font.FontStyle = []
    Font.FontHeight = 0
    Font.FontWidth = 0
    Font.FontWeight = 0
    Font.FontName = 'MS Sans Serif'
    Font.FontOrientation = 0
    Font.FontCharset = 0
    Font.FontPitch = fpFixed
    Font.FontQuality = fqDefault
    parentFont = False
    EraseBackground = False
    Localizy = loForm
    Transparent = False
    TextAlign = taLeft
    VerticalAlign = vaTop
    wordWrap = False
    autoSize = False
    Brush.Color = clBtnFace
    Brush.BrushStyle = bsSolid
    ShowAccelChar = False
    windowed = True
  end
  object btoptions: TKOLButton
    Tag = 0
    Left = 536
    Top = 256
    Width = 76
    Height = 22
    HelpContext = 0
    IgnoreDefault = True
    AnchorLeft = False
    AnchorTop = False
    AnchorRight = False
    AnchorBottom = False
    AcceptChildren = False
    MouseTransparent = False
    TabOrder = 1
    MinWidth = 0
    MinHeight = 0
    MaxWidth = 0
    MaxHeight = 0
    PlaceDown = False
    PlaceRight = False
    PlaceUnder = False
    Visible = True
    Enabled = True
    DoubleBuffered = False
    Align = caNone
    CenterOnParent = False
    Caption = 'Options'
    Ctl3D = True
    Color = clBtnFace
    parentColor = False
    Font.Color = clWindowText
    Font.FontStyle = [fsBold]
    Font.FontHeight = 0
    Font.FontWidth = 0
    Font.FontWeight = 0
    Font.FontName = 'MS Sans Serif'
    Font.FontOrientation = 0
    Font.FontCharset = 1
    Font.FontPitch = fpFixed
    Font.FontQuality = fqDefault
    parentFont = False
    OnClick = btoptionsClick
    EraseBackground = False
    Localizy = loForm
    Border = 2
    TextAlign = taCenter
    VerticalAlign = vaCenter
    TabStop = True
    LikeSpeedButton = False
    autoSize = False
    DefaultBtn = False
    CancelBtn = False
    windowed = True
    Flat = True
    WordWrap = False
  end
  object KOLProject1: TKOLProject
    Locked = False
    Localizy = False
    projectName = 'oneclick'
    projectDest = 'oneclick'
    sourcePath = 'C:\Documents and Settings\arthur pires\Desktop\1clickmusic\'
    outdcuPath = 'C:\Documents and Settings\arthur pires\Desktop\1clickmusic\'
    dprResource = False
    protectFiles = True
    showReport = False
    isKOLProject = True
    autoBuild = True
    autoBuildDelay = 500
    BUILD = False
    consoleOut = False
    SupportAnsiMnemonics = 0
    PaintType = ptWYSIWIG
    ShowHint = False
    ReportDetailed = False
    GeneratePCode = False
    NewIF = False
    Left = 80
    Top = 16
  end
  object Timer: TKOLTimer
    Interval = 500
    Enabled = True
    OnTimer = TimerTimer
    Multimedia = False
    Resolution = 0
    Periodic = True
    Left = 112
    Top = 16
  end
  object KOLForm1: TKOLForm
    Tag = 0
    Icon = 'TRAY'
    ForceIcon16x16 = False
    Caption = '1ClickMusic'
    Visible = True
    OnMessage = KOLForm1Message
    OnDestroy = KOLForm1Destroy
    AllBtnReturnClick = False
    Tabulate = False
    TabulateEx = False
    UnitSourcePath = 'C:\Documents and Settings\arthur pires\Desktop\1clickmusic\'
    Locked = False
    formUnit = 'Unit1'
    formMain = True
    Enabled = True
    defaultSize = False
    defaultPosition = False
    MinWidth = 0
    MinHeight = 0
    MaxWidth = 0
    MaxHeight = 0
    HasBorder = True
    HasCaption = True
    StayOnTop = False
    CanResize = False
    CenterOnScreen = True
    Ctl3D = True
    WindowState = wsNormal
    minimizeIcon = True
    maximizeIcon = False
    closeIcon = True
    helpContextIcon = False
    borderStyle = fbsSingle
    HelpContext = 0
    Color = clBtnFace
    Font.Color = clWindowText
    Font.FontStyle = []
    Font.FontHeight = 0
    Font.FontWidth = 0
    Font.FontWeight = 0
    Font.FontName = 'MS Sans Serif'
    Font.FontOrientation = 0
    Font.FontCharset = 1
    Font.FontPitch = fpFixed
    Font.FontQuality = fqDefault
    Brush.Color = clBtnFace
    Brush.BrushStyle = bsSolid
    DoubleBuffered = False
    PreventResizeFlicks = False
    Transparent = False
    AlphaBlend = 255
    Border = 2
    MarginLeft = 0
    MarginRight = 0
    MarginTop = 0
    MarginBottom = 0
    MinimizeNormalAnimated = False
    RestoreNormalMaximized = False
    zOrderChildren = False
    statusSizeGrip = True
    Localizy = False
    ShowHint = False
    KeyPreview = False
    OnFormCreate = KOLForm1FormCreate
    EraseBackground = False
    supportMnemonics = False
    Left = 48
    Top = 16
  end
  object Tray: TKOLBAPTrayIcon
    OnMouseUp = TrayMouseUp
    Left = 16
    Top = 16
  end
end
