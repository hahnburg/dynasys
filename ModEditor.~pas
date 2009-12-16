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

unit ModEditor;

(*
  Dynasys Modelleditor (Formular)
  mit eigenem Algorithmus zur Berechnung von Bezierkurven
  Version: 2.0
  Autor: Walter Hupfeld
  zuletzt bearbeitet:
*)

interface

uses
  SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls,
  Forms, Dialogs, Buttons, ExtCtrls,StdCtrls,
  SimObjekt, Liste, Menus, GeoUtil, ObjectDlg, Util, ErrorTxt, TabEdit;

const
  crVentil = 5;

type
  TWerkzeug = (wzStandard,wzZustand,wzWert,wzWirkung,wzVentil);
  Str20 = String[20];

  TModelleditor = class(TForm)
    Panel1: TPanel;
    StandardBtn: TSpeedButton;
    VentilBtn: TSpeedButton;
    RechteckBtn: TSpeedButton;
    KreisBtn: TSpeedButton;
    PfeilBtn: TSpeedButton;
    MainMenu1: TMainMenu;
    Bearbeiten1: TMenuItem;
    N2: TMenuItem;
    Loeschen: TMenuItem;
    Einfgen1: TMenuItem;
    Kopieren1: TMenuItem;
    Ausschneiden1: TMenuItem;
    Neuzeichnen1: TMenuItem;
    Allesauswaehlen1: TMenuItem;
    ScrollBox1: TScrollBox;
    Modell: TPaintBox;
    PopupObjekt: TPopupMenu;
    Bearbeiten2: TMenuItem;
    Namenndern1: TMenuItem;
    PopupBearbeiten: TPopupMenu;
    AllesAuswhlen1: TMenuItem;
    Neuzeichnen2: TMenuItem;
    Lschen2: TMenuItem;
    N1: TMenuItem;
    Starten1: TMenuItem;
    Weiterrechnen1: TMenuItem;
    Info1: TMenuItem;
    EditName: TEdit;
    PopupMenu1: TPopupMenu;
    N3: TMenuItem;
    Lschen1: TMenuItem;
    procedure FormCreate(Sender: TObject);
    procedure WerkzeugClick(Sender: TObject);
    procedure MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure MouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure MouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure Paint(Sender: TObject);
    procedure DblClick(Sender: TObject);
    procedure LoeschenClick(Sender: TObject);
    procedure Allesauswaehlen1Click(Sender: TObject);
    procedure Neuzeichnen1Click(Sender: TObject);
    procedure Bearbeiten2Click(Sender: TObject);
    procedure Namenaendern1Click(Sender: TObject);
    procedure EditNameExit(Sender: TObject);
    procedure EditNameKeyPress(Sender: TObject; var Key: Char);
    procedure Starten1Click(Sender: TObject);
    procedure Info1Click(Sender: TObject);
    procedure Loeschen1Click(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
  private
    ZeichnePfeil, ZeichneBezier1,ZeichneBezier2,
    ZeichneAnfang,ZeichneEnde,
    MausUnten, Drag, Auswahl,
    Wolke,ZeichneVentilFlag,
    EditFlag                    : boolean;
    DragFix                     : boolean;
    Werkzeug                    : TWerkzeug;
    ZeichenObj                  : TWirkPfeilObjekt;
    AnfangsPkt,ZiehPkt,EndPkt   : TPoint;
    StartPos, LastPos, Mitte    : TPoint;
    MausPos                     : TPoint;
    DragRect,SelectRect         : TRect;
    AnfangObj,EndObj,EditObj    : TSimuObjekt;
    procedure clear;
    function OhneNamen:Str20;
  public
    ObjektZaehler               : integer;
    { Public-Deklarationen }
  end;

var
  Modelleditor: TModelleditor;

implementation

uses DynaMain;

{$R *.DFM}

function TModelleditor.OhneNamen:Str20;
var ZahlStr  : String[5];
begin
  Str(ObjektZaehler,ZahlStr);
  Inc(ObjektZaehler);
  OhneNamen:='namenlos_'+ZahlStr;
end;

procedure TModelleditor.FormCreate(Sender: TObject);
begin
  Screen.Cursors[crVentil] := LoadCursor(hInstance, 'VENTILCURSOR');
  cursor:=crVentil;
  ObjektListe:=TObjektListe.create;
  Werkzeug:=wzStandard;
  StandardBtn.down:=true;
  MausUnten:=false;
  Drag:=false;
  Auswahl:=false;
  ZeichneVentilFlag:=false;
  EditFlag:=False;
  ObjektZaehler:=1;
  self.Top:=10;
  self.Left:=10;
  self.width:=round(0.9*MainForm.width);
  self.height:=round(0.8*MainForm.height);

end;

procedure TModelleditor.Clear;
begin
  Modell.Refresh;
end;

procedure TModelleditor.WerkzeugClick(Sender: TObject);
begin
  if Sender= StandardBtn then begin Werkzeug:=wzStandard; Modell.cursor:=1 end
  else if Sender=KreisBtn then begin Werkzeug:=wzWert; Modell.cursor:=crCross end
  else if Sender=RechteckBtn then begin Werkzeug:=wzZustand; Modell.cursor:=crHandPoint end
  else if Sender=PfeilBtn  then begin Werkzeug:=wzWirkung; Modell.cursor:=crHandPoint end
  else if Sender=VentilBtn then begin Werkzeug:=wzVentil; Modell.cursor:=crHandPoint end
end;

procedure TModelleditor.MouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var index:integer;
    Zustand :  TZustandObjekt;
    Wert    : TWertObjekt;
    Punkte   : TPunktFeld;
    obj     : TSimuObjekt;
    MausRechts : TPoint;
begin
  if EditFlag Then begin EditNameExit(Sender); (*Exit*) End;
  MausPos:=Point(x,y);
  if Button =  mbRight then
  begin
    MausRechts:=Modell.ClientToScreen(Point(x,y));
    if ObjektListe.ObjektUnterMaus(x,y,obj) then
      PopupObjekt.Popup(MausRechts.x,MausRechts.y)
    else
      PopupBearbeiten.Popup(MausRechts.x,MausRechts.y);
  end else { Button = mbLeft} begin
    if DragFix Then begin DragFix:=false; exit; (*Exit*) End;
    MausUnten:=true;
    MainForm.ChangeFlag:=true;
    Case Werkzeug of
    wzZustand:
      begin
        ObjektListe.LoescheAlleMarkierungen;
        Zustand:=TZustandObjekt.Create;
        Zustand.init(Point(x,y),OhneNamen);
        ObjektListe.add(Zustand);
        Zustand.Zeichne;
        Zustand.selected:=true;
        Zustand.ZeichneMarkierung;
      end;
    wzWert:
      begin
        ObjektListe.LoescheAlleMarkierungen;
        Wert:=TWertObjekt.Create;
        Wert.init(x,y,OhneNamen);
        Wert.Zeichne;
        Wert.selected:=true;
        Wert.ZeichneMarkierung;
        ObjektListe.add(Wert);
      end;
   wzWirkung:
     begin
      ObjektListe.LoescheAlleMarkierungen;
      if ObjektListe.ObjektunterMaus(x,y,obj) then begin
        ZeichnePfeil:=true;
        Mitte:=obj.Mitte;
        AnfangObj:=obj;
        AnfangsPkt:=BestimmeKreispunkt(Mitte,Point(x,y));
        ZiehPkt:=Point(x,y);
        Punkte[Anfang]:=AnfangsPkt;
        Punkte[Ende]:=ZiehPkt;
        Modell.Canvas.Pen.Mode := pmNotXor;
        GeoUtil.ZeichnePfeil(Punkte);
      end
     end;
   wzVentil:
     begin
       ObjektListe.LoescheAlleMarkierungen;
       Modell.Canvas.Pen.Mode := pmNotXor;
       if ObjektListe.ObjektunterMaus(x,y,obj) then begin
         if (obj is TZustandObjekt) then begin
           ZeichneVentilFlag:=true;
           AnfangObj:=obj;
           AnfangsPkt:=obj.Mitte;
           Endpkt:=point(x,y);
           Wolke:=false;
           Mitte:=AnfangsPkt;
           ZeichneVentil(AnfangsPkt.x,AnfangsPkt.y);
           ZeichneFlussZustandZustand(AnfangObj.Position,
                    Rect(EndPkt.x-10,EndPkt.y-10,EndPkt.x+10,EndPkt.y+10),Mitte);
          end else ZeichneVentilFlag:=false
        end else begin
          AnfangsPkt:=point(x,y);
          Endpkt:=point(x,y);
          ZeichneWolke(AnfangsPkt.x,AnfangsPkt.y,0);
          Mitte:=Point(x,AnfangsPkt.y);
          ZeichneVentil(Mitte.x,Mitte.y);
          ZeichneFlussWolkeZustand(
               Rect(AnfangsPkt.x-5,AnfangsPkt.y-5,AnfangsPkt.x+5,AnfangsPkt.y+5),
               Rect(EndPkt.x,EndPkt.y,EndPkt.x,EndPkt.y),Mitte);
          Wolke:=true;
          ZeichneVentilFlag:=true;
        end;
     end;
   wzStandard:
      if ObjektListe.ObjektunterMaus(x,y,obj) then
        if obj.selected then begin
          if obj is TWirkPfeilObjekt Then
             with TWirkPfeilObjekt(obj) do
               begin
                 if istBezierPunkt1(x,y) then ZeichneBezier1:=true;
                 if istBezierPunkt2(x,y) then ZeichneBezier2:=true;
                 ZeichenObj:=obj as TWirkPfeilObjekt;
               end
         end else
           begin { nicht ausgewählt }
             if not(ssShift in shift) then ObjektListe.LoescheAlleMarkierungen;
             obj.ZeichneMarkierung;
             obj.selected:=not obj.selected;
          end
      else
        begin
          { kein Objekt unter dem Mauszeiger }
          if not(ssShift in shift) then ObjektListe.LoescheAlleMarkierungen;
          Auswahl:=true;
          SelectRect:=Rect(x,y,x,y);
        end;
   end;
  end;
end;

procedure TModelleditor.MouseMove(Sender: TObject; Shift: TShiftState;
  X, Y: Integer);
var dummy       : TPoint;
    Punkte      : TPunktFeld;
    obj         : TSimuObjekt;
begin
  if Drag then begin
    Modell.Canvas.DrawFocusRect(DragRect);
    DragRect:=Rect(DragRect.left-LastPos.x+x,
                   DragRect.top-LastPos.y+y,
                   DragRect.right-Lastpos.x+x,
                   DragRect.bottom-Lastpos.y+y);
    Modell.Canvas.DrawFocusRect(DragRect);
    LastPos:=Point(x,y);
  end else
  if Auswahl then begin
    Modell.Canvas.DrawFocusRect(SelectRect);
    SelectRect:=Rect(SelectRect.left,SelectRect.top,x,y);
    Modell.Canvas.DrawFocusRect(SelectRect);
  end else
  if ZeichnePfeil then begin
    Modell.Canvas.Pen.Mode := pmNotXor;
    Punkte[Anfang]:=AnfangsPkt;
    Punkte[Ende]:=ZiehPkt;
    GeoUtil.ZeichnePfeil(Punkte);
    ZiehPkt:=Point(x,y);
    AnfangsPkt:=BestimmeKreispunkt(Mitte,Point(x,y));
    Punkte[Anfang]:=Anfangspkt;
    Punkte[Ende]:=ZiehPkt;
    GeoUtil.ZeichnePfeil(Punkte);
  end else
  if ZeichneBezier1 then
    with ZeichenObj do begin
       ZeichneMarkierung;
       VeraendereBezierPunkt1(Point(x,y));
       ZeichnePfeil(P,PVerschiebe);
       ZeichneMarkierung;
  end else
  if ZeichneBezier2 then
    with ZeichenObj do begin
       ZeichneMarkierung;
       VeraendereBezierPunkt2(Point(x,y));
       ZeichnePfeil(P,pVerschiebe);
       ZeichneMarkierung;
  end else
  if MausUnten and not drag Then if ObjektListe.ObjektUnterMaus(x,y,obj) then
    if obj.selected  then begin
      DragRect:=ObjektListe.HohleAuswahlRechteck;
      Modell.Canvas.DrawFocusRect(DragRect);
      Drag:=True;
      StartPos:=Point(x,y);
      LastPos:=StartPos;
  end;
  if ZeichneVentilFlag then begin
    if Wolke then begin
       ZeichneVentil(Mitte.x,Mitte.y);
       ZeichneFlussWolkeZustand
             (Rect(AnfangsPkt.x-5,AnfangsPkt.y-5,AnfangsPkt.x+5,AnfangsPkt.y+5),
              Rect(EndPkt.x,EndPkt.y,EndPkt.x,EndPkt.y),Mitte);
       EndPkt:=Point(x,y);
       Mitte:=Point((AnfangsPkt.x+EndPkt.x)div 2,AnfangsPkt.y);
       ZeichneVentil(Mitte.x,Mitte.y);
       ZeichneFlussWolkeZustand(
             Rect(AnfangsPkt.x-5,AnfangsPkt.y-5,AnfangsPkt.x+5,AnfangsPkt.y+5),
             Rect(EndPkt.x,EndPkt.y,EndPkt.x,EndPkt.y),Mitte);
    end else begin
       ZeichneVentil(Mitte.x,Mitte.y);
       ZeichneFlussZustandZustand(AnfangObj.Position,
                  Rect(EndPkt.x-10,EndPkt.y-10,EndPkt.x+10,EndPkt.y+10),Mitte);
       EndPkt:=Point(x,y);
       Mitte:=Point((AnfangsPkt.x+EndPkt.x)div 2,(AnfangsPkt.y+EndPkt.y)div 2);
       ZeichneVentil(Mitte.x,Mitte.y);
       ZeichneFlussZustandZustand(AnfangObj.Position,
                  Rect(EndPkt.x-10,EndPkt.y-10,EndPkt.x+10,EndPkt.y+10),Mitte);

    end;
  end;

  if Werkzeug=wzStandard then begin
    if ObjektListe.ObjektUnterMaus(x,y,obj) Then
      Modell.cursor:=crHandPoint
    else Modell.Cursor:=crDefault;
  end
end;


procedure TModelleditor.MouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var dummy         : TPoint;
    Punkte        : TPunktFeld;
    obj           : TSimuObjekt;
    index         : integer;
    ZustandObjekt : TZustandObjekt;
    Pfeil         : TWirkPfeilObjekt;
    Zustand       : Boolean;
    WolkeObjekt   : TWolkeObjekt;
    VentilObjekt  : TVentilObjekt;
begin
  if not MausUnten then exit;
  MausUnten:=false;
  if werkzeug=wzStandard then
    if ObjektListe.ObjektunterMaus(x,y,obj) and obj.selected then
      if obj.istNamen(x,y) then 
      begin
        obj.ZeichneMarkierung;
        obj.selected:=false;
        NamenAendern1Click(nil);
      end;
  if ZeichneVentilFlag then begin
    ZeichneVentilFlag:=false;
    ZeichneVentil(Mitte.x,Mitte.y);
    if Wolke then Begin
         ZeichneFlussWolkeZustand(
             Rect(AnfangsPkt.x-5,AnfangsPkt.y-5,AnfangsPkt.x+5,AnfangsPkt.y+5),
             Rect(EndPkt.x,EndPkt.y,EndPkt.x,EndPkt.y),Mitte);
         ZeichneWolke(AnfangsPkt.x,AnfangsPkt.y,0);
    end else
          ZeichneFlussZustandZustand(AnfangObj.Position,
                  Rect(EndPkt.x-10,EndPkt.y-10,EndPkt.x+10,EndPkt.y+10),Mitte);
    EndPkt:=Point(x,y);
    Zustand:=false;
    if ObjektListe.ObjektUnterMaus(x,y,obj) then
       Zustand:= obj is TZustandObjekt;
    if Zustand then ZustandObjekt:=obj as TZustandObjekt;
    { 1. Fall  Wolke --> Zustand }
    if Wolke and Zustand then begin
      WolkeObjekt:=TWolkeObjekt.create;
      WolkeObjekt.Init(AnfangsPkt.x,AnfangsPkt.y);
      VentilObjekt:=TVentilObjekt.create;
      VentilObjekt.init(0,0,OhneNamen,WolkeObjekt,ZustandObjekt);
      WolkeObjekt.SetVentil(VentilObjekt);
      WolkeObjekt.Zeichne;
      VentilObjekt.Zeichne;
      ObjektListe.add(WolkeObjekt);
      ObjektListe.add(VentilObjekt);
    end else
    { 2. Fall Zustand --> Zustand }
    if not Wolke and Zustand then begin
      VentilObjekt:=TVentilObjekt.create;
      VentilObjekt.init(0,0,OhneNamen,AnfangObj,ZustandObjekt);
      VentilObjekt.Zeichne;
      ObjektListe.add(VentilObjekt);
    end else
    { 3. Fall Zustand --> Wolke }
    if not Wolke and not Zustand then begin
      WolkeObjekt:=TWolkeObjekt.create;
      WolkeObjekt.Init(EndPkt.x,EndPkt.y);
      VentilObjekt:=TVentilObjekt.create;
      VentilObjekt.init(0,0,OhneNamen,AnfangObj,WolkeObjekt);
      WolkeObjekt.SetVentil(VentilObjekt);
      WolkeObjekt.Zeichne;
      VentilObjekt.Zeichne;
      ObjektListe.add(VentilObjekt);
      ObjektListe.add(WolkeObjekt);
    end;
  end;
  If Auswahl then begin
    Auswahl:=false;
    Modell.Canvas.DrawFocusRect(SelectRect);
    Objektliste.WaehleObjekteInRechteck(SelectRect);
  end
  else if ZeichnePfeil  Then begin
    EndPkt:=Point(x,y);
    Punkte[Anfang]:=AnfangsPkt;
    Punkte[Ende]:=EndPkt;
    ZeichnePfeil:=false;
   // Modell.Canvas.Pen.Mode := pmNotXor;
    GeoUtil.ZeichnePfeil(Punkte);
    Modell.Canvas.Pen.Mode := pmCopy;
    If ObjektListe.ObjektUnterMaus(x,y,obj) then begin
      EndObj:=obj;
      EndObj.Radiere;
      Pfeil:=TWirkPfeilObjekt.Create;
      Pfeil.Init(AnfangObj,EndObj);
      ObjektListe.add(Pfeil);
      Pfeil.selected:=true;
      Pfeil.Zeichne;
      EndObj.Zeichne;
      Pfeil.ZeichneMarkierung;
    end
  end
  else if ZeichneBezier1 then ZeichneBezier1:=false
  else if ZeichneBezier2 then ZeichneBezier2:=false
  else if Drag then begin
    drag:=false;
    Modell.Canvas.DrawFocusRect(DragRect);
    if ObjektListe.VerschiebeObjekte(x-StartPos.x,y-StartPos.y) then
       Modell.Repaint;
  end else if Auswahl then begin Auswahl:=false;
  end;
  if shift<>[ssALt] then begin
    Werkzeug:=wzStandard;
    StandardBtn.down:=true;
  end;
end;

procedure TModelleditor.Paint(Sender: TObject);
begin
  ObjektListe.ZeichneAlles;
end;

procedure TModelleditor.DblClick(Sender: TObject);
Var  obj: TSimuObjekt;
     wertobj : TWertObjekt;
begin
  if EditFlag Then begin EditNameExit(Sender); Exit End;
  if WerkZeug = wzStandard then begin
    if ObjektListe.ObjektUnterMaus(MausPos.x,MausPos.y,obj) then
      if obj is TWertObjekt then begin
         wertobj:= obj as TWertObjekt;
         if wertobj.xtbf=editTab then begin
            TabEditForm.Init(obj);
            TabEditForm.ShowModal;
         end
         else
         begin
            ObjektDialog.Init(obj);
            ObjektDialog.ShowModal;
         end;
      end
      else
      begin
        ObjektDialog.Init(obj);
        ObjektDialog.ShowModal;
      end;
    end;
    self.Auswahl:=false;
    self.MausUnten:=false;
    self.Drag:=false;
    ObjektListe.LoescheAlleMarkierungen;
    self.Modell.invalidate;
    self.MausUnten := false;
    obj.selected := false;
    DragFix := true;
end;

procedure TModelleditor.LoeschenClick(Sender: TObject);
begin
  ObjektListe.LoescheMarkierteObjekte;
  Modell.invalidate;
end;

procedure TModelleditor.Allesauswaehlen1Click(Sender: TObject);
begin
  ObjektListe.AllesAuswaehlen;
end;

procedure TModelleditor.Neuzeichnen1Click(Sender: TObject);
begin
 Modell.invalidate
end;

procedure TModelleditor.Bearbeiten2Click(Sender: TObject);
Var obj : TSimuObjekt;
begin
  if ObjektListe.ObjektUnterMaus(MausPos.x,MausPos.y,obj) then
  begin
    ObjektDialog.Init(obj);
    ObjektDialog.ShowModal;
  end;

end;

procedure TModelleditor.Namenaendern1Click(Sender: TObject);
Var obj      : TSimuObjekt;
    editrect : tRect;
begin
  if ObjektListe.ObjektUnterMaus(MausPos.x,MausPos.y,obj) then
  begin
     EditFlag:=true;
     //EditName.left:=obj.Mitte.x-EditName.width div 2;
     //EditName.top:=obj.position.bottom+4;
     obj.GetPositionNamen(editrect);
     EditName.left:=editrect.left;
     EditName.top:=editrect.top;
     EditName.width:=editrect.right-editrect.left+3;
     EditName.height:=editrect.bottom-editrect.top+1;
     EditName.Text:=obj.Name;
     EditName.visible:=true;
     EditName.Selstart:=0;
     EditName.SelLength:=Length(EditName.Text);
     EditName.SetFocus;
     EditObj:=obj;
     EditObj.LoescheNamen;
   end;
end;

procedure TModelleditor.EditNameExit(Sender: TObject);
Var ObjName : NameStr;
       i : Integer;
begin
   ObjName:=EditName.Text;
   If not Namekorrekt(ObjName) Then Begin
     MessageDlg(errortxt1,mtError,[mbok],0);
     Exit;
   End else
   If CompareText(EditObj.Name,ObjName)=0 then begin
     EditName.visible:=false;
     EditObj.SchreibeNamen;
     EditFlag:=false;
     exit
   end else
   if ObjektListe.NameVorhanden(ObjName) then begin
     MessageDlg(ErrorTxt2,mtError,[mbok],0);
     Exit
   end else
   if CompareText(EditObj.Name,ObjName)<>0 then begin
     EditObj.Name:=ObjName;
     EditFlag:=false;
     EditObj.SchreibeNamen;
   end;
     (*  End Else
          Begin

            If StrComp(SimObj^.Name,ObjName)<>0 Then Begin
              {Objekt mit Wirkverbindung ungültig erklären }
              For i:=1 To SimObj^.AusgangMax do Begin
                If Not Ersetze_Namen(PWirkPfeilObjekt(SimObj^.Ausgaenge[i].zgr)^.nach,SimObj^.Name,ObjName) Then
                   PWirkPfeilObjekt(SimObj^.Ausgaenge[i].zgr)^.nach^.gueltig:=False;
              End
            End;
            StrCopy (SimObj^.Name,ObjName);
         End; *)
   EditName.visible:=false;
   EditFlag:=false;
   Modell.invalidate

end;

procedure TModelleditor.EditNameKeyPress(Sender: TObject; var Key: Char);
begin
  if Key=#13 then EditNameExit(Sender);
  end;

procedure TModelleditor.Starten1Click(Sender: TObject);
begin
  MainForm.Starten1Click(Sender);
end;

procedure TModelleditor.Info1Click(Sender: TObject);
begin
  MainForm.ModellInfo1Click(Sender);
end;

procedure TModelleditor.Loeschen1Click(Sender: TObject);
begin
   LoeschenClick(Sender);
end;

procedure TModelleditor.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin

if(Key=VK_DELETE) then
self.Lschen1.Click;

end;

end.
