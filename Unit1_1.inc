{ KOL MCK } // Do not remove this line!

procedure NewForm1( var Result: PForm1; AParent: PControl );
begin

  {$IFDEF KOLCLASSES}
  Result := PForm1.Create;
  {$ELSE OBJECTS}
  New( Result, Create );
  {$ENDIF KOL CLASSES/OBJECTS}
  Result.Form := NewForm( AParent, '1ClickMusic' ).SetPosition( 406, 291 );
  Applet :=  Result.Form;
  Result.Form.Add2AutoFree( Result );
    Result.Form.Style := Result.Form.Style and not WS_MAXIMIZEBOX;
    Result.Form.SetClientSize( 613, 262 );
    Result.Form.IconLoad( hInstance, 'MAINICON' );
    Result.Form.Font.FontHeight := 15;
    Result.Form.Font.FontName := 'Arial';
    Result.Form.Font.FontPitch := fpFixed;
    Result.Form.Border := 0;
      Result.Form.OnMessage := Result.KOLForm1Message;
      Result.Form.OnDestroy := Result.KOLForm1Destroy;

    Result.Tray := NewBAPTrayIcon(Applet);
  Result.Form.Add2AutoFree( Result.Tray );
      Result.Tray.OnMouseUp := Result.TrayMouseUp;

    Result.treeimagelist := NewImageList( Result.Form );
    Result.treeimagelist.Colors := ilcColor24;
      Result.treeimagelist.ImgWidth := 16;
      Result.treeimagelist.ImgHeight := 16;
      {$R Form1_treeimagelist.res}
    Result.treeimagelist.AddMasked( LoadBmp( hInstance, 'FORM1_TREEIMAGELIST', Result.treeimagelist ), clWhite );
    Result.lblbuffer := NewLabel( Result.Form, '' ).SetPosition( 528, 112 ).SetSize( 79, 41 );
    Result.lblbuffer.Font.Color := TColor(clBlue);
    Result.lblbuffer.TextAlign := KOL.taRight;
    Result.lblhelp := NewLabel( Result.Form, 'Hotkeys:'+#13+#10+' CTRL + UP  : inc volume'+#13+#10+' CTRL + Down : dec volume'+#13+#10+' CTRL + END : Stop'+#13+#10+' CTRL + HOME : Play/Pause'+#13+#10+#13+#10+'Right click trayicon to see options'+#13+#10+'Right click on channels to bind hotkeys'+#13+#10+'www.1clickmusic.net' ).SetPosition( 241, 124 ).SetSize( 216, 137 );
    Result.lblhelp.Font.Color := TColor(clMaroon);
    Result.lblradio := NewLabel( Result.Form, '' ).SetPosition( 245, 74 ).SetSize( 212, 0 );
    Result.lblradio.Font.Color := TColor(clPurple);
    Result.lblstatus := NewLabel( Result.Form, '' ).SetPosition( 480, 75 ).SetSize( 127, 18 );
    Result.lblstatus.Font.Color := TColor(clDefault);
    Result.lblstatus.TextAlign := KOL.taRight;
    Result.lblstatus.IgnoreDefault := TRUE;
    Result.lbltrack := NewLabel( Result.Form, '' ).SetPosition( 242, 8 ).SetSize( 366, 57 );
    Result.lbltrack.Font.Color := TColor(clTeal);
    Result.lbltrack.Font.FontStyle := [ fsBold ];
    Result.lbltrack.Font.FontHeight := 17;
    Result.lbltrack.TextAlign := KOL.taCenter;
    Result.channeltree := NewTreeView( Result.Form, [ tvoLinesRoot, tvoTrackSelect, tvoSingleExpand ], Result.treeimagelist, nil ).SetAlign ( caLeft ).SetSize( 231, 0 );
    Result.btplay := NewButton( Result.Form, 'Play' ).SetPosition( 534, 239 ).SetSize( 76, 0 ).LikeSpeedButton;
    Result.btplay.Font.FontStyle := [ fsBold ];
    Result.btplay.EraseBackground := TRUE;
    Result.pgrbuffer := NewProgressBarEx( Result.Form, [ pboSmooth ] ).SetPosition( 536, 93 ).SetSize( 71, 19 );
    Result.pgrbuffer.Visible := False;
    Result.pgrbuffer.Color := TColor(clBtnFace);
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

