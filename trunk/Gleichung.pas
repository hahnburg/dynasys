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

unit Gleichung;

interface

uses
  SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls,
  Forms, Dialogs, StdCtrls,
  Liste, SimObjekt, ObjectDlg, TabEdit;

type
  TGleichungen = class(TForm)
    ListBox1: TListBox;
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure ListBox1DblClick(Sender: TObject);
    procedure ListBox1KeyPress(Sender: TObject; var Key: Char);
  private
    procedure FillListBox;
  public
  end;

var
  Gleichungen: TGleichungen;

implementation

uses DynaMain;

{$R *.DFM}

procedure TGleichungen.FillListbox;
Var i,j:integer;
    Titel,Zeile,Zahlstr:String;
begin
  { Zustaende  }
  Listbox1.items.add(' Zustandsgleichungen ');
  for i:=0 To ObjektListe.Count-1 do
    if ObjektListe.items[i].key=ZustandId then
      with ObjektListe.items[i] as TZustandObjekt do begin
        Zeile:='      '+Name+'.neu = '+Name+'.alt + dt*(';
      For j:=1 to ZuflussMax do
        If j<>1 Then Zeile:=Zeile+'+'+Zufluesse[j].zgr.Name
        else Zeile:=Zeile+Zufluesse[j].zgr.Name;
      For j:=1 to AbflussMax do Begin
        Zeile:=Zeile+'-'+Abfluesse[j].zgr.Name;
      End;
      Zeile:=Zeile+')';
      Listbox1.items.add(Zeile);
      Zeile:='          Startwert '+Name+' = '+Eingabe;
      (*Listbox1.items.add(Zeile);*)
      Listbox1.items.AddObject(Zeile,ObjektListe.items[i]);
    End;
  { Fluesse }
  Zeile:='  ';
  Listbox1.items.add(Zeile);
  Zeile:=' Zustandsänderungen ';
  Listbox1.items.add(Zeile);
  For i:=0 To ObjektListe.Count-1 do
    If ObjektListe.items[i].key=VentilId then  begin
      With ObjektListe.items[i] as TVentilObjekt do
        Zeile:='      '+Name+' = '+Eingabe;
      Listbox1.items.AddObject(Zeile,ObjektListe.items[i]);
    End;
  { Konstanten }
  Zeile:=' ';
  Listbox1.items.add(Zeile);
  Zeile:=' Parameter ';
  Listbox1.items.add(Zeile);
  For i:=0 To ObjektListe.Count-1 do with ObjektListe.items[i] do
    If (key=WertId) And (EingangMax=0) (*and
           {not} (*(xtbf=0)*) then begin

    With ObjektListe.items[i] as TWertObjekt do
      Zeile:='      '+Name+' = '+Eingabe;
      Listbox1.items.AddObject(Zeile,ObjektListe.items[i]);
    End;
    { Zwischenwerte }
  Zeile:='  ';
  Listbox1.items.add(Zeile);
  Zeile:=' Zwischenwerte ';
  Listbox1.items.add(Zeile);
  Zeile:='';
  For i:=0 To ObjektListe.Count-1 do
    With ObjektListe.items[i] do
    If (key=WertId) and ((EingangMax>0) (*or
            (TWertObjekt(ObjektListe.items[i].xtbf<>NoTab)*)) then Begin
      Zeile:='      '+Name+' = ';
    (*  P:=PWertObjekt(ObjListe^.at(i));
      If p^.xtbf>0 Then
      Begin            { TabellenFunktion }
        StrCat(Zeile,Eingabe);
        Programm^.Insert(StrNew(Zeile));
        StrCopy(Zeile,'      (');
        For j:=0 to P^.Tabelle^.count-1 do
          Begin
            StrCat(Zeile,'(');
            Str(PWPaar(p^.Tabelle^.at(j))^.x:4:2,Zahlstr);
            StrCat(Zeile,ZahlStr);
            StrCat(Zeile,';');
            Str(PWPaar(p^.Tabelle^.at(j))^.y:4:2,Zahlstr);
            StrCat(Zeile,ZahlStr);
            StrCat(Zeile,')');
            If StrLen(Zeile)>60 Then Begin
              Programm^.Insert(StrNew(Zeile));
              StrCopy(Zeile,'       '); End;
          End;
        StrCat(Zeile,')');  else*)
      Zeile:=Zeile+Eingabe;
      Listbox1.items.AddObject(Zeile,ObjektListe.items[i]);
     end;
    end;

procedure TGleichungen.FormCreate(Sender: TObject);
begin
  FillListBox;
End;

procedure TGleichungen.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
   Action := caFree;
end;

procedure TGleichungen.ListBox1DblClick(Sender: TObject);
Var Objekt:TSimuObjekt;
    SelIndex : integer;
    Zeile    : string;
begin
  SelIndex:=ListBox1.ItemIndex;
  Objekt:=ListBox1.items.objects[SelIndex] as TSimuObjekt;
  if Objekt<>nil then
    if (Objekt.Key=WertId) and (TWertObjekt(Objekt).xtbf=EditTab) then
      begin
        //Tabellenfunktion
        TabEditForm.init(TWertObjekt(Objekt));
        TabEditForm.ShowModal;
      end
    else
      begin
        ObjektDialog.init(Objekt);
        if ObjektDialog.ShowModal=idOk then  begin
          Case Objekt.key of
            ZustandId : Zeile:='          Startwert '+Objekt.Name+' = '+Objekt.Eingabe;
            WertId    : Zeile:='      '+Objekt.Name+' = '+Objekt.Eingabe;
            VentilId  : Zeile:='      '+Objekt.Name+' = '+Objekt.Eingabe;
        end;
        ListBox1.items.delete(SelIndex);
        ListBox1.items.InsertObject(SelIndex,Zeile,Objekt);
      end;
    end;
end;

procedure TGleichungen.ListBox1KeyPress(Sender: TObject; var Key: Char);
begin
   if key=#13 then ListBox1DblClick(Sender);
end;

end.
