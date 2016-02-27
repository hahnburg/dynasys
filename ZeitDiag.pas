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

unit Zeitdiag;

interface

uses
  SysUtils, unix, Messages, Classes, Graphics, Controls,
  Forms, Dialogs, ZeitSelect, LCLType,
  Liste;

type
  TZeitkurveForm = class(TForm)
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    ZeitDlg:TZeitKurveDlg;
    InputList:TStringList;
    Schritt,x : integer;
  public
    procedure InitWerte(Schritte:integer);
    procedure HoleWerte(Zeit:double);
    procedure ExitWerte(Minimum,Maximum:double);
  end;

var
  ZeitkurveForm: TZeitkurveForm;

implementation

{$R *.lfm}
procedure TZeitkurveForm.HoleWerte(Zeit:Double);
var i,j : integer;
    Eintrag   : String[40];
begin
  inc(Schritt);
  if schritt mod 5=0 then inc(x) else exit;
  for j:=0 to InputList.count-1 do
    begin
      Eintrag:=InputList.strings[j];
      for i:=1 to ObjektListe.count-1 do
         with ObjektListe.items[i] do
           if Eintrag=name then   begin
             (* ChartFX1.ThisSerie:=j;*)
             (* ChartFX1.Value[x]:=G_Wert;*)
         End;
    end;
end;

Procedure TZeitkurveForm.ExitWerte(Minimum,Maximum:double);
Begin
End;

procedure TZeitkurveForm.InitWerte(Schritte:integer);
begin
  Schritt:=-1;x:=-1;
end;

procedure TZeitkurveForm.FormCreate(Sender: TObject);
var i:integer;
begin
  InputList:=TStringList.Create;
  try
    ZeitDlg:=TZeitKurveDlg.Create(self);
    if ZeitDlg.ShowModal = idCancel Then
      begin
        self.close;
      end
    else
      for i:=0 to ZeitDlg.DstList.items.count-1 do
        InputList.add(ZeitDlg.DstList.items[i]);
  except
    MessageDlg('Fehler beim Öffnen des Dialogs!',mtError,[mbok],0);
  end;
  (*ChartFX1.width:=ClientWidth;
  ChartFX1.height:=ClientHeight;*)
end;


procedure TZeitkurveForm.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
 Action := caFree;
end;

end.
