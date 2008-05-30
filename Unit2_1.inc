{ KOL MCK } // Do not remove this line!

procedure NewForm2( var Result: PForm2; AParent: PControl );
begin

  {$IFDEF KOLCLASSES}
  Result := PForm2.Create;
  {$ELSE OBJECTS}
  New( Result, Create );
  {$ENDIF KOL CLASSES/OBJECTS}
  Result.Form := NewForm( AParent, 'Options' ).SetPosition( 481, 245 ).Tabulate;
  Result.Form.Add2AutoFree( Result );
{$IFDEF UNICODE_CTRLS}
     Result.Form.SetUnicode(TRUE);
{$ENDIF UNICODE_CTRLS}
   {$IFDEF USE_NAMES}
    Result.Form.SetName( Applet, 'Form2' );
   {$ENDIF}
    Result.Form.Style := Result.Form.Style and not WS_MAXIMIZEBOX;
    Result.Form.SetClientSize( 293, 336 );
    // Result.lblpass.TabOrder = -1
    Result.lblpass := NewLabel( Result.Form, 'Pass :' ).SetPosition( 16, 84 ).SetSize( 41, 0 );
   {$IFDEF USE_NAMES}
    Result.lblpass.SetName( Result.Form, 'lblpass' ); 
   {$ENDIF}
   {$IFDEF UNICODE_CTRLS}
   Result.lblpass.SetUnicode(TRUE);
   {$ENDIF UNICODE_CTRLS}
    Result.lblpass.Font.FontPitch := fpFixed;
    // Result.lblproxyhost.TabOrder = -1
    Result.lblproxyhost := NewLabel( Result.Form, 'Host :' ).SetPosition( 16, 52 ).SetSize( 41, 0 );
   {$IFDEF USE_NAMES}
    Result.lblproxyhost.SetName( Result.Form, 'lblproxyhost' ); 
   {$ENDIF}
   {$IFDEF UNICODE_CTRLS}
   Result.lblproxyhost.SetUnicode(TRUE);
   {$ENDIF UNICODE_CTRLS}
    Result.lblproxyhost.Font.FontPitch := fpFixed;
    // Result.lblproxyport.TabOrder = -1
    Result.lblproxyport := NewLabel( Result.Form, 'Port :' ).SetPosition( 16, 84 ).SetSize( 41, 0 );
   {$IFDEF USE_NAMES}
    Result.lblproxyport.SetName( Result.Form, 'lblproxyport' ); 
   {$ENDIF}
   {$IFDEF UNICODE_CTRLS}
   Result.lblproxyport.SetUnicode(TRUE);
   {$ENDIF UNICODE_CTRLS}
    Result.lblproxyport.Font.FontPitch := fpFixed;
    // Result.lbluser.TabOrder = -1
    Result.lbluser := NewLabel( Result.Form, 'User :' ).SetPosition( 16, 52 ).SetSize( 41, 0 );
   {$IFDEF USE_NAMES}
    Result.lbluser.SetName( Result.Form, 'lbluser' ); 
   {$ENDIF}
   {$IFDEF UNICODE_CTRLS}
   Result.lbluser.SetUnicode(TRUE);
   {$ENDIF UNICODE_CTRLS}
    Result.lbluser.Font.FontPitch := fpFixed;
    // Result.lblversion.TabOrder = -1
    Result.lblversion := NewLabel( Result.Form, '' ).SetPosition( 16, 296 ).SetSize( 257, 33 );
   {$IFDEF USE_NAMES}
    Result.lblversion.SetName( Result.Form, 'lblversion' ); 
   {$ENDIF}
   {$IFDEF UNICODE_CTRLS}
   Result.lblversion.SetUnicode(TRUE);
   {$ENDIF UNICODE_CTRLS}
    Result.lblversion.Font.FontHeight := 16;
    Result.lblversion.Font.FontName := 'Arial';
    Result.lblversion.Font.FontPitch := fpFixed;
    Result.lblversion.TextAlign := KOL.taRight;
    // Result.ckbxballons.TabOrder = 0
    Result.ckbxballons := NewCheckBox( Result.Form, 'Tray popups' ).SetPosition( 8, 24 ).SetSize( 113, 0 );
   {$IFDEF USE_NAMES}
    Result.ckbxballons.SetName( Result.Form, 'ckbxballons' ); 
   {$ENDIF}
   {$IFDEF UNICODE_CTRLS}
   Result.ckbxballons.SetUnicode(TRUE);
   {$ENDIF UNICODE_CTRLS}
    Result.ckbxballons.Tag := 10;
    Result.ckbxballons.Font.FontName := 'Arial';
    Result.ckbxballons.Font.FontPitch := fpFixed;
    // Result.ckbxtraycolors.TabOrder = 0
    Result.ckbxtraycolors := NewCheckBox( Result.Form, 'Trayicon colors' ).SetPosition( 8, 48 ).SetSize( 129, 0 );
   {$IFDEF USE_NAMES}
    Result.ckbxtraycolors.SetName( Result.Form, 'ckbxtraycolors' ); 
   {$ENDIF}
   {$IFDEF UNICODE_CTRLS}
   Result.ckbxtraycolors.SetUnicode(TRUE);
   {$ENDIF UNICODE_CTRLS}
    Result.ckbxtraycolors.Tag := 10;
    Result.ckbxtraycolors.Font.FontName := 'Arial';
    Result.ckbxtraycolors.Font.FontPitch := fpFixed;
    // Result.ckbxmsnenabled.TabOrder = 1
    Result.ckbxmsnenabled := NewCheckBox( Result.Form, 'Messenger Now playing' ).SetPosition( 8, 24 ).SetSize( 273, 0 );
   {$IFDEF USE_NAMES}
    Result.ckbxmsnenabled.SetName( Result.Form, 'ckbxmsnenabled' ); 
   {$ENDIF}
   {$IFDEF UNICODE_CTRLS}
   Result.ckbxmsnenabled.SetUnicode(TRUE);
   {$ENDIF UNICODE_CTRLS}
    Result.ckbxmsnenabled.Font.FontName := 'Arial';
    Result.ckbxmsnenabled.Font.FontPitch := fpFixed;
    // Result.cmbxmsnicon.TabOrder = 2
    Result.cmbxmsnicon := NewComboBox( Result.Form, [ coReadOnly, coNoIntegralHeight ] ).SetPosition( 16, 53 ).SetSize( 161, 0 );
   {$IFDEF USE_NAMES}
    Result.cmbxmsnicon.SetName( Result.Form, 'cmbxmsnicon' ); 
   {$ENDIF}
   {$IFDEF UNICODE_CTRLS}
   Result.cmbxmsnicon.SetUnicode(TRUE);
   {$ENDIF UNICODE_CTRLS}
    Result.cmbxmsnicon.Font.FontPitch := fpFixed;
    Result.cmbxmsnicon.Color := TColor(clWindow);
    Result.cmbxmsnicon.Items[ 0 ] := 'Headfone icon';
    Result.cmbxmsnicon.Items[ 1 ] := 'Games icon';
    Result.cmbxmsnicon.Items[ 2 ] := 'Office icon';
    Result.cmbxmsnicon.CurIndex := 0;
    // Result.ckbxlistenabled.TabOrder = 3
    Result.ckbxlistenabled := NewCheckBox( Result.Form, 'Listened tracks list' ).SetPosition( 8, 24 ).SetSize( 153, 0 );
   {$IFDEF USE_NAMES}
    Result.ckbxlistenabled.SetName( Result.Form, 'ckbxlistenabled' ); 
   {$ENDIF}
   {$IFDEF UNICODE_CTRLS}
   Result.ckbxlistenabled.SetUnicode(TRUE);
   {$ENDIF UNICODE_CTRLS}
    Result.ckbxlistenabled.Font.FontName := 'Arial';
    Result.ckbxlistenabled.Font.FontPitch := fpFixed;
    // Result.edtlistname.TabOrder = 4
    Result.edtlistname := NewEditBox( Result.Form, [  ] ).SetPosition( 16, 53 ).SetSize( 161, 0 );
   {$IFDEF USE_NAMES}
    Result.edtlistname.SetName( Result.Form, 'edtlistname' ); 
   {$ENDIF}
    Result.edtlistname.Font.FontPitch := fpFixed;
    {$IFNDEF UNICODE_CTRLS}Result.edtlistname.SetUnicode( TRUE );{$ENDIF}
    // Result.ckbxclipboard.TabOrder = 5
    Result.ckbxclipboard := NewCheckBox( Result.Form, 'Copy track name to Clipboard' ).SetPosition( 8, 82 ).SetSize( 273, 23 );
   {$IFDEF USE_NAMES}
    Result.ckbxclipboard.SetName( Result.Form, 'ckbxclipboard' ); 
   {$ENDIF}
   {$IFDEF UNICODE_CTRLS}
   Result.ckbxclipboard.SetUnicode(TRUE);
   {$ENDIF UNICODE_CTRLS}
    Result.ckbxclipboard.Font.FontName := 'Arial';
    Result.ckbxclipboard.Font.FontPitch := fpFixed;
    // Result.ckbxlastfm.TabOrder = 6
    Result.ckbxlastfm := NewCheckBox( Result.Form, 'Last.fm Scrobber plugin' ).SetPosition( 8, 24 ).SetSize( 273, 0 );
   {$IFDEF USE_NAMES}
    Result.ckbxlastfm.SetName( Result.Form, 'ckbxlastfm' ); 
   {$ENDIF}
   {$IFDEF UNICODE_CTRLS}
   Result.ckbxlastfm.SetUnicode(TRUE);
   {$ENDIF UNICODE_CTRLS}
    Result.ckbxlastfm.Font.FontName := 'Arial';
    Result.ckbxlastfm.Font.FontPitch := fpFixed;
    // Result.ckbxproxyenabled.TabOrder = 6
    Result.ckbxproxyenabled := NewCheckBox( Result.Form, 'Use http proxy' ).SetPosition( 8, 24 ).SetSize( 273, 0 );
   {$IFDEF USE_NAMES}
    Result.ckbxproxyenabled.SetName( Result.Form, 'ckbxproxyenabled' ); 
   {$ENDIF}
   {$IFDEF UNICODE_CTRLS}
   Result.ckbxproxyenabled.SetUnicode(TRUE);
   {$ENDIF UNICODE_CTRLS}
    Result.ckbxproxyenabled.Font.FontName := 'Arial';
    Result.ckbxproxyenabled.Font.FontPitch := fpFixed;
    // Result.edtproxyhost.TabOrder = 7
    Result.edtproxyhost := NewEditBox( Result.Form, [  ] ).SetPosition( 56, 51 ).SetSize( 162, 0 );
   {$IFDEF USE_NAMES}
    Result.edtproxyhost.SetName( Result.Form, 'edtproxyhost' ); 
   {$ENDIF}
    Result.edtproxyhost.Font.FontPitch := fpFixed;
    {$IFNDEF UNICODE_CTRLS}Result.edtproxyhost.SetUnicode( TRUE );{$ENDIF}
    // Result.edtuser.TabOrder = 7
    Result.edtuser := NewEditBox( Result.Form, [  ] ).SetPosition( 56, 51 ).SetSize( 162, 0 );
   {$IFDEF USE_NAMES}
    Result.edtuser.SetName( Result.Form, 'edtuser' ); 
   {$ENDIF}
    Result.edtuser.Font.FontPitch := fpFixed;
    {$IFNDEF UNICODE_CTRLS}Result.edtuser.SetUnicode( TRUE );{$ENDIF}
    // Result.edtpass.TabOrder = 8
    Result.edtpass := NewEditBox( Result.Form, [ eoPassword ] ).SetPosition( 56, 80 ).SetSize( 162, 0 );
   {$IFDEF USE_NAMES}
    Result.edtpass.SetName( Result.Form, 'edtpass' ); 
   {$ENDIF}
    Result.edtpass.Font.FontPitch := fpFixed;
    {$IFNDEF UNICODE_CTRLS}Result.edtpass.SetUnicode( TRUE );{$ENDIF}
    // Result.edtproxyport.TabOrder = 8
    Result.edtproxyport := NewEditBox( Result.Form, [ eoNumber ] ).SetPosition( 56, 80 ).SetSize( 162, 0 );
   {$IFDEF USE_NAMES}
    Result.edtproxyport.SetName( Result.Form, 'edtproxyport' ); 
   {$ENDIF}
    Result.edtproxyport.Font.FontPitch := fpFixed;
    {$IFNDEF UNICODE_CTRLS}Result.edtproxyport.SetUnicode( TRUE );{$ENDIF}
    // Result.btapply.TabOrder = 9
    Result.btapply := NewButton( Result.Form, 'Apply' ).SetPosition( 75, 268 );
   {$IFDEF USE_NAMES}
    Result.btapply.SetName( Result.Form, 'btapply' ); 
   {$ENDIF}
   {$IFDEF UNICODE_CTRLS}
   Result.btapply.SetUnicode(TRUE);
   {$ENDIF UNICODE_CTRLS}
    Result.btapply.Font.FontPitch := fpFixed;
    // Result.btupdate.TabOrder = 10
    Result.btupdate := NewButton( Result.Form, 'Update!' ).SetPosition( 147, 268 );
   {$IFDEF USE_NAMES}
    Result.btupdate.SetName( Result.Form, 'btupdate' ); 
   {$ENDIF}
   {$IFDEF UNICODE_CTRLS}
   Result.btupdate.SetUnicode(TRUE);
   {$ENDIF UNICODE_CTRLS}
    Result.btupdate.Font.FontPitch := fpFixed;
    // Result.tabs.TabOrder = 11
    Result.tabs := NewTabControl( Result.Form, [  ], [ tcoMultiline ], nil, 0 ).SetAlign ( caTop ).SetSize( 0, 263 );
   {$IFDEF USE_NAMES}
    Result.tabs.SetName( Result.Form, 'tabs' ); 
   {$ENDIF}
   {$IFDEF UNICODE_CTRLS}
   Result.tabs.SetUnicode(TRUE);
   {$ENDIF UNICODE_CTRLS}
    Result.tabs.TabStop := FALSE;
    Result.tabs.Font.FontHeight := 15;
    Result.tabs.Font.FontName := 'Arial';
      Result.ckbxmsnenabled.OnClick := Result.ckbxmsnenabledClick;
      Result.ckbxlistenabled.OnClick := Result.ckbxlistenabledClick;
    Result.edtlistname.Color := TColor(clWindow);
      Result.ckbxlastfm.OnClick := Result.ckbxlastfmClick;
      Result.ckbxproxyenabled.OnClick := Result.ckbxproxyenabledClick;
    Result.edtproxyhost.Color := TColor(clWindow);
    Result.edtuser.Color := TColor(clWindow);
    Result.edtpass.Color := TColor(clWindow);
    Result.edtproxyport.Color := TColor(clWindow);
      Result.btapply.OnClick := Result.btapplyClick;
    Result.btapply.DefaultBtn := TRUE;
      Result.btupdate.OnClick := Result.btupdateClick;
    Result.Form.CenterOnParent.CanResize := False;
    Result.Form.Perform( WM_INITMENU, 0, 0 );
    Result.KOLForm1FormCreate( Result );

end;

