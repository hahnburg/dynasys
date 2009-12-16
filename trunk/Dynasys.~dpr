program Dynasys;

{%ToDo 'Dynasys.todo'}

uses
  Forms,
  Dynamain in 'DYNAMAIN.PAS' {MainForm},
  DynaAbout in 'DynaAbout.pas' {AboutBox},
  ModEditor in 'ModEditor.pas' {Modelleditor},
  Liste in 'LISTE.PAS',
  SimObjekt in 'SimObjekt.pas',
  Geoutil in 'GEOUTIL.PAS',
  ObjectDlg in 'ObjectDlg.pas' {ObjektDialog},
  MatheLehrer in 'MatheLehrer.pas',
  Parser in 'PARSER.PAS',
  Util in 'UTIL.PAS',
  Errortxt in 'ERRORTXT.PAS',
  Tabelle in 'TABELLE.PAS' {TabForm},
  Gleichung in 'Gleichung.pas' {Gleichungen},
  ZeitSelect in 'ZeitSelect.pas' {ZeitkurveDlg},
  Numerik in 'NUMERIK.PAS' {NumerikDlg},
  Info in 'info.pas' {ModellInfo},
  Simulation in 'Simulation.pas',
  Funktion in 'FUNKTION.PAS',
  Diagram in 'DIAGRAM.PAS',
  Optionen in 'OPTIONEN.PAS' {OptionenDlg},
  Tabselect in 'Tabselect.pas' {TabelleDlg},
  RegDialog in 'RegDialog.pas' {RegisterDlg},
  ShareDlg in 'ShareDlg.pas' {SharewareDlg},
  Register in 'Register.pas',
  PhaseSelect in 'PhaseSelect.pas' {PhasenAuswahl},
  PhaseWin in 'PhaseWin.pas' {PhaseForm},
  GraphWin in 'GraphWin.pas' {GraphForm},
  TabEdit in 'TabEdit.pas' {TabEditForm};

{$R *.RES}

begin
  Application.Title := 'Dynasys';
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
  Application.HelpFile := 'dynasys.hlp';
  Application.Run;
end.
