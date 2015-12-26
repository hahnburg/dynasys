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

unit RegDialog;

{$MODE Delphi}

interface

uses SysUtils, unix, Classes, Graphics, Forms, Controls, Buttons,
  StdCtrls, ExtCtrls, Dialogs, IniFiles, Register;

type
  TRegisterDlg = class(TForm)
    OKBtn: TBitBtn;
    CancelBtn: TBitBtn;
    Bevel1: TBevel;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    RegName: TEdit;
    RegStrasse: TEdit;
    RegOrt: TEdit;
    RegNummer: TEdit;
    procedure OKBtnClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormActivate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  RegisterDlg: TRegisterDlg;

implementation
uses DynaMain;

{$R *.lfm}

procedure TRegisterDlg.OKBtnClick(Sender: TObject);
var  DynasysIni  : TIniFile;
     HomePath : String;
begin
  MainForm.Registriert:=LicenceOK(RegNummer.Text,RegName.text,RegStrasse.text,RegOrt.text);
  If MainForm.Registriert Then Begin
    MessageDlg('Registrierung korrekt ausgeführt.'+
    #13+#10+'Beim nächsten Programmstart meldet sich Dynasys als registrierte Version.',
    mtInformation,[mbOk],0);
  end
  Else
  Begin
    MessageDlg('Registrierung fehlgeschlagen?',mtError,[mbok],0);
    RegName.Text:='';
    RegStrasse.Text:='';
    RegOrt.Text:='';
    RegNummer.Text:='';
  End;
  HomePath:=Paramstr(0);
  HomePath:=ExtractFilePath(HomePath);
  DynasysIni := TIniFile.Create(HomePath+'Dynasys.ini');
  DynasysIni.WriteString('Registrierung','Name',RegName.Text);
  DynasysIni.WriteString('Registrierung','Strasse',RegStrasse.Text);
  DynasysIni.WriteString('Registrierung','Wohnort',RegOrt.Text);
  DynasysIni.WriteString('Registrierung','Nummer',RegNummer.Text);
  DynasysIni.Free;
end;

procedure TRegisterDlg.FormShow(Sender: TObject);
begin
  RegName.SetFocus;
end;

procedure TRegisterDlg.FormActivate(Sender: TObject);
var  DynasysIni  : TIniFile;
     HomePath : String;
begin
  HomePath:=Paramstr(0);
  HomePath:=ExtractFilePath(HomePath);
  DynasysIni := TIniFile.Create(HomePath+'Dynasys.ini');
  RegName.Text:=DynasysIni.ReadString('Registrierung','Name','Bitte registrieren!');
  RegStrasse.Text:=DynasysIni.ReadString('Registrierung','Strasse','');
  RegOrt.Text:=DynasysIni.ReadString('Registrierung','Wohnort','');
  RegNummer.Text:=DynasysIni.ReadString('Registrierung','Nummer','');
end;

end.
