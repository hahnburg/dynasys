(* Dynasys, http://code.google.com/p/dynasys/
 * Copyright (C) 2009  Dynasys
 * 
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 * 
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 * GNU General Public License for more details.
 * 
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http:www.gnu.org/licenses/>.
 *)

unit DynaMain;

(*
  Dynasys-Hauptfenster (als MDI-Application)
  Autor: Walter Hupfeld
  Version: 2.0
  zuletzt bearbeitet:  3.9.2003
*)

interface

uses
  SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls,
  Forms, Dialogs, StdCtrls, Buttons, ExtCtrls, Menus,
  DynaAbout, ModEditor,
  Tabelle,  Gleichung, Liste, ErrorTxt, Numerik, Info,
  Simulation, Gauges, Einstell, GraphWin, PhaseWin, Optionen, ShareDlg,
  IniFiles, Register;

type
  TMainForm = class(TForm)
    MainMenu: TMainMenu;
    FileNewItem: TMenuItem;
    FileOpenItem: TMenuItem;
    FileSaveItem: TMenuItem;
    FileSaveAsItem: TMenuItem;
    FilePrintItem: TMenuItem;
    FilePrintSetupItem: TMenuItem;
    FileExitItem: TMenuItem;
    EditCutItem: TMenuItem;
    EditCopyItem: TMenuItem;
    EditPasteItem: TMenuItem;
    WindowTileItem: TMenuItem;
    WindowCascadeItem: TMenuItem;
    WindowArrangeItem: TMenuItem;
    HelpContentsItem: TMenuItem;
    HelpSearchItem: TMenuItem;
    HelpHowToUseItem: TMenuItem;
    HelpAboutItem: TMenuItem;
    StatusLine: TPanel;
    OpenDialog: TOpenDialog;
    SaveDialog: TSaveDialog;
    PrintDialog: TPrintDialog;
    PrintSetupDialog: TPrinterSetupDialog;
    SpeedBar: TPanel;
    SpeedButton1: TSpeedButton;  { &Neu }
    SpeedButton2: TSpeedButton;  { &Öffnen... }
    SpeedButton3: TSpeedButton;  { &Speichern }
    SpeedButton4: TSpeedButton;  { &Drucken... }
    SpeedButton5: TSpeedButton;  { &Ausschneiden }
    SpeedButton6: TSpeedButton;  { &Kopieren }
    SpeedButton7: TSpeedButton;  { &Einfügen }
    SpeedButton11: TSpeedButton;
    SpeedButton12: TSpeedButton;
    SpeedButton13: TSpeedButton;
    SpeedButton14: TSpeedButton;
    SpeedButton15: TSpeedButton;
    SpeedButton16: TSpeedButton;

    TabelleButton: TSpeedButton;
    GleichungButton: TSpeedButton;  { &Symbole anordnen }
    Simulation1: TMenuItem;
    Starten1: TMenuItem;
    Weiterrechnen1: TMenuItem;
    N2: TMenuItem;
    Modellinfo1: TMenuItem;
    Ausgabe1: TMenuItem;
    Zeitdiagramm1: TMenuItem;
    Phasendiagramm1: TMenuItem;
    Tabelle1: TMenuItem;
    Gleichungen1: TMenuItem;
    Einstellungen: TMenuItem;
    Numerik1: TMenuItem;
    N5: TMenuItem;
    Gauge1: TGauge;
    N6: TMenuItem;
    Registrierung1: TMenuItem;
    N7: TMenuItem;
    Shareware1: TMenuItem;
    Timer1: TTimer;  { &Inhalt }
    procedure FormCreate(Sender: TObject);
    procedure ShowHint(Sender: TObject);
    procedure FileNew(Sender: TObject);
    procedure FileOpen(Sender: TObject);
    procedure FileSave(Sender: TObject);
    procedure FileSaveAs(Sender: TObject);
    procedure FilePrint(Sender: TObject);
    procedure FilePrintSetup(Sender: TObject);
    procedure FileExit(Sender: TObject);
    procedure EditUndo(Sender: TObject);
    procedure EditCut(Sender: TObject);
    procedure EditCopy(Sender: TObject);
    procedure EditPaste(Sender: TObject);
    procedure WindowTile(Sender: TObject);
    procedure WindowCascade(Sender: TObject);
    procedure WindowArrange(Sender: TObject);
    procedure HelpContents(Sender: TObject);
    procedure HelpSearch(Sender: TObject);
    procedure HelpHowToUse(Sender: TObject);
    procedure HelpAbout(Sender: TObject);
    procedure TabelleButtonClick(Sender: TObject);
    procedure GleichungButtonClick(Sender: TObject);
    procedure Numerik1Click(Sender: TObject);
    procedure Modellinfo1Click(Sender: TObject);
    procedure Starten1Click(Sender: TObject);
    procedure EinstellungenClick(Sender: TObject);
    procedure Zeitdiagramm1Click(Sender: TObject);
    procedure PhasendiagrammClick(Sender: TObject);
    procedure Shareware1Click(Sender: TObject);
    procedure Registrierung1Click(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
   private
    DateiVorhanden : Boolean;
   public
    Version        : String;
    FileName       : String;
    ChangeFlag     : Boolean;
    Name,Strasse,Wohnort,Nummer : String;
    registriert    : Boolean;
  end;

var
  MainForm: TMainForm;

implementation

uses RegDialog;

{$R *.DFM}

procedure TMainForm.FormCreate(Sender: TObject);
var DynasysIni : TIniFile;
    HomePath  : string;
    DefaultStr: string;
begin
  MainForm.Version := '2.0.2';
  MainForm.Caption := 'Dynasys '+MainForm.Version;
  Application.Title := 'Dynasys '+MainForm.Version;
  Application.OnHint := ShowHint;
  DateiVorhanden:=false;
  ChangeFlag:=false;
  FileName:='';
  Gauge1.visible:=false;
  self.left:=screen.width  div 20;
  self.top:=screen.width div 40;
  self.width:=screen.width*9 div 10;
  self.height:=screen.height*9 div 10;;
  // Status-Zeile ---------------------------------------------
  StatusLine.Caption:='Dynasys '+MainForm.Version;
  Application.OnHint := ShowHint;
  (*Screen.OnActiveFormChange := UpdateMenuItems;*)

  // Registrierung --------------------------------------------
  HomePath:=Paramstr(0);
  HomePath:=ExtractFilePath(HomePath);
  DynasysIni := TIniFile.Create(HomePath+'Dynasys.ini');
  Name    :=DynasysIni.ReadString('Registrierung','Name','');
  Strasse :=DynasysIni.ReadString('Registrierung','Strasse','');
  Wohnort :=DynasysIni.ReadString('Registrierung','Wohnort','');
  Nummer  :=DynasysIni.ReadString('Registrierung','Nummer','');
  Registriert := LicenceOk(Nummer,Name,Strasse,Wohnort);
  DynasysIni.free;
  if registriert then begin
    DefaultStr:=Name+', '+Wohnort;
    shareware1.visible:=false;
  end
  else
      DefaultStr:='Der Einsatz dieser Version im Unterricht ist nicht erlaubt!';

  StatusLine.Caption:=DefaultStr;
end;

procedure TMainForm.ShowHint(Sender: TObject);
begin
  StatusLine.Caption := Application.Hint;
end;

procedure TMainForm.FileNew(Sender: TObject);
var result : integer;
begin
  if ChangeFlag then begin
       Result:=MessageDlg(InfoTxt1,  mtConfirmation,mbYesNoCancel,0);
       if result=mrCancel then exit
       else if result=mrYes then FileSave(Sender);
  end;
  ObjektListe.LoescheAlles;
  ModellInfo.Clear;
  Modelleditor.Neuzeichnen1Click(Sender);
  Filename:='';
  Changeflag:=false;
  DateiVorhanden:=false;
end;

procedure TMainForm.FileOpen(Sender: TObject);
var S:TStream;
    R:TReader;
    Kennung:LongInt;
begin
  if ChangeFlag then
       if mrCancel=MessageDlg(InfoTxt2,mtConfirmation,mbOKCancel,0) then Exit;
  if OpenDialog.Execute then
  begin
    ObjektListe.LoescheAlles;
    Modelleditor.Neuzeichnen1Click(Sender);
    Filename:=OpenDialog.FileName;
    try
      S:=TFileStream.Create(FileName,fmOpenRead);
   except
      MessageDlg(ErrorTxt21,mtError,[mbok],0);
      S.free;
      exit;
    end;

      R:=TReader.Create(S,2048);
      Kennung:=R.ReadInteger;
      If Kennung=3035401 then begin
        try
         ObjektListe.Lesen(R);
         NumerikDlg.LoadData(R);
         ModellInfo.ReadData(R);
        except
          MessageDlg(ErrorTxt22,mtError,[mbok],0);
        end;
      end else MessageDlg(ErrorTxt22,mtError,[mbok],0);
      R.Free;
      S.Free;

    Changeflag:=false;
    DateiVorhanden:=true;
  end;
end;

procedure TMainForm.FileSave(Sender: TObject);
var S:TStream;
    W:TWriter;
begin
//if ObjektListe.ModellGueltig<>0 then
  If Dateivorhanden then begin
    S:=TFileStream.Create(FileName,fmCreate);
    W:=TWriter.Create(S,2048);
    W.WriteInteger(3035401);
    ObjektListe.Speichern(W);
    NumerikDlg.StoreData(W);
    ModellInfo.StoreData(W);
    W.Free;
    S.Free;
  end else
    FileSaveAs(Sender);
end;

procedure TMainForm.FileSaveAs(Sender: TObject);
begin
  if SaveDialog.Execute then
  begin
    FileName:=SaveDialog.FileName;
    (*MainForm.Caption:=FileName;*)
    DateiVorhanden:=true;
    // Falls Datei vorhanden ist - nachfragen
    if FileExists(FileName) then
       if MessageDlg('Wollen Sie ' + ExtractFileName(FileName)
         + ' wirklich überschreiben?',mtWarning,[mbYes,mbNo],0) <> mrYes
    then exit;
    FileSave(Sender);
  end;
end;

procedure TMainForm.FilePrint(Sender: TObject);
begin
  if PrintDialog.Execute then
  begin
    { Programmcode zum Drucken der aktuellen Datei hier einfügen }
  end;
end;

procedure TMainForm.FilePrintSetup(Sender: TObject);
begin
  PrintSetupDialog.Execute;
end;

procedure TMainForm.FileExit(Sender: TObject);
var res : integer;
begin
  if ChangeFlag then begin
      res:=MessageDlg(InfoTxt3,mtConfirmation,mbyesnocancel,0);
      if res=mrcancel then exit
      else if res=mrok then ;
  end;
  Close;
end;

procedure TMainForm.EditUndo(Sender: TObject);
begin
  { Programmcode zur Ausführung von Bearbeiten Rückgänging hier einfügen }
end;

procedure TMainForm.EditCut(Sender: TObject);
begin
  // Vorläufig
  ModellEditor.LoeschenClick(Sender);
end;

procedure TMainForm.EditCopy(Sender: TObject);
begin
  { Programmcode zur Ausführung von Bearbeiten Kopieren hier einfügen }
end;

procedure TMainForm.EditPaste(Sender: TObject);
begin
  { Programmcode zur Ausführung von Bearbeiten Einfügen hier einfügen }
end;

procedure TMainForm.WindowTile(Sender: TObject);
begin
  Tile;
end;

procedure TMainForm.WindowCascade(Sender: TObject);
begin
  Cascade;
end;

procedure TMainForm.WindowArrange(Sender: TObject);
begin
  ArrangeIcons;
end;

procedure TMainForm.HelpContents(Sender: TObject);
begin
  Application.HelpCommand(HELP_CONTENTS, 0);
end;

procedure TMainForm.HelpSearch(Sender: TObject);
const
  EmptyString: PChar = '';
begin
  Application.HelpCommand(HELP_PARTIALKEY, Longint(EmptyString));
end;

procedure TMainForm.HelpHowToUse(Sender: TObject);
begin
  Application.HelpCommand(HELP_HELPONHELP, 0);
end;

procedure TMainForm.HelpAbout(Sender: TObject);
begin
  AboutBox.ShowModal
end;

procedure TMainForm.TabelleButtonClick(Sender: TObject);
begin
  if ObjektListe.ModellGueltig<>0 then begin
    TabForm:=TTabForm.Create(Application);
    TabForm.show;
    Starten1Click(Sender);
 end else MessageDlg(ErrorTxt23, mtInformation,[mbOk], 0);
end;

procedure TMainForm.GleichungButtonClick(Sender: TObject);
var Gleichungen:TGleichungen;
begin
  Gleichungen:=TGleichungen.Create(Application);
  Gleichungen.Show;
end;

procedure TMainForm.Zeitdiagramm1Click(Sender: TObject);
var GraphForm:TGraphForm;
begin
  if ObjektListe.ModellGueltig<>0 then begin
    GraphForm:=TGraphForm.Create(Application);
    GraphForm.Show;
    (*Application.MessageBox(PChar(GraphForm.ModalResult), 'abc');
    MessageDlg(String(GraphForm.ModalResult), mtInformation,[mbOk], 0);   *)
    If GraphForm.ModalResult<>mrCancel then
    Starten1Click(Sender);
  end else MessageDlg(ErrorTxt23, mtInformation,[mbOk], 0);

end;

procedure TMainForm.PhasendiagrammClick(Sender: TObject);
  //MessageDlg('In dieser Version noch nicht verfügbar!', mtInformation, [mbOk], 0);
var GraphForm:TGraphForm;
begin
  if ObjektListe.ModellGueltig<>0 then begin
    PhaseForm:=TPhaseForm.Create(Application);
    if (PhaseForm.isClosed=false) then begin
    PhaseForm.Show;
    Starten1Click(Sender);
    end else begin
    PhaseForm.Close
    end;
  end else MessageDlg(ErrorTxt23, mtInformation,[mbOk], 0);
end;


procedure TMainForm.Numerik1Click(Sender: TObject);
begin
  { NumerikDialog aufrufen }
   NumerikDlg.ShowModal;
end;

procedure TMainForm.Modellinfo1Click(Sender: TObject);
begin
  ModellInfo.ShowModal;
end;

procedure TMainForm.Starten1Click(Sender: TObject);
begin
  Gauge1.left:=self.width-Gauge1.width-30;
  Screen.Cursor:=crHourGlass;
  Gauge1.visible:=true;
  Gauge1.progress:=0;
  Simulator.StarteBerechnung;
  Gauge1.progress:=0;
  Screen.Cursor:=crDefault;
  Gauge1.visible:=false;
end;

procedure TMainForm.EinstellungenClick(Sender: TObject);
begin
  OptionenDlg.ShowModal;
end;

procedure TMainForm.Shareware1Click(Sender: TObject);
begin
  SharewareDlg.ShowModal;
end;

procedure TMainForm.Registrierung1Click(Sender: TObject);
begin
   RegisterDlg.ShowModal;
end;

procedure TMainForm.Timer1Timer(Sender: TObject);
begin
   Timer1.Enabled:=false;
   Timer1.Free;
   if not registriert then ShareWareDlg.ShowModal;
end;

end.
