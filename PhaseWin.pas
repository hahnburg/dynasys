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

unit PhaseWin;

(*
  Zeichnet das Phasendiagramm
  HoleWerte, InitWerte, ExitWerte werden von Simulation aufgerufen.

  Version: 2.0
*)

interface

uses
  SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls,
  Forms, StdCtrls, Buttons, ColorGrd, Menus, Printers, ClipBrd, Dialogs,
  ExtCtrls,
  Funktion, PhaseSelect, Liste, Diagram, Numerik;


type
  TPhaseForm = class(TForm)
	 ScrollBox1: TScrollBox;
	 Image: TImage;
         MainMenu1: TMainMenu;
	 Graphik1: TMenuItem;
	 Zeichnen1: TMenuItem;
	 Copy1: TMenuItem;
	 xlog1: TMenuItem;
	 ylog1: TMenuItem;
         Skalierung1: TMenuItem;
         Autoskalierung1: TMenuItem;
	 N3: TMenuItem;
         xAutoskalierung1: TMenuItem;
	 yAutoskalierung1: TMenuItem;
	 N4: TMenuItem;

	 procedure FormCreate(Sender: TObject);
	 procedure Exit1Click(Sender: TObject);
	 procedure Print1Click(Sender: TObject);
	 procedure Save1Click(Sender: TObject);
	 procedure Copy1Click(Sender: TObject);
	 procedure FormResize(Sender: TObject);
	 procedure Zeichnen1Click(Sender: TObject);
	 procedure ylog1Click(Sender: TObject);
	 procedure xlog1Click(Sender: TObject);
	 procedure Autoskalierung1Click(Sender: TObject);
	 procedure xAutoskalierung1Click(Sender: TObject);
	 procedure yAutoskalierung1Click(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormShow(Sender: TObject);
  private
	 { Private declarations }
         dx : double;
	 Oldwidth, Oldheight : Integer;
         PhaseDlg:TPhasenAuswahl;
         InputList:TStringList;
         Schritt: integer;
         Aufloesung:integer;
         Diagram : TDiagram;

  public
	 { Public declarations }
   isClosed: bool;
	 Origin, MovePt: TPoint;
	 CurrentFile: string;
        procedure HoleWerte(Zeit:Double);
        // Eigentlich eine blöde Bezeichnung. Prozedur liefert Wert zum Zeitpunkt
        // Zeit von Simulation
        Procedure ExitWerte(Minimum,Maximum:double);
        procedure InitWerte(Schritte:integer);
  end;

var
  PhaseForm: TPhaseForm;


implementation

{$R *.DFM}


(* ====================================================================== *)

procedure TPhaseForm.FormCreate(Sender: TObject);
var
  Bitmap: TBitmap;
  Placement : TWindowPlacement;
  i : integer;

begin
  InputList:=TStringList.Create;
  self.isClosed := false;
  try
    PhaseDlg:=TPhasenAuswahl.Create(self);
    if PhaseDlg.ShowModal = mrCancel Then
      begin
        self.isClosed := true;
        Exit;
      end
    else
      for i:=0 to PhaseDlg.DstList.items.count-1 do begin
        InputList.add(PhaseDlg.DstList.items[i]);
      end;
  except
    MessageDlg('Fehler beim Öffnen des Dialogs!',mtError,[mbok],0);
  end;

  Bitmap := TBitmap.Create;
  Bitmap.Height := Image.Height;
  Bitmap.Width := Image.Width;
  Oldheight:=Height;
  Oldwidth:=Width;
  Image.Picture.Graphic := Bitmap;
  Diagram:=TDiagram.create;
  Diagram.init(Image.canvas,Bitmap.height,Bitmap.width,2);
    // Diagram.SetPlotArea(0.02,0.02,20,20);
  xlog1.Checked:=Diagram.xtyp=1;
  ylog1.Checked:=Diagram.ytyp=1;

  CurrentFile:='';
end;


procedure TPhaseForm.Exit1Click(Sender: TObject);
begin
  Close;
end;


procedure TPhaseForm.Print1Click(Sender: TObject);
begin
 (*with Printer do
  begin
	 BeginDoc;
	 Canvas.Draw(0, 0, Image.Picture.Graphic);
	 EndDoc;
  end; *)
end;

procedure TPhaseForm.Save1Click(Sender: TObject);
begin
(*  if CurrentFile <> '' then
	 Image.Picture.SaveToFile(CurrentFile)
  else if SaveDialog1.Execute then begin
	 CurrentFile := SaveDialog1.FileName;
	 Image.Picture.SaveToFile(CurrentFile)
  end; *)
end;


procedure TPhaseForm.Copy1Click(Sender: TObject);
begin
  Clipboard.Assign(Image.Picture);
end;


procedure TPhaseForm.FormResize(Sender: TObject);
var
  ARect: TRect;
begin
  { Größen anpassen }
  if Width<300
	then Width:=300;
  if Height<200
	then Height:=200;
  Image.Picture.Graphic.Width :=Image.Width;
  Image.Picture.Graphic.Height :=Image.Height;
  with Image.Canvas do
  begin
    { Zeichenfläche löschen }
    CopyMode := cmWhiteness;
    ARect := Rect(0, 0, Image.Width, Image.Height);
    CopyRect(ARect, Image.Canvas, ARect);
    CopyMode := cmSrcCopy;
  end;
  { Graphik neu zeichnen, da sonst krissellig!! }
  Diagram.SetSize(Image.Width, Image.Height);
  Diagram.Zeichnen;
end;

procedure TPhaseForm.Autoskalierung1Click(Sender: TObject);
begin
  Diagram.AutoSkalierung;
  Diagram.Zeichnen
end;

procedure TPhaseForm.xAutoskalierung1Click(Sender: TObject);
begin
  Diagram.xAutoSkalierung;
  Diagram.Zeichnen
end;

procedure TPhaseForm.yAutoskalierung1Click(Sender: TObject);
begin
  Diagram.yAutoSkalierung;
  Diagram.Zeichnen
end;

procedure TPhaseForm.ylog1Click(Sender: TObject);
begin
	 ylog1.Checked:=not ylog1.Checked;
	 If ylog1.Checked
		then Diagram.ytyp:=1
		else Diagram.ytyp:=0;
	 Diagram.yAutoSkalierung;
	 Diagram.Zeichnen
end;

procedure TPhaseForm.xlog1Click(Sender: TObject);
begin
	 xlog1.Checked:=not xlog1.Checked;
	 If xlog1.Checked
		then Diagram.xtyp:=1
		else Diagram.xtyp:=0;
	 Diagram.xAutoSkalierung;
	 Diagram.Zeichnen
end;


procedure TPhaseForm.Zeichnen1Click(Sender: TObject);
begin
  Diagram.Zeichnen
end;


procedure TPhaseForm.HoleWerte(Zeit:double);
var i: integer;
    Eintrag_X,Eintrag_Y   : String[40];
    Wert_X,Wert_Y : double;
    p : tDbPoint;
begin
  inc(Schritt);
  if schritt mod aufloesung=0 then begin
        Eintrag_X:=InputList.strings[0];
        Eintrag_Y:=InputList.strings[1];
        p:= tDbPoint.create;
        for i:=0 to ObjektListe.count-1 do begin
          if Eintrag_X=ObjektListe.items[i].Name then Wert_X:=ObjektListe.items[i].G_Wert;
          if Eintrag_Y=ObjektListe.items[i].Name then Wert_Y:=ObjektListe.items[i].G_Wert;
        end;
        p.init(Wert_X,Wert_Y);
        Diagram.y[1].add(p);
  end; //if
end;

Procedure TPhaseForm.ExitWerte(Minimum,Maximum:double);
Begin
  Diagram.AutoSkalierung;
  Diagram.Zeichnen
End;

procedure TPhaseForm.InitWerte(Schritte:integer);
var i,j:integer;
    Eintrag   : String[40];
begin
  for i:=1 to maxGraph do begin
    Diagram.y[i].free;
    Diagram.y[i]:=TGraph.create;
    case i of
      1 : Diagram.y[i].setColor(PhasenAuswahl.ColorBox1.Selected);
      2 : Diagram.y[i].setColor(PhasenAuswahl.ColorBox2.Selected);
      3 : Diagram.y[i].setColor(PhasenAuswahl.ColorBox3.Selected);
      4 : Diagram.y[i].setColor(PhasenAuswahl.ColorBox4.Selected);
      else Diagram.y[i].setColor(clBlack);
    end
  end;
  for j:=0 to InputList.count-1 do
     begin
        Eintrag:=InputList.strings[j];
        for i:=1 to ObjektListe.count-1 do
           with ObjektListe.items[i] do
             if Eintrag=name then
                Diagram.y[j+1].title:=name;
      end;
  Schritt:=-1;
  aufloesung:=2;
end;


procedure TPhaseForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  action:=caFree;
end;

procedure TPhaseForm.FormShow(Sender: TObject);
begin

  if(self.isClosed=false) then
  FormResize(Sender);
end;

end.
