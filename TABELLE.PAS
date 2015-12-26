unit Tabelle;

{$MODE Delphi}

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

(*
  Darstellung der Ergebnisse in einer Tabelle
  Version: 2.0
*)

interface

uses
  SysUtils, unix, Messages, Classes, Graphics, Controls, LCLType,
  Forms, StdCtrls, Dialogs, Grids, Tabselect, Liste, SimObjekt, Menus;

type
  TTabForm = class(TForm)
    Tabelle: TStringGrid;
    TabellenPopup: TPopupMenu;
    Kopieren1: TMenuItem;
    N1: TMenuItem;
    Optionen1: TMenuItem;
    Drucken1: TMenuItem;
    Optionen2: TMenuItem;
    N2: TMenuItem;
    procedure FormShow(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure InitWerte(Schritte:integer);
    procedure HoleWerte(Zeit:double);
    procedure ExitWerte(Minimum,Maximum:double);
    procedure Optionen2Click(Sender: TObject);
  private
    AktZeile : integer;
    Data  : Double;
  public
    { Public-Deklarationen }
    TabelleDlg:TTabelleDlg;
    InputList:TStringList;
    stellen : integer;
  end;

var
  TabForm: TTabForm;

implementation

{$R *.lfm}

procedure TTabForm.FormShow(Sender: TObject);
var i:integer;
begin
  for i:=0 to TabelleDlg.DstList.items.count-1 do
     InputList.add(TabelleDlg.DstList.items[i]);

   Tabelle.ColCount:=InputList.Count+1;
   Tabelle.RowCount:=110;                  // ?????

   // Überschriften setzen
   For i:=0 to InputList.Count-1 do
     Tabelle.Cells[i+1,0]:=InputList.strings[i];


   // If (Tabelle.ColCount*Tabelle.defaultcolWidth)<self.width Then
   //     Tabelle.DefaultColWidth:=round(self.width div Tabelle.colCount);
   Tabelle.Cells[0,0]:='Zeit';
end;


procedure TTabForm.FormCreate(Sender: TObject);
begin
  InputList:=TStringList.Create;
  stellen:=2;
  try
    TabelleDlg:=TTabelleDlg.Create(self);
    AktZeile:=1;
    if TabelleDlg.ShowModal = idCancel Then
      begin
        self.close;
      end;
  except
    MessageDlg('Fehler beim Öffnen des Dialogs!',mtError,[mbok],0);
  end
end;


procedure TTabForm.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  CanClose:=true;
end;

procedure TTabForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action := caFree;
end;

procedure TTabForm.HoleWerte(Zeit:Double);
var i,j : integer;
    AktSpalte : integer;
    Eintrag   : String[40];
begin
  { in die 0. Spalte kommt die Zeit }
  Stellen:=TabelleDlg.SpinEdit1.Value;
  Tabelle.cells[0,AktZeile]:=FloatToStrF(Zeit,ffNumber,15,2);
  AktSpalte:=1;
//todo  for j:=1 to Tabelle.ColCount do
    for j:=0 to Tabelle.ColCount-1 do
    begin
      Eintrag:=Tabelle.Cells[j,0];
      for i:=0 to ObjektListe.count-1 do
         with ObjektListe.items[i] do
            if Eintrag=name then
              Tabelle.cells[j,AktZeile]:=FloatToStrF(G_Wert,ffNumber,15,stellen);
    end;
  Inc(AktZeile);
end;

Procedure TTabForm.ExitWerte(Minimum,Maximum:double);
Begin
 { nicht loeschen }
End;

procedure TTabForm.InitWerte(Schritte:integer);
var i,j : integer;
begin
  {Tabelle loeschen }
  for i:=1 to Tabelle.RowCount-1 do
    for j:=0 to Tabelle.ColCount-1 do
      Tabelle.cells[j,i]:='';
  Tabelle.RowCount:=Schritte+1;
  AktZeile:=1;
end;

procedure TTabForm.Optionen2Click(Sender: TObject);
begin
  TabelleDlg.ShowModal;
end;

end.
