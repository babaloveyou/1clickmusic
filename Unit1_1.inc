{ KOL MCK } // Do not remove this line!

procedure NewForm1( var Result: PForm1; AParent: PControl );
begin

  {$IFDEF KOLCLASSES}
  Result := PForm1.Create;
  {$ELSE OBJECTS}
  New( Result, Create );
  {$ENDIF KOL CLASSES/OBJECTS}
  Result.Form := NewForm( AParent, '1ClickMusic' ).SetPosition( 462, 369 );
  Applet :=  Result.Form;
  Result.Form.Add2AutoFree( Result );
{$IFDEF UNICODE_CTRLS}
     Result.Form.SetUnicode(TRUE);
{$ENDIF UNICODE_CTRLS}
   {$IFDEF USE_NAMES}
    Result.Form.SetName( Applet, 'Form1' );
   {$ENDIF}
    Result.Form.Style := Result.Form.Style and not WS_MAXIMIZEBOX;
    Result.Form.SetClientSize( 613, 266 );
    Result.Form.IconLoad( hInstance, 'MAINICON' );
    Result.Form.Font.FontName := 'MS Sans Serif';
    Result.Form.Font.FontPitch := fpFixed;
    Result.Form.Border := 0;
      Result.Form.OnMessage := Result.KOLForm1Message;
      Result.Form.OnDestroy := Result.KOLForm1Destroy;

    Result.Tray := NewBAPTrayIcon(Applet);
   {$IFDEF USE_NAMES}
    Result.Tray.SetName( Result.Form, 'Tray' ); 
   {$ENDIF}
  Result.Form.Add2AutoFree( Result.Tray );
      Result.Tray.OnMouseUp := Result.TrayMouseUp;

    Result.treeimagelist := NewImageList( Result.Form );
    Result.treeimagelist.Colors := ilcColor24;
      Result.treeimagelist.ImgWidth := 16;
      Result.treeimagelist.ImgHeight := 16;
      {$R Form1_treeimagelist.res}
    Result.treeimagelist.AddMasked( LoadBmp( hInstance, 'FORM1_TREEIMAGELIST', Result.treeimagelist ), clWhite );
   {$IFDEF USE_NAMES}
    Result.treeimagelist.SetName( Result.Form, 'treeimagelist' ); 
   {$ENDIF}
    // Result.lblbuffer.TabOrder = -1
    Result.lblbuffer := NewLabel( Result.Form, '' ).SetPosition( 528, 112 ).SetSize( 79, 41 );
   {$IFDEF USE_NAMES}
    Result.lblbuffer.SetName( Result.Form, 'lblbuffer' ); 
   {$ENDIF}
   {$IFDEF UNICODE_CTRLS}
   Result.lblbuffer.SetUnicode(TRUE);
   {$ENDIF UNICODE_CTRLS}
    Result.lblbuffer.Font.Color := TColor(clBlue);
    Result.lblbuffer.Font.FontCharset := 0;
    Result.lblbuffer.TextAlign := KOL.taRight;
    // Result.lblhelp.TabOrder = -1
    Result.lblhelp := NewLabel( Result.Form, 'Hotkeys:'+#13+#10+' CTRL + UP  : inc volume'+#13+#10+' CTRL + Down : dec volume'+#13+#10+' CTRL + END : Stop'+#13+#10+' CTRL + HOME : Play/Pause'+#13+#10+#13+#10+'Right click trayicon to see options'+#13+#10+'Right click on channels to bind hotkeys'+#13+#10+'www.1clickmusic.net' ).SetPosition( 241, 128 ).SetSize( 216, 137 );
   {$IFDEF USE_NAMES}
    Result.lblhelp.SetName( Result.Form, 'lblhelp' ); 
   {$ENDIF}
   {$IFDEF UNICODE_CTRLS}
   Result.lblhelp.SetUnicode(TRUE);
   {$ENDIF UNICODE_CTRLS}
    Result.lblhelp.Font.Color := TColor(clMaroon);
    Result.lblhelp.Font.FontHeight := 15;
    Result.lblhelp.Font.FontName := 'Arial';
    Result.lblhelp.Font.FontPitch := fpDefault;
    // Result.lblradio.TabOrder = -1
    Result.lblradio := NewLabel( Result.Form, '' ).SetPosition( 245, 74 ).SetSize( 212, 0 );
   {$IFDEF USE_NAMES}
    Result.lblradio.SetName( Result.Form, 'lblradio' ); 
   {$ENDIF}
   {$IFDEF UNICODE_CTRLS}
   Result.lblradio.SetUnicode(TRUE);
   {$ENDIF UNICODE_CTRLS}
    Result.lblradio.Font.Color := TColor(clPurple);
    Result.lblradio.Font.FontCharset := 0;
    // Result.lblstatus.TabOrder = -1
    Result.lblstatus := NewLabel( Result.Form, '' ).SetPosition( 480, 75 ).SetSize( 127, 18 );
   {$IFDEF USE_NAMES}
    Result.lblstatus.SetName( Result.Form, 'lblstatus' ); 
   {$ENDIF}
   {$IFDEF UNICODE_CTRLS}
   Result.lblstatus.SetUnicode(TRUE);
   {$ENDIF UNICODE_CTRLS}
    Result.lblstatus.Font.Color := TColor(clDefault);
    Result.lblstatus.Font.FontCharset := 0;
    Result.lblstatus.TextAlign := KOL.taRight;
    Result.lblstatus.IgnoreDefault := TRUE;
    // Result.lbltrack.TabOrder = -1
    Result.lbltrack := NewLabel( Result.Form, '' ).SetPosition( 242, 8 ).SetSize( 366, 57 );
   {$IFDEF USE_NAMES}
    Result.lbltrack.SetName( Result.Form, 'lbltrack' ); 
   {$ENDIF}
   {$IFDEF UNICODE_CTRLS}
   Result.lbltrack.SetUnicode(TRUE);
   {$ENDIF UNICODE_CTRLS}
    Result.lbltrack.Font.Color := TColor(clTeal);
    Result.lbltrack.Font.FontStyle := [ fsBold ];
    Result.lbltrack.Font.FontName := 'Times New Roman';
    Result.lbltrack.Font.FontCharset := 0;
    Result.lbltrack.TextAlign := KOL.taCenter;
    // Result.channeltree.TabOrder = 0
    Result.channeltree := NewTreeView( Result.Form, [ tvoLinesRoot, tvoTrackSelect, tvoSingleExpand ], Result.treeimagelist, nil ).SetAlign ( caLeft ).SetSize( 231, 0 );
   {$IFDEF USE_NAMES}
    Result.channeltree.SetName( Result.Form, 'channeltree' ); 
   {$ENDIF}
   {$IFDEF UNICODE_CTRLS}
   Result.channeltree.SetUnicode(TRUE);
   {$ENDIF UNICODE_CTRLS}
    // Result.btplay.TabOrder = 1
    Result.btplay := NewButton( Result.Form, 'Play' ).SetPosition( 534, 239 ).SetSize( 76, 0 ).LikeSpeedButton;
   {$IFDEF USE_NAMES}
    Result.btplay.SetName( Result.Form, 'btplay' ); 
   {$ENDIF}
   {$IFDEF UNICODE_CTRLS}
   Result.btplay.SetUnicode(TRUE);
   {$ENDIF UNICODE_CTRLS}
    Result.btplay.Font.FontStyle := [ fsBold ];
    Result.btplay.EraseBackground := TRUE;
    // Result.pgrbuffer.TabOrder = 2
    Result.pgrbuffer := NewProgressBarEx( Result.Form, [ pboSmooth ] ).SetPosition( 536, 93 ).SetSize( 71, 19 );
   {$IFDEF USE_NAMES}
    Result.pgrbuffer.SetName( Result.Form, 'pgrbuffer' ); 
   {$ENDIF}
   {$IFDEF UNICODE_CTRLS}
   Result.pgrbuffer.SetUnicode(TRUE);
   {$ENDIF UNICODE_CTRLS}
    Result.pgrbuffer.Visible := False;
    Result.pgrbuffer.Color := TColor(clBtnFace);
    Result.pgrbuffer.ProgressColor := $E39C5A;
      Result.channeltree.OnMouseUp := Result.channeltreeMouseUp;
      Result.channeltree.OnSelChange := Result.channeltreeSelChange;
    {$IFDEF OVERRIDE_SCROLLBARS}
    OverrideScrollbars( Result.channeltree);
    {$ENDIF OVERRIDE_SCROLLBARS}
      Result.btplay.OnClick := Result.btplayClick;
    Result.Form.CenterOnParent.CanResize := False;
    Result.Form.Perform( WM_INITMENU, 0, 0 );
    Result.KOLForm1FormCreate( Result );

end;

