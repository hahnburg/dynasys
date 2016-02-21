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

unit Errortxt;

{$MODE Delphi}

(*
  Zentrale Datei für alle Systemmeldungen
  Autor: Walter Hupfeld
  Version: 2.0
  zuletzt bearbeitet: 3.9.2003
*)

interface

Uses Parser;

const
  cr = #10#13;
  ErrorTxt1 ='Fehlerhafter Name! Namen dürfen nur Buchstaben und Ziffern'+
             ' enthalten, keine Sonderzeichen und Leerzeichen.';
  ErrorTxt2 ='Der Objektname ist bereits vergeben!';
  ErrorTxt3 ='Es müssen alle Eingänge verwendet werden!';
  ErrorTxt4 ='Fehlerhafte Eingabe! Dezimalen werden mit einem Komma getrennt.';

  { Unit Simulation }
  ErrorTxt10 = 'Fataler Fehler! ';
  ErrorTxt11 = 'Überlauf: Bei der Berechnung sind zu große Werte entstanden!'+#10#13;
  ErrorTxt12 = 'Division durch Null!'+#10#13;
  ErrorTxt13 = 'Zahl liegt außerhalb des erlaubten Bereichs!'+#10#13;
  ErrorTxt14 = 'Die Zeitverzögerung in der Funktion AlterWert'+#10#13+
               'muss größer als dt sein!'+#10#13;
  ErrorTxt15 = 'Simulation kann nicht gestartet werden!'+#12+#13+
               'Das Modell ist nicht vollständig!';
  ErrorTxt16 = 'Simulation kann nicht gestartet werden!'+#12+#13+
                  'Es sind Zirkelbezüge vohanden!';
  ErrorTxt17 = 'Fataler Fehler beim Übersetzen der Eingabe im Objekt ';
  ErrorTxt18 = ' Überprüfen Sie Ihr Modell!';
  ErrorTxt19 = 'Überlauf: Bei der Berechnung sind zu große Werte entstanden!'+#10#13
                     +'Rechnung fortsetzen?';
  ErrorTxt20 = 'Überprüfen Sie Ihr Modell.';
  ErrorTxt21 = 'Datei kann nicht geöffnet werden!';
  ErrorTxt22 = 'Unbekanntes Datenformat!';
  ErrorTxt23 = 'Kein Modell vorhanden?';
  ErrorTxt30 = 'Nur 4 Ausgabegraphen möglich!';
  ErrorTxt31 = 'Für Phasendiagramme müssen genau 2 Parameter ausgewählt werden!';
  ErrorTxt40 = 'Fehlerhafte Zahleneingabe im Textfeld.'+cr+'Dezimalzahlen werden mit Komma eingegeben!';

  InfoTxt1='Vorhandenes Modell ist noch nicht gesichert?'+#10#13+'Speichern?';
  InfoTxt2='Aktuelles Modell überschreiben?';
  InfoTxt3='Datei speichern ?';
  InfoTxt4='Kein Modell vorhanden oder Modell unvollständig.';


 function ErrorMsg(Error:Errortype):String;

implementation

 function ErrorMsg(Error:Errortype):String;
 begin
   Case Parse.ErrorArt of
                 errOK :  result:='Kein Fehler!';
          errCharacter :  result:='Unerlaubtes Zeichen im Text!';
          errBezeichner:  result:='Undeklarierter Bezeichner!';
          errKlammerAuf:  result:='"(" erwartet!';
          errKlammerZu :  result:='")" erwartet!';
          errSemikolon :  result:='";" erwartet!';
          errAusdruck  :  result:='Arithmetischer Ausdruck erwartet!';
          errOperator  :  result:='Operator erwartet';
          errEmpty     :  result:='Eingabe fehlt!';
          errXtbf      :  result:='Fehlerhafte Tabellenfunktion!'+ #10#13+#10#13+
                               'Die Tabellenfunktion hat die Form'+ #10#13 +
                               'Tabelle(Bezeichner)((x1;y1)(x2;y2) ... (xn;yn)) ';
          errXtbf2     :  result:='In einer Tabellenfunktion müssen die x-Werte'+ #10#13 +
                               'aufsteigend sortiert sein!';
          errDelay     :  result:='Fehlerhafte Funktion AlterWert!'+ #10#13+#10#13+
                               'Die Funktion AlterWert hat die Form'+ #10#13 +
                               'AlterWert(Bezeichner;Verzögerung;Init) ';
          errKommentar :  result:='Abschließende Kommentarklammer fehlt!';
          errRelation  :  result:='Fehler in Wenn-Funktion: Wenn(Bed1<Bed2;Dann;Sonst) ';
      else result :='Unbekannter Fehler'
   end;  {case }
 end;



 end.
