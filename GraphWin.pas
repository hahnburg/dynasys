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

unit GraphWin;

{$MODE Delphi}

interface

uses
  SysUtils, unix, Messages, Classes, Graphics, Controls,
  Forms, StdCtrls, Buttons, LCLType, Menus, Printers, ClipBrd, Dialogs,
  ExtCtrls,
  Funktion, ZeitSelect,
  Liste,
  Diagram,
  Numerik;


type
  TGraphForm = class(TForm)
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
	 Oldwidth, Oldheight : Integer;
         ZeitDlg:TZeitKurveDlg;
         InputList:TStringList;
         Schritt: integer;
         dx : double;
         Aufloesung:integer;
         Diagram : TDiagram;

  public
	 { Public declarations }
	 Origin, MovePt: TPoint;
	 CurrentFile: string;
        procedure HoleWerte(Zeit:Double);
        Procedure ExitWerte(Minimum,Maximum:double);
        procedure InitWerte(Schritte:integer);
  end;

var
  GraphForm: TGraphForm;


implementation

{$R *.lfm}


(* ====================================================================== *)

procedure TGraphForm.FormCreate(Sender: TObject);
var
  Bitmap: TBitmap;
  //Placement : TWindowPlacement;
  i : integer;

begin
  InputList:=TStringList.Create;
  try
    ZeitDlg:=TZeitKurveDlg.Create(self);
    if ZeitDlg.ShowModal = idCancel Then
      begin
        self.close;
      end
    else
      for i:=0 to ZeitDlg.DstList.items.count-1 do begin
        InputList.add(ZeitDlg.DstList.items[i]);

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
  Diagram.init(Image.canvas,Bitmap.height,Bitmap.width,1);

With NumerikDlg do
    Diagram.SetPlotArea(Startzeit,0.02,Endzeit,20);

  xlog1.Checked:=Diagram.xtyp=1;
  ylog1.Checked:=Diagram.ytyp=1;

  CurrentFile:='';
end;

procedure TGraphForm.Exit1Click(Sender: TObject);
begin
  Close;
end;

procedure TGraphForm.Print1Click(Sender: TObject);
begin
 (*with Printer do
  begin
	 BeginDoc;
	 Canvas.Draw(0, 0, Image.Picture.Graphic);
	 EndDoc;
  end; *)
end;

procedure TGraphForm.Save1Click(Sender: TObject);
begin
(*  if CurrentFile <> '' then
	 Image.Picture.SaveToFile(CurrentFile)
  else if SaveDialog1.Execute then begin
	 CurrentFile := SaveDialog1.FileName;
	 Image.Picture.SaveToFile(CurrentFile)
  end; *)
end;

procedure TGraphForm.Copy1Click(Sender: TObject);
begin
  Clipboard.Assign(Image.Picture);
end;

procedure TGraphForm.FormResize(Sender: TObject);
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

procedure TGraphForm.Autoskalierung1Click(Sender: TObject);
begin
  Diagram.AutoSkalierung;
  Diagram.Zeichnen
end;

procedure TGraphForm.xAutoskalierung1Click(Sender: TObject);
begin
  Diagram.xAutoSkalierung;
  Diagram.Zeichnen
end;

procedure TGraphForm.yAutoskalierung1Click(Sender: TObject);
begin
  Diagram.yAutoSkalierung;
  Diagram.Zeichnen
end;


procedure TGraphForm.ylog1Click(Sender: TObject);
begin
	 ylog1.Checked:=not ylog1.Checked;
	 If ylog1.Checked
		then Diagram.ytyp:=1
		else Diagram.ytyp:=0;
	 Diagram.yAutoSkalierung;
	 Diagram.Zeichnen
end;

procedure TGraphForm.xlog1Click(Sender: TObject);
begin
	 xlog1.Checked:=not xlog1.Checked;
	 If xlog1.Checked
		then Diagram.xtyp:=1
		else Diagram.xtyp:=0;
	 Diagram.xAutoSkalierung;
	 Diagram.Zeichnen
end;


procedure TGraphForm.Zeichnen1Click(Sender: TObject);
begin
  Diagram.Zeichnen
end;


procedure TGraphForm.HoleWerte(Zeit:Double);
var i,j : integer;
    Eintrag   : String[40];
    p : tDbPoint;
begin
  inc(Schritt);
  if schritt mod aufloesung=0 then begin
    for j:=0 to InputList.count-1 do
      begin
        Eintrag:=InputList.strings[j];
        for i:=0 to ObjektListe.count-1 do
           with ObjektListe.items[i] do begin
             //MessageDlg(eintrag+' - '+name,mtError,[mbok],0);
             if Eintrag=name then begin
                 p:= tDbPoint.create;

                 with NumerikDlg do
                   p.init(StartZeit+dt*Schritt,G_Wert);
                 Diagram.y[j+1].add(p);
             End;
           end; //with
      end;
  end; //if
end;

Procedure TGraphForm.ExitWerte(Minimum,Maximum:double);
Begin
  Diagram.AutoSkalierung;
  Diagram.Zeichnen
End;

procedure TGraphForm.InitWerte(Schritte:integer);
var i,j:integer;
    Eintrag   : String[40];
begin
  for i:=1 to maxGraph do begin
    Diagram.y[i].free;
    Diagram.y[i]:=TGraph.create;
    case i of
      1 : Diagram.y[i].setColor(ZeitKurveDlg.ColorBox1.Selected);
      2 : Diagram.y[i].setColor(ZeitKurveDlg.ColorBox2.Selected);
      3 : Diagram.y[i].setColor(ZeitKurveDlg.ColorBox3.Selected);
      4 : Diagram.y[i].setColor(ZeitKurveDlg.ColorBox4.Selected);
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


procedure TGraphForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  action:=caFree;
end;

procedure TGraphForm.FormShow(Sender: TObject);
begin
  FormResize(Sender);
end;

end.
