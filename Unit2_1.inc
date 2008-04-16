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
    Result.Form.SetClientSize( 285, 335 );
    // Result.lblpass.TabOrder = -1
    Result.lblpass := NewLabel( Result.Form, 'Pass :' ).SetPosition( 16, 244 ).SetSize( 41, 0 );
   {$IFDEF USE_NAMES}
    Result.lblpass.SetName( Result.Form, 'lblpass' ); 
   {$ENDIF}
   {$IFDEF UNICODE_CTRLS}
   Result.lblpass.SetUnicode(TRUE);
   {$ENDIF UNICODE_CTRLS}
    Result.lblpass.Font.FontPitch := fpFixed;
    // Result.lbluser.TabOrder = -1
    Result.lbluser := NewLabel( Result.Form, 'User :' ).SetPosition( 16, 212 ).SetSize( 41, 0 );
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
    Result.ckbxballons := NewCheckBox( Result.Form, 'Tray popups' ).SetPosition( 8, 8 ).SetSize( 273, 0 );
   {$IFDEF USE_NAMES}
    Result.ckbxballons.SetName( Result.Form, 'ckbxballons' ); 
   {$ENDIF}
   {$IFDEF UNICODE_CTRLS}
   Result.ckbxballons.SetUnicode(TRUE);
   {$ENDIF UNICODE_CTRLS}
    Result.ckbxballons.Font.FontName := 'Arial';
    Result.ckbxballons.Font.FontPitch := fpFixed;
    // Result.ckbxmsnenabled.TabOrder = 1
    Result.ckbxmsnenabled := NewCheckBox( Result.Form, 'Messenger Now playing' ).SetPosition( 8, 40 ).SetSize( 273, 0 );
   {$IFDEF USE_NAMES}
    Result.ckbxmsnenabled.SetName( Result.Form, 'ckbxmsnenabled' ); 
   {$ENDIF}
   {$IFDEF UNICODE_CTRLS}
   Result.ckbxmsnenabled.SetUnicode(TRUE);
   {$ENDIF UNICODE_CTRLS}
    Result.ckbxmsnenabled.Font.FontName := 'Arial';
    Result.ckbxmsnenabled.Font.FontPitch := fpFixed;
    // Result.cmbxmsnicon.TabOrder = 2
    Result.cmbxmsnicon := NewComboBox( Result.Form, [ coReadOnly, coNoIntegralHeight ] ).SetPosition( 16, 69 ).SetSize( 161, 0 );
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
    Result.ckbxlistenabled := NewCheckBox( Result.Form, 'Listened tracks list' ).SetPosition( 8, 97 ).SetSize( 153, 0 );
   {$IFDEF USE_NAMES}
    Result.ckbxlistenabled.SetName( Result.Form, 'ckbxlistenabled' ); 
   {$ENDIF}
   {$IFDEF UNICODE_CTRLS}
   Result.ckbxlistenabled.SetUnicode(TRUE);
   {$ENDIF UNICODE_CTRLS}
    Result.ckbxlistenabled.Font.FontName := 'Arial';
    Result.ckbxlistenabled.Font.FontPitch := fpFixed;
    // Result.edtlistname.TabOrder = 4
    Result.edtlistname := NewEditBox( Result.Form, [  ] ).SetPosition( 16, 126 ).SetSize( 161, 0 );
   {$IFDEF USE_NAMES}
    Result.edtlistname.SetName( Result.Form, 'edtlistname' ); 
   {$ENDIF}
    Result.edtlistname.Font.FontPitch := fpFixed;
    {$IFNDEF UNICODE_CTRLS}Result.edtlistname.SetUnicode( TRUE );{$ENDIF}
    // Result.ckbxclipboard.TabOrder = 5
    Result.ckbxclipboard := NewCheckBox( Result.Form, 'Copy track name to Clipboard' ).SetPosition( 8, 154 ).SetSize( 273, 0 );
   {$IFDEF USE_NAMES}
    Result.ckbxclipboard.SetName( Result.Form, 'ckbxclipboard' ); 
   {$ENDIF}
   {$IFDEF UNICODE_CTRLS}
   Result.ckbxclipboard.SetUnicode(TRUE);
   {$ENDIF UNICODE_CTRLS}
    Result.ckbxclipboard.Font.FontName := 'Arial';
    Result.ckbxclipboard.Font.FontPitch := fpFixed;
    // Result.ckbxlastfm.TabOrder = 6
    Result.ckbxlastfm := NewCheckBox( Result.Form, 'Last.fm Scrobber plugin' ).SetPosition( 8, 183 ).SetSize( 273, 0 );
   {$IFDEF USE_NAMES}
    Result.ckbxlastfm.SetName( Result.Form, 'ckbxlastfm' ); 
   {$ENDIF}
   {$IFDEF UNICODE_CTRLS}
   Result.ckbxlastfm.SetUnicode(TRUE);
   {$ENDIF UNICODE_CTRLS}
    Result.ckbxlastfm.Font.FontName := 'Arial';
    Result.ckbxlastfm.Font.FontPitch := fpFixed;
    // Result.edtuser.TabOrder = 7
    Result.edtuser := NewEditBox( Result.Form, [  ] ).SetPosition( 56, 211 ).SetSize( 162, 0 );
   {$IFDEF USE_NAMES}
    Result.edtuser.SetName( Result.Form, 'edtuser' ); 
   {$ENDIF}
    Result.edtuser.Font.FontPitch := fpFixed;
    {$IFNDEF UNICODE_CTRLS}Result.edtuser.SetUnicode( TRUE );{$ENDIF}
    // Result.edtpass.TabOrder = 8
    Result.edtpass := NewEditBox( Result.Form, [ eoPassword ] ).SetPosition( 56, 240 ).SetSize( 162, 0 );
   {$IFDEF USE_NAMES}
    Result.edtpass.SetName( Result.Form, 'edtpass' ); 
   {$ENDIF}
    Result.edtpass.Font.FontPitch := fpFixed;
    {$IFNDEF UNICODE_CTRLS}Result.edtpass.SetUnicode( TRUE );{$ENDIF}
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
      Result.ckbxlistenabled.OnClick := Result.ckbxlistenabledClick;
    Result.edtlistname.Color := TColor(clWindow);
      Result.ckbxlastfm.OnClick := Result.ckbxlastfmClick;
    Result.edtuser.Color := TColor(clWindow);
      Result.ckbxmsnenabled.OnClick := Result.ckbxmsnenabledClick;
      Result.btapply.OnClick := Result.btapplyClick;
    Result.btapply.DefaultBtn := TRUE;
      Result.btupdate.OnClick := Result.btupdateClick;
    Result.edtpass.Color := TColor(clWindow);
    Result.Form.CenterOnParent.CanResize := False;
    Result.Form.Perform( WM_INITMENU, 0, 0 );
    Result.KOLForm1FormCreate( Result );

end;

