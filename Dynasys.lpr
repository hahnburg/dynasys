program Dynasys;

{$MODE Delphi}

{%ToDo 'Dynasys.todo'}

uses
  {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads,
  {$ENDIF}{$ENDIF}
  Forms, Interfaces,
  DynaMain in 'DynaMain.pas' {MainForm},
  DynaAbout in 'DynaAbout.pas' {AboutBox},
  ModEditor in 'ModEditor.pas' {Modelleditor},
  Liste in 'Liste.pas',
  SimObjekt in 'SimObjekt.pas',
//  Einstell in 'Einstell.pas' {EinstellDlg},
  Geoutil in 'GeoUtil.pas',
  ObjectDlg in 'ObjectDlg.pas' {ObjektDialog},
  MatheLehrer in 'MatheLehrer.pas',
  Parser in 'Parser.pas',
  Util in 'Util.pas',
  Errortxt in 'ErrorTxt.pas',
  Tabelle in 'Tabelle.pas' {TabForm},
  Gleichung in 'Gleichung.pas' {Gleichungen},
  ZeitSelect in 'ZeitSelect.pas' {ZeitkurveDlg},
  Numerik in 'Numerik.pas' {NumerikDlg},
  Info in 'Info.pas' {ModellInfo},
  Simulation in 'Simulation.pas',
  Funktion in 'Funktion.pas',
  Diagram in 'Diagram.pas',
  Optionen in 'Optionen.pas' {OptionenDlg},
  Tabselect in 'TabSelect.pas' {TabelleDlg},
  RegDialog in 'RegDialog.pas' {RegisterDlg},
  ShareDlg in 'ShareDlg.pas' {SharewareDlg},
  Register in 'Register.pas',
  PhaseSelect in 'PhaseSelect.pas' {PhasenAuswahl},
  PhaseWin in 'PhaseWin.pas' {PhaseForm},
  GraphWin in 'GraphWin.pas' {GraphForm},
  TabEdit in 'TabEdit.pas';
//  Zeitdiag in 'ZeitDiag.pas' {ZeitkurveForm} ;

begin
  Application.Initialize;
  Application.CreateForm(TMainForm, MainForm);
  Application.CreateForm(TModelleditor, Modelleditor);
  Application.CreateForm(TObjektDialog, ObjektDialog);
  Application.CreateForm(TAboutBox, AboutBox);
  Application.CreateForm(TNumerikDlg, NumerikDlg);
  Application.CreateForm(TModellInfo, ModellInfo);
  Application.CreateForm(TOptionenDlg, OptionenDlg);
  Application.CreateForm(TTabelleDlg, TabelleDlg);
  Application.CreateForm(TZeitkurveDlg, ZeitkurveDlg);
  Application.CreateForm(TRegisterDlg, RegisterDlg);
  Application.CreateForm(TSharewareDlg, SharewareDlg);
  Application.CreateForm(TPhasenAuswahl, PhasenAuswahl);
  Application.CreateForm(TTabEditForm, TabEditForm);
//  Application.CreateForm(TEinstellDlg, EinstellDlg);
//  Application.CreateForm(TGleichungen, Gleichungen);
//  Application.CreateForm(TGraphForm, GraphForm);
//  Application.CreateForm(TPhaseForm, PhaseForm);
//  Application.CreateForm(TTabForm, TabForm);
//  Application.CreateForm(TZeitkurveForm, ZeitkurveForm);
  Application.Run;
end.
