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

unit Tabselect;

{$MODE Delphi}

(*
  Auswahldialog für Tabelleneinträge
  Version: 2.0
*)

interface

uses unix, Classes, Graphics, Forms, Controls, StdCtrls, LCLType,
  Buttons, ExtCtrls, Liste, SimObjekt, ComCtrls, Spin;
const
  LB_ERR = -1;
type
  TTabelleDlg = class(TForm)
    ButtonPanel: TPanel;
    OKBtn: TBitBtn;
    CancelBtn: TBitBtn;
    HelpBtn: TBitBtn;
    PageControl1: TPageControl;
    TabSheet1: TTabSheet;
    GroupBox1: TGroupBox;
    SrcLabel: TLabel;
    DstLabel: TLabel;
    IncludeBtn: TSpeedButton;
    IncAllBtn: TSpeedButton;
    ExcludeBtn: TSpeedButton;
    ExAllBtn: TSpeedButton;
    SrcList: TListBox;
    DstList: TListBox;
    TabSheet2: TTabSheet;
    GroupBox2: TGroupBox;
    Label1: TLabel;
    SpinEdit1: TSpinEdit;
    procedure IncludeBtnClick(Sender: TObject);
    procedure ExcludeBtnClick(Sender: TObject);
    procedure IncAllBtnClick(Sender: TObject);
    procedure ExAllBtnClick(Sender: TObject);
    procedure FormPaint(Sender: TObject);
    procedure MoveSelected(List: TCustomListBox; Items: TStrings);
    procedure SetItem(List: TListBox; Index: Integer);
    function GetFirstSelection(List: TCustomListBox): Integer;
    procedure SetButtons;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  TabelleDlg: TTabelleDlg;

implementation

{$R *.lfm}

procedure TTabelleDlg.IncludeBtnClick(Sender: TObject);
var
  Index: Integer;
begin
  Index := GetFirstSelection(SrcList);
  MoveSelected(SrcList, DstList.Items);
  SetItem(SrcList, Index);
end;

procedure TTabelleDlg.ExcludeBtnClick(Sender: TObject);
var
  Index: Integer;
begin
  Index := GetFirstSelection(DstList);
  MoveSelected(DstList, SrcList.Items);
  SetItem(DstList, Index);
end;

procedure TTabelleDlg.IncAllBtnClick(Sender: TObject);
var
  I: Integer;
begin
  for I := 0 to SrcList.Items.Count - 1 do
    DstList.Items.AddObject(SrcList.Items[I],
      SrcList.Items.Objects[I]);
  SrcList.Items.Clear;
  SetItem(SrcList, 0);
end;

procedure TTabelleDlg.ExAllBtnClick(Sender: TObject);
var
  I: Integer;
begin
  for I := 0 to DstList.Items.Count - 1 do
    SrcList.Items.AddObject(DstList.Items[I], DstList.Items.Objects[I]);
  DstList.Items.Clear;
  SetItem(DstList, 0);
end;

procedure TTabelleDlg.FormPaint(Sender: TObject);
var i : integer;
begin
  SrcList.items.clear;
  DstList.items.clear;
  for i:=0 to ObjektListe.Count-1 do begin
    if ObjektListe.items[i].key=ZustandId then
            DstList.items.add(ObjektListe.items[i].name);
//         SrcList.items.add(ObjektListe.items[i].name)
  end;
  for i:=0 to ObjektListe.Count-1 do begin
    if (ObjektListe.items[i].key>0) and (ObjektListe.items[i].key<ZustandId)then
         SrcList.items.add(ObjektListe.items[i].name)
  end;
  if ObjektListe.Count>0 then SrcList.selected[0]:=true;
end;

procedure TTabelleDlg.MoveSelected(List: TCustomListBox; Items: TStrings);
var
  I: Integer;
begin
  for I := List.Items.Count - 1 downto 0 do
    if List.Selected[I] then
    begin
      Items.AddObject(List.Items[I], List.Items.Objects[I]);
//      Items.Add(List.Items[I]);
      List.Items.Delete(I);
    end;
end;

procedure TTabelleDlg.SetButtons;
var
  SrcEmpty, DstEmpty: Boolean;
begin
  SrcEmpty := SrcList.Items.Count = 0;
  DstEmpty := DstList.Items.Count = 0;
  IncludeBtn.Enabled := not SrcEmpty;
  IncAllBtn.Enabled := not SrcEmpty;
  ExcludeBtn.Enabled := not DstEmpty;
  ExAllBtn.Enabled := not DstEmpty;
end;

function TTabelleDlg.GetFirstSelection(List: TCustomListBox): Integer;
begin
  for Result := 0 to List.Items.Count - 1 do
    if List.Selected[Result] then Exit;
  Result := LB_ERR;
end;

procedure TTabelleDlg.SetItem(List: TListBox; Index: Integer);
var
  MaxIndex: Integer;
begin
  with List do
  begin
    SetFocus;
    MaxIndex := List.Items.Count - 1;
    if Index = LB_ERR then Index := 0
    else if Index > MaxIndex then Index := MaxIndex;
    Selected[Index] := True;
  end;
  SetButtons;
end;

end.
