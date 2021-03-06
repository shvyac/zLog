unit UWAEScore;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  UBasicScore, Grids, StdCtrls, Buttons, ExtCtrls, UzLogGlobal;

const
  BandFactor : array[b19..b28] of integer =
           (0, 4, 3, 0, 2, 0, 2, 0, 2);    // multi bonus factor

type
  TWAEScore = class(TBasicScore)
    Grid: TStringGrid;
    procedure GridDrawCell(Sender: TObject; ACol, ARow: Integer; Rect: TRect; State: TGridDrawState);
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
    QTCs : array[b19..b28] of integer;
  public
    procedure Reset; override;
    procedure Renew; override;
    procedure AddNoUpdate(var aQSO : TQSO);  override;
    procedure Update; override;
    procedure SummaryWriteScore(FileName : string); override;
  end;

implementation

{$R *.DFM}

procedure TWAEScore.Reset;
var
   B: TBand;
begin
   inherited;
   for B := b19 to b28 do begin
      QTCs[B] := 0;
   end;
end;

procedure TWAEScore.Renew;
var
   i: word;
   band: TBand;
begin
   Reset;
   for i := 1 to Log.TotalQSO do begin
      band := TQSO(Log.List[i]).QSO.band;
      Inc(QSO[band]);
      Inc(Points[band], TQSO(Log.List[i]).QSO.Points);

      if TQSO(Log.List[i]).QSO.NewMulti1 then begin
         Inc(Multi[band]);
      end;
      if pos('[QTC', TQSO(Log.List[i]).QSO.Memo) > 0 then begin
         Inc(QTCs[band]);
      end;
   end;
end;

procedure TWAEScore.AddNoUpdate(var aQSO: TQSO);
var
   band: TBand;
begin
   inherited;

   if aQSO.QSO.Dupe then begin
      Exit;
   end;

   if aQSO.QSO.Multi1 = 'Non-EU' then begin
      Exit;
   end;

   band := aQSO.QSO.band;
   aQSO.QSO.Points := 1;
   Inc(Points[band]);

   if pos('[QTC', aQSO.QSO.Memo) > 0 then begin
      Inc(QTCs[band]);
   end;
end;

procedure TWAEScore.Update;
var
   band: TBand;
   TotQSO, TotMulti, TotQTCs: LongInt;
   row: integer;
begin
   TotQSO := 0;
   TotMulti := 0;
   TotQTCs := 0;
   row := 1;

   // ���o���s
   Grid.Cells[0,0] := 'MHz';
   Grid.Cells[1,0] := 'QSOs';
   Grid.Cells[2,0] := 'Points';
   Grid.Cells[3,0] := 'Multi';

   for band := b35 to b28 do begin
      if NotWARC(band) then begin
         TotQSO := TotQSO + QSO[band];
         TotQTCs := TotQTCs + QTCs[band];
         TotMulti := TotMulti + BandFactor[band] * Multi[band];

         Grid.Cells[0, row] := '*' + MHzString[band];
         Grid.Cells[1, row] := IntToStr3(QSO[band]);
         Grid.Cells[2, row] := IntToStr3(QTCs[band]);
         Grid.Cells[3, row] := IntToStr3(BandFactor[band] * Multi[band]);

         Inc(row);
      end;
   end;

   Grid.Cells[0, 6] := 'Total';
   Grid.Cells[1, 6] := IntToStr3(TotQSO);
   Grid.Cells[2, 6] := IntToStr3(TotQTCs);
   Grid.Cells[3, 6] := IntToStr3(TotMulti);

   Grid.Cells[0, 7] := 'Score';
   Grid.Cells[1, 7] := '';
   Grid.Cells[2, 7] := '';
   Grid.Cells[3, 7] := IntToStr3((TotQSO + TotQTCs) * TotMulti);

   Grid.ColCount := 4;
   Grid.RowCount := 8;
   ClientWidth := (Grid.DefaultColWidth * Grid.ColCount) + (Grid.ColCount * Grid.GridLineWidth);
   ClientHeight := (Grid.DefaultRowHeight * Grid.RowCount) + (Grid.RowCount * Grid.GridLineWidth) + Panel1.Height + 4;
end;

procedure TWAEScore.SummaryWriteScore(FileName: string);
var
   f: textfile;
   TQSO, tmulti, tqtc: LongInt;
   B: TBand;
begin
   TQSO := 0;
   tqtc := 0;
   tmulti := 0;

   AssignFile(f, FileName);
   Append(f);
   writeln(f, 'MHz           QSOs     QTCs    Mult(*bonus)');

   for B := b35 to b28 do begin
      if NotWARC(B) then begin
         writeln(f, FillRight(MHzString[B], 8) + FillLeft(IntToStr(QSO[B]), 10) + FillLeft(IntToStr(QTCs[B]), 10) +
           FillLeft(IntToStr(Multi[B] * BandFactor[B]), 10));
         TQSO := TQSO + QSO[B];
         tqtc := tqtc + QTCs[B];
         tmulti := tmulti + Multi[B] * BandFactor[B];
      end;
   end;

   writeln(f, FillRight('Total :', 8) + FillLeft(IntToStr(TQSO), 10) + FillLeft(IntToStr(tqtc), 10) + FillLeft(IntToStr(tmulti), 10));
   writeln(f, 'Total score : ' + IntToStr((TQSO + tqtc) * tmulti));

   CloseFile(f);
end;

procedure TWAEScore.FormShow(Sender: TObject);
begin
   inherited;
   Button1.SetFocus;
   Grid.Col := 1;
   Grid.Row := 1;
end;

procedure TWAEScore.GridDrawCell(Sender: TObject; ACol, ARow: Integer; Rect: TRect; State: TGridDrawState);
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
