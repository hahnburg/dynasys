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

unit ObjectDlg;

{$MODE Delphi}

(*
  Modelleditor für Zustände und Zwischenwerte
*)

interface

uses unix, LCLType, Classes, Graphics, Forms, Controls, Buttons,
  StdCtrls, ExtCtrls, Dialogs, SysUtils,
  SimObjekt, ErrorTxt, Parser, Util, Liste, TabEdit;

 const
  MaxFunktionen = 21; //22;
  Funktionen : Array [1..MaxFunktionen] of String[13] =
    ('Zeit','pi','e','sin()','cos()','tan()','arctan()',
    'mod','div','exp()','ln()','Quadrat()','Wurzel()','abs()','sign()',
    'Wenn()','Zufall()','Impuls()','Rampe()','Tabelle()','int()'{,'AlterWert()'});

type

  { TObjektDialog }

  TObjektDialog = class(TForm)
    OKBtn: TBitBtn;
    CancelBtn: TBitBtn;
    HelpBtn: TBitBtn;
    Bevel1: TBevel;
    ListBox1: TListBox;
    Label1: TLabel;
    Edit1: TEdit;
    Label2: TLabel;
    Label3: TLabel;
    Memo1: TMemo;
    B7: TButton;
    B8: TButton;
    B9: TButton;
    Bdiv: TButton;
    B4: TButton;
    B5: TButton;
    B6: TButton;
    BMal: TButton;
    B1: TButton;
    B2: TButton;
    B3: TButton;
    BPlus: TButton;
    B0: TButton;
    BKomma: TButton;
    Bminus: TButton;
    BCE: TButton;
    Bp: TButton;
    BBlank: TButton;
    ListBox2: TListBox;
    Label4: TLabel;
    BKlaAuf: TButton;
    BKlaZu: TButton;
    Bexo: TButton;
    BPot: TButton;
    TabFktBtn: TBitBtn;
    procedure FormActivate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure ListBox1Click(Sender: TObject);
    procedure ButtonClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure ListBox2Click(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
   // procedure OKBtnClick(Sender: TObject);
     procedure TabFktBtnClick(Sender: TObject);
    procedure Memo1KeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);

  private
    Objekt:TSimuObjekt;
    ObjName : String[40];
    EingabeZeile : String;
  public
    procedure Init(Aobj:TSimuObjekt);
  end;

var
  ObjektDialog: TObjektDialog;

implementation

{$R *.lfm}

procedure TObjektDialog.Init(Aobj:TSimuObjekt);
begin
  Objekt:=Aobj;
  With Objekt do
    Case key of
      ZustandId : Caption:='Zustand';
      VentilId  : Caption:='Zustandsänderung';
      WertId    : if EingangMax=0 then Caption:='Parameter'
                  else Caption:='Zwischenwert';
      WirkPfeilID : Caption:='Wirkung';
    end;
end;

procedure TObjektDialog.FormActivate(Sender: TObject);
var i:integer;
    AnzahlEingaenge : integer;
    obj : TSimuObjekt;
    R:Real;
begin
  if Objekt.key=ZustandId then begin
    { eine Zustandsgöße kann mit einem Parameter initialisiert werden }
    for i:=0 to ObjektListe.count-1 do
        If objektListe.items[i].key=WertId then
          if ObjektListe.items[i].EingangMax=0 then
             begin
               obj:=ObjektListe.items[i];
               parse.LerneLokVariable(Obj.Name,@R,@obj.delay,@obj.DelayValue);
               ListBox1.items.add(obj.name);
             end
  end else if (Objekt.key>0) and (Objekt.key<ZustandId) then
    begin
     AnzahlEingaenge:=0;
     { Erst Zustände }
     for i:=1 to Objekt.EingangMax Do Begin
         obj:=TWirkPfeilObjekt(Objekt.Eingaenge[i].zgr).von;
         if obj.key=ZustandId Then Begin
           parse.LerneLokVariable(obj.Name,@R,@obj.delay,@obj.DelayValue);
           ListBox1.items.add(obj.name);
           INC(AnzahlEingaenge);
         End;
     end;  { Dann der Rest }
     for i:=1 to Objekt.EingangMax Do Begin
         obj:=TWirkPfeilObjekt(Objekt.Eingaenge[i].zgr).von;
         If obj.key<>ZustandId Then Begin
           parse.LerneLokVariable(obj.Name,@R,@obj.delay,@obj.DelayValue);
           ListBox1.items.add(obj.name);
           INC(AnzahlEingaenge);
         end;
     end;
    end;
  Edit1.Text:=Objekt.Name;
  Memo1.Text:=Objekt.Eingabe;
  TabFktBtn.Visible:=Objekt.EingangMax<=1
end;

procedure TObjektDialog.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  While ListBox1.items.count >0 do Listbox1.items.delete(0);
end;

procedure TObjektDialog.ListBox1Click(Sender: TObject);
begin
  Memo1.SelText:=ListBox1.items[ListBox1.ItemIndex];
  Memo1.SetFocus;
end;

procedure TObjektDialog.ButtonClick(Sender: TObject);
begin
  if Sender=B0 then Memo1.Seltext:='0' else
  if Sender=B1 then Memo1.Seltext:='1' else
  if Sender=B2 then Memo1.Seltext:='2' else
  if Sender=B3 then Memo1.Seltext:='3' else
  if Sender=B4 then Memo1.Seltext:='4' else
  if Sender=B5 then Memo1.Seltext:='5' else
  if Sender=B6 then Memo1.Seltext:='6' else
  if Sender=B7 then Memo1.Seltext:='7' else
  if Sender=B8 then Memo1.Seltext:='8' else
  if Sender=B9 then Memo1.Seltext:='9' else
  if Sender=Bmal then Memo1.Seltext:='*' else
  if Sender=Bplus then Memo1.Seltext:='+' else
  if Sender=Bdiv then Memo1.Seltext:='/' else
  if Sender=Bminus then Memo1.Seltext:='-' else
  if Sender=Bkomma then Memo1.Seltext:=',' else
  if Sender=BKlaZu then Memo1.Seltext:=')' else
  if Sender=BKlaAuf then Memo1.Seltext:='(' else
  if Sender=Bblank then Memo1.Seltext:=' ' else
  if Sender=BPot then Memo1.Seltext:='^' else
  if Sender=BExo then Memo1.Seltext:='E' else ;
  Memo1.SetFocus;
end;

procedure TObjektDialog.FormCreate(Sender: TObject);
var i:integer;
begin
  for i:=1 to MaxFunktionen do ListBox2.items.add(Funktionen[i]);
end;

procedure TObjektDialog.ListBox2Click(Sender: TObject);
begin
  Memo1.SelText:=ListBox2.items[ListBox2.ItemIndex];
  Memo1.SetFocus;
  (*If pos('()',ListBox2.items[ListBox2.ItemIndex])>0 then
    Memo1.SelText:=#8;*)
end;

procedure TObjektDialog.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
var msg:String;
    i  : integer;
    P  : TSimuObjekt;
    NStr : BezString;
begin
  If ModalResult=mrCancel then begin canclose:=true; exit end;
  Objekt.gueltig:=false;
  ObjName:=Edit1.Text;
  EingabeZeile:=Memo1.Text;
  if not NameKorrekt(ObjName) Then Begin
    MessageDlg(ErrorTxt1,mtError,[mbok],0);
    CanClose:=False;  Exit;
  end;
  { Objektname schon vorhanden ? }
  if ObjName<>Objekt.Name then
    if ObjektListe.NameVorhanden(ObjName) Then Begin
      MessageDlg(ErrorTxt2,mtError,[mbok],0);
      CanClose:=False;  Exit;
    End;
  case Objekt.key of
ZustandId :
    Begin
       with Objekt as TZustandObjekt do begin
         Parse.LoescheBaum(Baum);
         Parse.LoescheBaum(StartWert);
         StartWert:=parse.parse(EingabeZeile,NIL);
         If parse.SyntaxError Then Begin
            MessageDlg(ErrorMsg(parse.ErrorArt),mtError,[mbok],0);
            CanClose:=False;
         End Else Begin
          If Name<>ObjName Then Begin
              {Objekt mit Wirkverbindung ungültig erklären }
               For i:=1 To AusgangMax do Begin
                If Not ErsetzeNamen(TWirkPfeilObjekt(Objekt.Ausgaenge[i].zgr).nach,Objekt.Name,ObjName) Then
                   TWirkPfeilObjekt(Ausgaenge[i].zgr).nach.gueltig:=False;
              End;
            Name:=ObjName;
          end;
          Eingabe:=EingabeZeile;
          gueltig:=true;
          CanClose:=True;
         end;
       Parse.LoescheBaum(StartWert);
       end;  {with}
      end; {ZustandId }
WertId :
     begin
       with Objekt as TWertObjekt do begin
         Parse.LoescheBaum(Objekt.Baum);
       { Prüfen, ob alle Eingänge verwendet wurden }
       for i:=1 to Objekt.EingangMax Do Begin
         P:=TWirkPfeilObjekt(Objekt.Eingaenge[i].zgr).von;
         NStr:=P.Name;
         if Pos(UpperCase(NStr),UpperCase(EingabeZeile))=0 Then
           begin
             MessageDlg(ErrorTxt3,mtError,[mbok],0);
             CanClose:=False; Exit
           end;
        end;
       { Eingabe-Syntax prüfen }
       If TWertObjekt(Objekt).xtbf=NoTab Then Objekt.Baum:=parse.parse(EingabeZeile,NIL)
       Else Objekt.Baum:=parse.parse(Eingabe,TWertObjekt(Objekt).Tabelle);
       If parse.SyntaxError Then Begin
         MessageDlg(ErrorMsg(parse.ErrorArt),mtError,[mbok],0);
         CanClose:=False;
         Memo1.SetFocus;
         Memo1.SelStart:=0;
         Memo1.SelLength:= Parse.ScanErrPos;
       End Else Begin
          {Werte übertragen }
          If Objekt.Name<>ObjName Then Begin
              {Objekt mit Wirkverbindung ungültig erklären }
              For i:=1 To Objekt.AusgangMax do Begin
                If Not ErsetzeNamen(TWirkPfeilObjekt(Objekt.Ausgaenge[i].zgr).nach,Objekt.Name,ObjName) Then
                   TWirkPfeilObjekt(Objekt.Ausgaenge[i].zgr).nach.gueltig:=False;
              End
            End;
          Objekt.Name:=ObjName;
          Objekt.Eingabe:=EingabeZeile;
          Objekt.gueltig:=true;
          CanClose:=True;
       End;
       {Baum auf alle Fälle löschen }
       Parse.LoescheBaum(Objekt.Baum);

       end; { with Objekt }
     end; {WertId}
VentilId :
     begin
       with Objekt as TVentilObjekt do begin
         Parse.LoescheBaum(Objekt.Baum);
       { Prüfen, ob alle Eingänge verwendet wurden }
       for i:=1 to Objekt.EingangMax Do Begin
         P:=TWirkPfeilObjekt(Objekt.Eingaenge[i].zgr).von;
         NStr:=P.Name;
         if Pos(UpperCase(NStr),UpperCase(EingabeZeile))=0 Then
           begin
             MessageDlg(ErrorTxt3,mtError,[mbok],0);
             CanClose:=False; Exit
           end;
        end;
       { Eingabe-Syntax prüfen }
       Objekt.Baum:=parse.parse(EingabeZeile,NIL);
       If parse.SyntaxError Then Begin
         MessageDlg(ErrorMsg(parse.ErrorArt),mtError,[mbok],0);
         CanClose:=False;
         Memo1.SetFocus;
         Memo1.SelStart:=0;
         Memo1.SelLength:= Parse.ScanErrPos;
       End Else Begin
          {Werte übertragen }
          If Objekt.Name<>ObjName Then Begin
              {Objekt mit Wirkverbindung ungültig erklären }
              For i:=1 To Objekt.AusgangMax do Begin
                If Not ErsetzeNamen(TWirkPfeilObjekt(Objekt.Ausgaenge[i].zgr).nach,Objekt.Name,ObjName) Then
                   TWirkPfeilObjekt(Objekt.Ausgaenge[i].zgr).nach.gueltig:=False;
              End
            End;
          Objekt.Name:=ObjName;
          Objekt.Eingabe:=EingabeZeile;
          Objekt.gueltig:=true;
          CanClose:=True;
       End;
       {Baum auf alle Fälle löschen }
       Parse.LoescheBaum(Objekt.Baum);

       end; { with Objekt }
     end; {VentilId}
    end; { case }
   Parse.LoescheLokBezListe;
end;


//procedure TObjektDialog.OKBtnClick(Sender: TObject);
//begin
//self.OKBtn.Click; //superflous (test only)
//end;

procedure TObjektDialog.TabFktBtnClick(Sender: TObject);
begin
  // Tabelleneditor aufrufen
  TabEditForm:=TTabEditForm.Create(Application);
  TabEditForm.init(Objekt);
  TabEditForm.Show;
  // Objektdialog schließen
  self.close();
end;



procedure TObjektDialog.Memo1KeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
if(Key=VK_RETURN) then
self.OKBtn.Click;
end;

end.
