unit UGeneralScore;

interface

uses
  Windows, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  UBasicScore, StdCtrls, ExtCtrls, UzLogGlobal, Menus, Grids, UITypes,
  UMultipliers, Buttons, UGeneralMulti2;


type
  TPointsTable = array[b19..HiBand, mCW..mOther] of Integer;

  TGeneralScore = class(TBasicScore)
    Grid: TStringGrid;
    procedure FormShow(Sender: TObject);
    procedure GridDrawCell(Sender: TObject; ACol, ARow: Integer; Rect: TRect; State: TGridDrawState);
  private
    { Private declarations }
    procedure ResetParams(); // called from LoadCFG
  public
    { Public declarations }
    SameCTYPoints, SameCONTPoints : boolean;
    PointsTable : TPointsTable;
    LocalPointsTable : TPointsTable;
    SameCTYPointsTable : TPointsTable;
    SameCONTPointsTable : TPointsTable;

    SpecialCallPointsTable : TPointsTable;
    SpecialCalls : string;  // special callsigns for specialcallpointstable

    AlphabetPointsTable : array[ord('0')..ord('Z')] of Integer;
    AlphabetPoints : boolean;
    formMulti: TGeneralMulti2;

    procedure SetPointsTable(var PT : TPointsTable; str : string);
    procedure CalcPoints(var aQSO : TQSO);
    procedure AddNoUpdate(var aQSO : TQSO); override;
    procedure Update; override;
    procedure Reset; override;
    procedure Add(var aQSO : TQSO); override; {calculates points}
    procedure LoadCFG(Filename : string);
  end;

implementation

uses
  Main;

{$R *.DFM}

procedure TGeneralScore.SetPointsTable(var PT: TPointsTable; str: string);
var
   i, k: Integer;
   tempstr, pstr: string;
   B: TBand;
begin
   tempstr := str + ',';
   B := b19;

   while pos(',', tempstr) > 0 do begin
      i := pos(',', tempstr);
      if i > 0 then begin
         pstr := copy(tempstr, 1, i - 1);
      end
      else begin
         exit;
      end;

      k := StrToIntDef(pstr, 0);
      PT[B, mCW] := k;
      delete(tempstr, 1, i);

      i := pos(',', tempstr);
      if i > 0 then begin
         pstr := copy(tempstr, 1, i - 1);
      end
      else begin
         exit;
      end;

      k := StrToIntDef(pstr, 0);
      PT[B, mSSB] := k;
      PT[B, mFM] := k;
      PT[B, mAM] := k;
      delete(tempstr, 1, i);

      repeat
         inc(B);
      until NotWARC(B);
   end;
end;

procedure TGeneralScore.ResetParams();
var
   B: TBand;
   M: TMode;
   i: Integer;
begin
   for B := b19 to HiBand do begin
      for M := mCW to mOther do begin
         PointsTable[B, M] := 1;
         LocalPointsTable[B, M] := 1;
         SameCTYPointsTable[B, M] := 1;
         SameCONTPointsTable[B, M] := 1;
         SpecialCallPointsTable[B, M] := 1;
      end;
   end;

   SameCTYPoints := False;
   SameCONTPoints := False;
   AlphabetPoints := False;
   SpecialCalls := '';

   for i := ord('0') to ord('Z') do begin
      AlphabetPointsTable[i] := 0;
   end;

   SerialContestType := 0;
   for B := b19 to HiBand do begin
      SerialArray[B] := 1;
   end;

   with formMulti do begin
      for i := 0 to MAXLOCAL do begin
         LocalString[i] := '';
      end;

      MinLocalLen := 0;
      _cut := 0;
      _lcut := 0;
      _tail := 0;
      _ltail := 0;
   end;
end;

procedure TGeneralScore.LoadCFG(Filename: string);
var
   zfile: textfile;
   check: boolean;
   rstr, tstr, com, opr, str: string;
   p, q, work, i, k: Integer;
   _bnd: TBand;
const
   TAB = #$09;
begin
   // Filename�̓t���p�X
   if FileExists(Filename) = False then begin
      MessageDlg('[' + Filename + '] file cannot be found. Place it in the same folder as ZLOG.EXE', mtError, [mbOK], 0);
      Exit;
   end;

   ResetParams();
   System.Assign(zfile, Filename);
{$I-}
   System.Reset(zfile);
{$I+}

   while not(eof(zfile)) do begin
      readln(zfile, rstr);
      if (rstr <> '') and (rstr[1] <> ';') then begin

         q := pos(';', rstr);
         if q > 0 then
            rstr := copy(rstr, 1, q - 1); { Cut out comment }

         p := 0;
         repeat
            inc(p);
         until (CharInSet(rstr[p], [' ', TAB])) or (p > length(rstr));
         q := p;
         repeat
            inc(q);
         until not(CharInSet(rstr[q], [' ', TAB])) or (q > length(rstr));

         com := Uppercase(copy(rstr, 1, p - 1));
         opr := copy(rstr, q, 255);

         opr := Uppercase(opr);

         if pos('PT', com) = 1 then begin
            _bnd := b19;
            if copy(com, 3, 3) = '1.9' then
               _bnd := b19;
            if copy(com, 3, 3) = '3.5' then
               _bnd := b35;
            if copy(com, 3, 3) = '7' then
               _bnd := b7;
            if copy(com, 3, 3) = '10' then
               _bnd := b10;
            if copy(com, 3, 3) = '14' then
               _bnd := b14;
            if copy(com, 3, 3) = '18' then
               _bnd := b18;
            if copy(com, 3, 3) = '21' then
               _bnd := b21;
            if copy(com, 3, 3) = '24' then
               _bnd := b24;
            if copy(com, 3, 3) = '28' then
               _bnd := b28;
            if copy(com, 3, 3) = '50' then
               _bnd := b50;
            if copy(com, 3, 3) = '144' then
               _bnd := b144;
            if copy(com, 3, 3) = '430' then
               _bnd := b430;
            if copy(com, 3, 3) = '120' then
               _bnd := b1200;
            if copy(com, 3, 3) = '240' then
               _bnd := b2400;
            if copy(com, 3, 3) = '560' then
               _bnd := b5600;
            if copy(com, 3, 3) = '10G' then
               _bnd := b10g;
            if length(opr) >= 2 then begin
               work := StrToIntDef(opr[1], 1);
               PointsTable[_bnd, mSSB] := work;

               work := StrToIntDef(opr[2], 1);
               PointsTable[_bnd, mCW] := work;

               work := StrToIntDef(opr[3], 1);
               PointsTable[_bnd, mFM] := work;

               work := StrToIntDef(opr[4], 1);
               PointsTable[_bnd, mAM] := work;
            end;
         end;

         if pos('LPT', com) = 1 then begin
            _bnd := b19;
            if copy(com, 4, 3) = '1.9' then
               _bnd := b19;
            if copy(com, 4, 3) = '3.5' then
               _bnd := b35;
            if copy(com, 4, 3) = '7' then
               _bnd := b7;
            if copy(com, 4, 3) = '10' then
               _bnd := b10;
            if copy(com, 4, 3) = '14' then
               _bnd := b14;
            if copy(com, 4, 3) = '18' then
               _bnd := b18;
            if copy(com, 4, 3) = '21' then
               _bnd := b21;
            if copy(com, 4, 3) = '24' then
               _bnd := b24;
            if copy(com, 4, 3) = '28' then
               _bnd := b28;
            if copy(com, 4, 3) = '50' then
               _bnd := b50;
            if copy(com, 4, 3) = '144' then
               _bnd := b144;
            if copy(com, 4, 3) = '430' then
               _bnd := b430;
            if copy(com, 4, 3) = '120' then
               _bnd := b1200;
            if copy(com, 4, 3) = '240' then
               _bnd := b2400;
            if copy(com, 4, 3) = '560' then
               _bnd := b5600;
            if copy(com, 4, 3) = '10G' then
               _bnd := b10g;
            if length(opr) >= 2 then begin
               work := StrToIntDef(opr[1], 1);
               LocalPointsTable[_bnd, mSSB] := work;

               work := StrToIntDef(opr[2], 1);
               LocalPointsTable[_bnd, mCW] := work;

               work := StrToIntDef(opr[3], 1);
               LocalPointsTable[_bnd, mFM] := work;

               work := StrToIntDef(opr[4], 1);
               LocalPointsTable[_bnd, mAM] := work;
            end;
         end;

         if pos('XPT', com) = 1 then begin
            _bnd := b19;
            if copy(com, 4, 3) = '1.9' then
               _bnd := b19;
            if copy(com, 4, 3) = '3.5' then
               _bnd := b35;
            if copy(com, 4, 3) = '7' then
               _bnd := b7;
            if copy(com, 4, 3) = '10' then
               _bnd := b10;
            if copy(com, 4, 3) = '14' then
               _bnd := b14;
            if copy(com, 4, 3) = '18' then
               _bnd := b18;
            if copy(com, 4, 3) = '21' then
               _bnd := b21;
            if copy(com, 4, 3) = '24' then
               _bnd := b24;
            if copy(com, 4, 3) = '28' then
               _bnd := b28;
            if copy(com, 4, 3) = '50' then
               _bnd := b50;
            if copy(com, 4, 3) = '144' then
               _bnd := b144;
            if copy(com, 4, 3) = '430' then
               _bnd := b430;
            if copy(com, 4, 3) = '120' then
               _bnd := b1200;
            if copy(com, 4, 3) = '240' then
               _bnd := b2400;
            if copy(com, 4, 3) = '560' then
               _bnd := b5600;
            if copy(com, 4, 3) = '10G' then
               _bnd := b10g;
            if length(opr) >= 4 then begin
               work := StrToIntDef(opr[1] + opr[2], 1);
               PointsTable[_bnd, mSSB] := work;

               work := StrToIntDef(opr[3] + opr[4], 1);
               PointsTable[_bnd, mCW] := work;

               work := StrToIntDef(opr[5] + opr[6], 1);
               PointsTable[_bnd, mFM] := work;

               work := StrToIntDef(opr[7] + opr[8], 1);
               PointsTable[_bnd, mAM] := work;
            end;
         end;

         if pos('XLPT', com) = 1 then begin
            _bnd := b19;
            if copy(com, 5, 3) = '1.9' then
               _bnd := b19;
            if copy(com, 5, 3) = '3.5' then
               _bnd := b35;
            if copy(com, 5, 3) = '7' then
               _bnd := b7;
            if copy(com, 5, 3) = '10' then
               _bnd := b10;
            if copy(com, 5, 3) = '14' then
               _bnd := b14;
            if copy(com, 5, 3) = '18' then
               _bnd := b18;
            if copy(com, 5, 3) = '21' then
               _bnd := b21;
            if copy(com, 5, 3) = '24' then
               _bnd := b24;
            if copy(com, 5, 3) = '28' then
               _bnd := b28;
            if copy(com, 5, 3) = '50' then
               _bnd := b50;
            if copy(com, 5, 3) = '144' then
               _bnd := b144;
            if copy(com, 5, 3) = '430' then
               _bnd := b430;
            if copy(com, 5, 3) = '120' then
               _bnd := b1200;
            if copy(com, 5, 3) = '240' then
               _bnd := b2400;
            if copy(com, 5, 3) = '560' then
               _bnd := b5600;
            if copy(com, 5, 3) = '10G' then
               _bnd := b10g;
            if length(opr) >= 4 then begin
               work := StrToIntDef(opr[1] + opr[2], 1);
               LocalPointsTable[_bnd, mSSB] := work;

               work := StrToIntDef(opr[3] + opr[4], 1);
               LocalPointsTable[_bnd, mCW] := work;

               work := StrToIntDef(opr[5] + opr[6], 1);
               LocalPointsTable[_bnd, mFM] := work;

               work := StrToIntDef(opr[7] + opr[8], 1);
               LocalPointsTable[_bnd, mAM] := work;
            end;
         end;

         if com = 'SAMECTYPT' then begin
            SetPointsTable(SameCTYPointsTable, opr);
            SameCTYPoints := true;
         end;

         if com = 'SAMECONTPT' then begin
            SetPointsTable(SameCONTPointsTable, opr);
            SameCONTPoints := true;
         end;

         if com = 'LOCALPT' then begin
            SetPointsTable(LocalPointsTable, opr);
         end;

         if com = 'DEFAULTPT' then begin
            SetPointsTable(PointsTable, opr);
         end;

         if com = 'SPECIALCALLPT' then begin
            SetPointsTable(SpecialCallPointsTable, opr);
         end;

         if com = 'SPECIALCALLS' then begin
            if SpecialCalls <> '' then
               SpecialCalls := SpecialCalls + ',' + opr
            else
               SpecialCalls := opr;
         end;

         if com = 'LOCALCTY' then begin
            formMulti.LocalCTY := Uppercase(opr);
         end;

         if com = 'LOCALCONT' then begin
            formMulti.LocalCONT := Uppercase(opr);
         end;

         if com = 'LOCAL' then begin
            tstr := '';
            k := 0;
            for i := 1 to length(opr) do begin
               if opr[i] = ',' then begin
                  formMulti.LocalString[k] := tstr;
                  if k < MAXLOCAL then
                     inc(k);
                  tstr := '';
               end
               else
                  tstr := tstr + opr[i];
            end;
            if k <= MAXLOCAL then
               formMulti.LocalString[k] := tstr;
         end;

         if pos('ALPHAPT', com) = 1 then begin
            AlphabetPoints := true;
            for i := 1 to (length(opr) div 2) do begin
               if opr[2 * i - 1] = '?' then begin
                  if CharInSet(opr[2 * i], ['0' .. '9']) = True then
                     for k := ord('0') to ord('Z') do
                        AlphabetPointsTable[k] := StrToInt(opr[2 * i]);
               end
            end;
            for i := 1 to (length(opr) div 2) do begin
               if CharInSet(opr[2 * i - 1], ['0' .. 'Z']) = True then begin
                  if CharInSet(opr[2 * i], ['0' .. '9']) = True then
                     AlphabetPointsTable[ord(opr[2 * i - 1])] := StrToInt(opr[2 * i]);
               end
            end;
         end;

         if com = 'LOCMIN' then begin
            work := StrToIntDef(opr, -99);
            if work >= 0 then
               formMulti.MinLocalLen := work;
         end;

         if com = 'SENDNR' then begin
            dmZlogGlobal.Settings._sentstr := opr;
         end;

         if com = 'DAT' then begin
            tstr := opr;
            if pos('.', tstr) = 0 then begin
               tstr := tstr + '.DAT';
            end;

            tstr := ExtractFilePath(Filename) + tstr;

            formMulti.LoadDAT(tstr);
         end;

         if com = 'TIME' then
            if opr = 'UTC' then begin
               UseUTC := true;
               TQSO(Log.List[0]).QSO.RSTSent := _USEUTC; // JST = 0; UTC = $FFFF
            end;

         if com = 'CTY' then begin
            formMulti.LoadCTY(Uppercase(opr));
         end;

         if com = 'COUNTMULTIONCE' then begin
            if opr = 'ON' then
               formMulti.CountOnce := true
            else
               formMulti.CountOnce := False;
         end;

         if com = 'NOCTYMULTI' then begin
            formMulti.NoCTYMulti := Uppercase(opr);
         end;

         if com = 'MODE' then begin
            if opr = 'ON' then begin
               Log.AcceptDifferentMode := true;
            end;
         end;

         if com = 'CUT' then begin
            work := StrToIntDef(opr, -99);
            if work <> -99 then
               formMulti._cut := work;
         end;

         if com = 'LCUT' then begin
            work := StrToIntDef(opr, -99);
            if work <> -99 then
               formMulti._lcut := work;
         end;

         if com = 'TAIL' then begin
            work := StrToIntDef(opr, -99);
            if work <> -99 then
               formMulti._tail := work;
         end;

         if com = 'LTAIL' then begin
            work := StrToIntDef(opr, -99);
            if work <> -99 then
               formMulti._ltail := work;
         end;

         if com = 'UNDEFMULTI' then begin
            if opr = 'ON' then
               formMulti.UndefMulti := true;
         end;

         if com = 'JARL' then begin
            if opr = 'ON' then
               formMulti.CutTailingAlphabets := true;
         end;

         if com = 'CUTTAILABT' then // equivalent to JARL
         begin
            if opr = 'ON' then
               formMulti.CutTailingAlphabets := true;
         end;

         if com = 'POWER' then begin
            _bnd := b19;
            for i := 1 to length(opr) do begin
               case opr[i] of
                  'A':
                     dmZlogGlobal.CurrentPower[_bnd] := p010;
                  'B':
                     dmZlogGlobal.CurrentPower[_bnd] := p025;
                  'C':
                     dmZlogGlobal.CurrentPower[_bnd] := p050;
                  'D':
                     dmZlogGlobal.CurrentPower[_bnd] := p100;
                  'E':
                     dmZlogGlobal.CurrentPower[_bnd] := p500;
                  'O':
                     dmZlogGlobal.CurrentPower[_bnd] := p001;
                  'F':
                     dmZlogGlobal.CurrentPower[_bnd] := p005;
                  'N':
                     dmZlogGlobal.CurrentPower[_bnd] := p002;
                  'T':
                     dmZlogGlobal.CurrentPower[_bnd] := p020;
                  'W':
                     dmZlogGlobal.CurrentPower[_bnd] := p200;
                  'K':
                     dmZlogGlobal.CurrentPower[_bnd] := p1000;
                  'X':
                     dmZlogGlobal.CurrentPower[_bnd] := p1000;
                  'P':
                     dmZlogGlobal.CurrentPower[_bnd] := pwrP;
                  'L':
                     dmZlogGlobal.CurrentPower[_bnd] := pwrL;
                  'M':
                     dmZlogGlobal.CurrentPower[_bnd] := pwrM;
                  'H':
                     dmZlogGlobal.CurrentPower[_bnd] := pwrH;
                  '-': begin
                     dmZlogGlobal.CurrentPower[_bnd] := pwrP;
                     MainForm.HideBandMenu(_bnd);
                  end;
               end;

               if _bnd < HiBand then begin
                  repeat
                     inc(_bnd);
                  until NotWARC(_bnd);
               end;
            end;

            MainForm.HideBandMenuWarc();
         end;

         if com = 'UNLISTEDMULTI' then begin
            if opr = 'ON' then
               formMulti.AllowUnlistedMulti := true;
         end;

         if com = 'NOMULTI' then begin
            if opr = 'ON' then
               formMulti.NoMulti := true;
         end;

         if com = 'PXMULTI' then begin
            // CAPTION := OPR;
            if opr = 'NORMAL' then begin
               // undefMulti := True;
               formMulti.PXMulti := PX_Normal;
            end;
            if opr = 'WPX' then begin
               // undefMulti := True;
               formMulti.PXMulti := PX_WPX;
            end;
            if opr = 'OFF' then begin
               formMulti.PXMulti := 0;
            end;
         end;

         if com = 'SERIAL' then begin
            if opr = 'ALL' then
               SerialContestType := SER_ALL;
            if opr = 'BAND' then
               SerialContestType := SER_BAND;
         end;

         if com = 'SERIALSTART' then begin
            for _bnd := b19 to HiBand do
               SerialArray[_bnd] := StrToInt(opr);
         end;

         if com = 'COUNTHIGH' then begin
            if opr = 'ON' then
               Log.CountHigherPoints := true;
            { for _bnd := b19 to HiBand do
              SubLog[_bnd].AcceptDifferentMode := True; }
         end;

         if com = 'WARC' then begin
            if opr = 'ON' then begin
               formMulti.WARC := True;
               MainForm.BandMenu.Items[ord(b10)].Visible := True;
               MainForm.BandMenu.Items[ord(b18)].Visible := True;
               MainForm.BandMenu.Items[ord(b24)].Visible := True;
            end
            else begin
               formMulti.WARC := False;
               MainForm.HideBandMenuWarc();
            end;
         end;
      end;
   end;

   System.close(zfile);
end;

procedure TGeneralScore.Update;
var
   band: TBand;
   TotQSO, TotPoints, TotMulti: LongInt;
   row: Integer;
begin
   TotQSO := 0;
   TotPoints := 0;
   TotMulti := 0;
   row := 1;

   Grid.Cells[0, 0] := 'MHz';
   Grid.Cells[1, 0] := 'QSOs';
   Grid.Cells[2, 0] := 'Points';
   Grid.Cells[3, 0] := 'Mult';

   if ShowCWRatio then begin
      Grid.Cells[4, 0] := 'CW QSOs';
      Grid.Cells[5, 0] := 'CW %';
   end
   else begin
      Grid.Cells[4, row] := '';
      Grid.Cells[5, row] := '';
   end;

   for band := b19 to HiBand do begin
      TotQSO := TotQSO + QSO[band];
      TotPoints := TotPoints + Points[band];
      TotMulti := TotMulti + Multi[band];

      if (MainForm.BandMenu.Items[Ord(band)].Visible = True) and
         (dmZlogGlobal.Settings._activebands[band] = True) then begin

         Grid.Cells[0, row] := '*' + MHzString[band];
         Grid.Cells[1, row] := IntToStr3(QSO[band]);
         Grid.Cells[2, row] := IntToStr3(Points[band]);

         if formMulti.NoMulti then begin
            Grid.Cells[3, row] := '-';
         end
         else begin
            Grid.Cells[3, row] := IntToStr3(Multi[band]);
         end;

         if ShowCWRatio then begin
            Grid.Cells[4, row] := IntToStr3(CWQSO[band]);
            if QSO[band] > 0 then begin
               Grid.Cells[5, row] := FloatToStrF(100 * (CWQSO[band] / QSO[band]), ffFixed, 1000, 1);
            end
            else begin
               Grid.Cells[5, row] := '-';
            end;
         end
         else begin
            Grid.Cells[4, row] := '';
            Grid.Cells[5, row] := '';
         end;

         Inc(row);
      end;
   end;

   Grid.Cells[0, row] := 'Total';
   Grid.Cells[1, row] := IntToStr3(TotQSO);
   Grid.Cells[2, row] := IntToStr3(TotPoints);
   if formMulti.NoMulti then begin
      Grid.Cells[3, row] := '-';
   end
   else begin
      Grid.Cells[3, row] := IntToStr(TotMulti);
   end;

   if ShowCWRatio then begin
      Grid.Cells[4, row] := IntToStr3(TotalCWQSOs);
      if TotQSO > 0 then begin
         Grid.Cells[5, row] := FloatToStrF(100 * (TotalCWQSOs / TotQSO), ffFixed, 1000, 1);
      end
      else begin
         Grid.Cells[5, row] := '-';
      end;
   end
   else begin
      Grid.Cells[4, row] := '';
      Grid.Cells[5, row] := '';
   end;
   Inc(row);

   Grid.Cells[0, row] := 'Score';
   Grid.Cells[1, row] := '';
   Grid.Cells[2, row] := '';
   if formMulti.NoMulti then begin
      Grid.Cells[3, row] := IntToStr3(TotPoints);
   end
   else begin
      Grid.Cells[3, row] := IntToStr3(TotPoints * TotMulti);
   end;
   Grid.Cells[4, row] := '';
   Grid.Cells[5, row] := '';
   Inc(row);

   Grid.RowCount := row;
   ClientWidth := (Grid.DefaultColWidth * Grid.ColCount) + (Grid.ColCount * Grid.GridLineWidth);
   ClientHeight := (Grid.DefaultRowHeight * Grid.RowCount) + (Grid.RowCount * Grid.GridLineWidth) + Panel1.Height + 4;
end;

procedure TGeneralScore.CalcPoints(var aQSO: TQSO);
var
   i: Integer;
   ch: AnsiChar;
   C: TCountry;
begin
   aQSO.QSO.Points := PointsTable[aQSO.QSO.band, aQSO.QSO.Mode];

   if formMulti._DXTEST then begin
      if SameCTYPoints or SameCONTPoints then begin
         i := aQSO.QSO.Power2;
         if (i < CountryList.List.Count) and (i >= 0) then begin
            C := TCountry(CountryList.List[i]);
            if SameCTYPoints and (C.Country = MyCountry) then
               aQSO.QSO.Points := SameCTYPointsTable[aQSO.QSO.band, aQSO.QSO.Mode]
            else if SameCONTPoints and (C.Continent = MyContinent) then
               aQSO.QSO.Points := SameCONTPointsTable[aQSO.QSO.band, aQSO.QSO.Mode];
         end;
      end;
   end;

   if formMulti.IsLocal(aQSO) then
      aQSO.QSO.Points := LocalPointsTable[aQSO.QSO.band, aQSO.QSO.Mode];

   if AlphabetPoints then begin
      aQSO.QSO.Points := 0;
      i := length(aQSO.QSO.NrRcvd);
      if i > 0 then begin
         ch := aQSO.QSO.NrRcvd[i];
         if ch in ['0' .. 'Z'] then
            aQSO.QSO.Points := AlphabetPointsTable[ord(ch)];
      end;
   end;

   if SpecialCalls <> '' then begin
      if pos(',' + aQSO.QSO.Callsign + ',', ',' + SpecialCalls + ',') > 0 then
         aQSO.QSO.Points := SpecialCallPointsTable[aQSO.QSO.band, aQSO.QSO.Mode];
   end;
end;

procedure TGeneralScore.AddNoUpdate(var aQSO: TQSO);
var
   i: Integer;
   tempQSO: TQSO;
begin
   inherited;

   if aQSO.QSO.Dupe then
      exit;

   CalcPoints(aQSO);

   if Log.CountHigherPoints = true then begin
      i := Log.DifferentModePointer;
      If i > 0 then begin
         if TQSO(Log.List[i]).QSO.Points < aQSO.QSO.Points then begin
            tempQSO := TQSO(Log.List[i]);
            Dec(Points[tempQSO.QSO.band], tempQSO.QSO.Points);
            TQSO(Log.List[i]).QSO.Points := 0;
            // NeedRefresh := True;
         end
         else
            aQSO.QSO.Points := 0;
      end;
   end;

   inc(Points[aQSO.QSO.band], aQSO.QSO.Points);
end;

procedure TGeneralScore.Reset;
begin
   inherited;
end;

procedure TGeneralScore.Add(var aQSO: TQSO);
begin
   inherited;
end;

procedure TGeneralScore.FormShow(Sender: TObject);
begin
   inherited;
   Button1.SetFocus;
   Grid.Col := 1;
   Grid.row := 1;
end;

procedure TGeneralScore.GridDrawCell(Sender: TObject; ACol, ARow: Integer; Rect: TRect; State: TGridDrawState);
var
   strText: string;
begin
   inherited;
   strText := TStringGrid(Sender).Cells[ACol, ARow];

   with TStringGrid(Sender).Canvas do begin
      Brush.Color := TStringGrid(Sender).Color;
      Brush.Style := bsSolid;
      FillRect(Rect);

      Font.Name := '�l�r �S�V�b�N';
      Font.Size := 11;

      if Copy(strText, 1, 1) = '*' then begin
         strText := Copy(strText, 2);
         Font.Color := clBlue;
      end
      else begin
         Font.Color := clBlack;
      end;

      TextRect(Rect, strText, [tfRight,tfVerticalCenter,tfSingleLine]);
   end;
end;

end.
