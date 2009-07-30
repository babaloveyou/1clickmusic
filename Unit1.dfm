object Form1: TForm1
  Left = 282
  Top = 276
  Width = 621
  Height = 300
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
    Left = 0
    Top = 0
    Width = 231
    Height = 273
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
    parentFont = False
    OnMouseUp = channeltreeMouseUp
    EraseBackground = False
    Localizy = loForm
    Transparent = False
    Options = [tvoLinesRoot, tvoTrackSelect, tvoSingleExpand]
    ImageListNormal = treeimagelist
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
    Left = 480
    Top = 75
    Width = 127
    Height = 18
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
    Left = 528
    Top = 112
    Width = 79
    Height = 41
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
    Font.Color = clBlue
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
  object lbltrack: TKOLLabel
    Tag = 0
    Left = 242
    Top = 8
    Width = 366
    Height = 57
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
    VerticalAlign = vaTop
    wordWrap = False
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
      ' : Hotkey for Channels'#13#10#13#10'Right click trayicon to see options'#13#10'R' +
      'ight click on a channel to bind hotkeys'#13#10
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
  object lblradio: TKOLLabel
    Tag = 0
    Left = 245
    Top = 74
    Width = 212
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
  object btplay: TKOLButton
    Tag = 0
    Left = 534
    Top = 247
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
    Caption = 'Play'
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
    OnClick = btplayClick
    EraseBackground = True
    Localizy = loForm
    Border = 2
    TextAlign = taCenter
    VerticalAlign = vaCenter
    TabStop = True
    autoSize = False
    DefaultBtn = False
    CancelBtn = False
    windowed = True
    Flat = False
    WordWrap = False
    LikeSpeedButton = True
  end
  object pgrbuffer: TKOLProgressBar
    Tag = 0
    Left = 536
    Top = 93
    Width = 71
    Height = 19
    HelpContext = 0
    IgnoreDefault = False
    AnchorLeft = False
    AnchorTop = False
    AnchorRight = False
    AnchorBottom = False
    AcceptChildren = False
    MouseTransparent = False
    TabOrder = 2
    MinWidth = 0
    MinHeight = 0
    MaxWidth = 0
    MaxHeight = 0
    PlaceDown = False
    PlaceRight = False
    PlaceUnder = False
    Visible = False
    Enabled = True
    DoubleBuffered = False
    Align = caNone
    CenterOnParent = False
    Ctl3D = True
    Color = clBtnFace
    parentColor = False
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
    parentFont = True
    EraseBackground = False
    Localizy = loForm
    Transparent = False
    Vertical = False
    Smooth = True
    ProgressColor = 14916698
    ProgressBkColor = clBtnFace
    Progress = 0
    MaxProgress = 100
    Brush.Color = clBtnFace
    Brush.BrushStyle = bsSolid
  end
  object KOLProject1: TKOLProject
    Locked = False
    Localizy = False
    projectName = 'oneclick'
    projectDest = 'oneclick'
    sourcePath = 'C:\Documents and Settings\Administrador\Desktop\1clickmusic\'
    outdcuPath = 'dcu\'
    dprResource = True
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
    DefaultFont.Color = clWindowText
    DefaultFont.FontStyle = []
    DefaultFont.FontHeight = 0
    DefaultFont.FontWidth = 0
    DefaultFont.FontWeight = 0
    DefaultFont.FontName = 'System'
    DefaultFont.FontOrientation = 0
    DefaultFont.FontCharset = 1
    DefaultFont.FontPitch = fpDefault
    DefaultFont.FontQuality = fqDefault
    Left = 80
    Top = 16
  end
  object KOLForm1: TKOLForm
    Tag = 0
    Icon = 'MAINICON'
    ForceIcon16x16 = False
    Caption = '1ClickMusic'
    Visible = True
    OnMessage = KOLForm1Message
    OnDestroy = KOLForm1Destroy
    AllBtnReturnClick = False
    Tabulate = False
    TabulateEx = False
    UnitSourcePath = 'C:\Documents and Settings\Administrador\Desktop\1clickmusic\'
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
    FontDefault = False
    Brush.Color = clBtnFace
    Brush.BrushStyle = bsSolid
    DoubleBuffered = False
    PreventResizeFlicks = False
    Transparent = False
    AlphaBlend = 255
    Border = 0
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
    Active = False
    HideBallOnTimer = False
    OnMouseUp = TrayMouseUp
    Localizy = loForm
    Left = 112
    Top = 16
  end
  object treeimagelist: TKOLImageList
    ImgWidth = 16
    ImgHeight = 16
    Count = 3
    bitmap.Data = {
      36090000424D3609000000000000360000002800000030000000100000000100
      1800000000000009000000000000000000000000000000000000FFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF084148084148
      0841480841480841480841480841480841480841480841480841480841480841
      48084148FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFF08414839DDF036D8EB32D3E62ECEE12AC9DC26C4D722
      BFD21EBBCD1BB6C817B1C313ACBE0FA7B9084148FFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF0841483DE2F5
      39DDF036D8EB32D3E62ECEE12AC9DC26C4D722BFD21EBBCD1BB6C817B1C313AC
      BE084148FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFBDBDBD0069C8BDBDBDFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF00A801FFFFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFF08414841E7FB3DE2F539DDF036D8EB32D3E62ECEE12A
      C9DC26C4D722BFD21EBBCD1BB6C817B1C3084148FFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFBDBDBDBDBDBDBDBDBDBDBDBDBDBDBDBDBDBD0069C80069C8BDBDBDFFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFF00A80100A801FFFFFFFFFFFFFFFFFFFFFFFFFFFFFF08414843E9FD
      41E7FB3DE2F539DDF036D8EB32D3E62ECEE12AC9DC26C4D722BFD21EBBCD1BB6
      C8084148FFFFFFFFFFFFFFFFFFFFFFFFFFFFFF0069C80069C80069C80069C800
      69C80069C80069C84296F50069C8BDBDBDFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFF00A80100A80100A80100A80100A80100A80100A80100D70000A801FFFF
      FFFFFFFFFFFFFFFFFFFF08414843E9FD43E9FD41E7FB3DE2F539DDF036D8EB32
      D3E62ECEE12AC9DC26C4D722BFD21EBBCD084148FFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFF0069C84296F54296F54296F54296F54296F54296F54296F54296F50069
      C8FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFBDBDBD00A80100D70000D70000D70000
      D70000D70000D70076BE3C00D70000A801FFFFFFFFFFFFFFFFFF08414843E9FD
      43E9FD43E9FD41E7FB3DE2F539DDF036D8EB32D3E62ECEE12AC9DC26C4D722BF
      D2084148FFFFFFFFFFFFFFFFFFFFFFFFFFFFFF0069C83FB4F73FB4F73FB4F73F
      B4F73FB4F73FB4F73FB4F73FB4F70069C8FFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      BDBDBD00A80176BE3C76BE3C76BE3C76BE3C76BE3C76BE3C76BE3C76BE3C00A8
      01FFFFFFFFFFFFFFFFFF08414843E9FD43E9FD43E9FD43E9FD41E7FB3DE2F539
      DDF036D8EB32D3E62ECEE12AC9DC26C4D7084148FFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFF0069C80069C80069C80069C80069C80069C80069C83FB4F70069C8FFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFBDBDBD00A80100A80100A80100A80100
      A80100A80100A80176BE3C00A801FFFFFFFFFFFFFFFFFFFFFFFF08414843E9FD
      43E9FD43E9FD43E9FD43E9FD41E7FB3DE2F5FFFFFFFFFFFFFFFFFFFFFFFF2AC9
      DC084148FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFF0069C80069C8FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      BDBDBDBDBDBDBDBDBDBDBDBDBDBDBDBDBDBDBDBDBD00A80100A801FFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFF08414808414808414808414808414808414808414808
      4148084148084148084148084148084148084148FFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF0069C8FFFFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFBDBDBD00A801FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF084148
      43E9FD43E9FD43E9FD43E9FD084148FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF084148084148084148084148FFFFFFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF}
    TransparentColor = clWhite
    systemimagelist = False
    Colors = ilcColor24
    Masked = True
    BkColor = clNone
    Left = 16
    Top = 16
  end
end
