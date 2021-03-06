unit UMenu;

interface

uses
   SysUtils, Windows, Messages, Classes, Graphics, Controls, StdCtrls, ExtCtrls,
   Forms, UITypes, Dialogs, Buttons, UzLogGlobal;

type
   TMenuForm = class(TForm)
      OKButton: TButton;
      CancelButton: TButton;
      Button3: TButton;
      ContestGroup: TGroupBox;
      OpGroup: TRadioGroup;
      BandGroup: TRadioGroup;
      rbALLJA: TRadioButton;
      rb6D: TRadioButton;
      rbFD: TRadioButton;
      rbACAG: TRadioButton;
      ModeGroup: TRadioGroup;
      editCallsign: TEdit;
      Label1: TLabel;
      OpenDialog: TOpenDialog;
      rbCQWW: TRadioButton;
      rbJIDXJA: TRadioButton;
      rbCQWPX: TRadioButton;
      rbPedi: TRadioButton;
      rbJIDXDX: TRadioButton;
      rbGeneral: TRadioButton;
      CFGOpenDialog: TOpenDialog;
      SelectButton: TSpeedButton;
      CheckBox1: TCheckBox;
      rbARRLDX: TRadioButton;
      rbARRLW: TRadioButton;
      rbAPSprint: TRadioButton;
      rbJA0in: TRadioButton;
      rbJA0out: TRadioButton;
      TXNrEdit: TEdit;
      Label2: TLabel;
      ScoreCoeffEdit: TEdit;
      Label3: TLabel;
      rbIARU: TRadioButton;
      rbAllAsian: TRadioButton;
      rbIOTA: TRadioButton;
      rbARRL10: TRadioButton;
      rbKCJ: TRadioButton;
      rbWAE: TRadioButton;
      procedure FormCreate(Sender: TObject);
      procedure FormShow(Sender: TObject);
      procedure rbCQWWClick(Sender: TObject);
      procedure rbGeneralEnter(Sender: TObject);
      procedure rbGeneralExit(Sender: TObject);
      procedure SelectButtonClick(Sender: TObject);
      procedure rbALLJAClick(Sender: TObject);
      procedure rbPediClick(Sender: TObject);
      procedure rbACAGClick(Sender: TObject);
      procedure rb6DClick(Sender: TObject);
      procedure rbFDClick(Sender: TObject);
      procedure rbJA0inClick(Sender: TObject);
      procedure rbARRLWClick(Sender: TObject);
      procedure rbAPSprintClick(Sender: TObject);
      procedure OpGroupClick(Sender: TObject);
      procedure TXNrEditKeyPress(Sender: TObject; var Key: Char);
      procedure UserDefClick(Sender: TObject);
      procedure rbIARUClick(Sender: TObject);
      procedure rbIOTAClick(Sender: TObject);
      procedure rbARRL10Click(Sender: TObject);
      procedure rbARRL10Exit(Sender: TObject);
      procedure FnugrySingleInstance1AlreadyRunning(Sender: TObject; hPrevInst, hPrevWnd: Integer);
      procedure FormKeyPress(Sender: TObject; var Key: Char);
      procedure rbKCJClick(Sender: TObject);
      procedure rbWAEClick(Sender: TObject);
   private
      FSelectContest: array[0..20] of TRadioButton;
      FBandTemp: Integer; // temporary storage for bandgroup.itemindex
      FCFGFileName: string;
      procedure EnableEveryThing;

      function GetOpGroupIndex(): Integer;
      function GetBandGroupIndex(): Integer;
      function GetModeGroupIndex(): Integer;
      function GetCallsign(): string;
      function GetContestNumber(): Integer;
      procedure SetContestNumber(v: Integer);
      function GetTxNumber(): Integer;
      function GetScoreCoeff(): Extended;
      function GetGeneralName(): string;
      function GetPostContest(): Boolean;
      procedure SelectFirstBand();
   public
      property CFGFileName: string read FCFGFileName;
      property OpGroupIndex: Integer read GetOpGroupIndex;
      property BandGroupIndex: Integer read GetBandGroupIndex;
      property ModeGroupIndex: Integer read GetModeGroupIndex;
      property Callsign: string read GetCallsign;
      property ContestNumber: Integer read GetContestNumber write SetContestNumber;
      property TxNumber: Integer read GetTxNumber;
      property ScoreCoeff: Extended read GetScoreCoeff;
      property GeneralName: string read GetGeneralName;
      property PostContest: Boolean read GetPostContest;
   end;

implementation

{$R *.DFM}

procedure TMenuForm.FormCreate(Sender: TObject);
begin
   FCFGFileName := '';
   FSelectContest[0] := rbALLJA;
   FSelectContest[1] := rb6D;
   FSelectContest[2] := rbFD;
   FSelectContest[3] := rbACAG;
   FSelectContest[4] := rbJA0in;
   FSelectContest[5] := rbJA0out;
   FSelectContest[6] := rbKCJ;
   FSelectContest[7] := rbJIDXDX;
   FSelectContest[8] := rbPedi;
   FSelectContest[9] := rbGeneral;
   FSelectContest[10] := rbCQWW;
   FSelectContest[11] := rbCQWPX;
   FSelectContest[12] := rbJIDXJA;
   FSelectContest[13] := rbAPSprint;
   FSelectContest[14] := rbARRLW;
   FSelectContest[15] := rbARRLDX;
   FSelectContest[16] := rbARRL10;
   FSelectContest[17] := rbIARU;
   FSelectContest[18] := rbAllAsian;
   FSelectContest[19] := rbIOTA;
   FSelectContest[20] := rbWAE;
end;

procedure TMenuForm.FormShow(Sender: TObject);
begin
   if dmZlogGlobal.Band = 0 then begin
      BandGroup.ItemIndex := 0;
   end
   else begin
      BandGroup.ItemIndex := OldBandOrd(TBand(dmZlogGlobal.Band - 1)) + 1;
   end;
   ModeGroup.ItemIndex := dmZlogGlobal.Mode;

   if dmZlogGlobal.MultiOp > 0 then begin
      OpGroup.ItemIndex := dmZlogGlobal.MultiOp;
      TXNrEdit.Enabled := True;
   end
   else begin
      OpGroup.ItemIndex := 0;
      TXNrEdit.Enabled := False;
   end;

   TXNrEdit.Text := IntToStr(dmZlogGlobal.TXNr);

   editCallsign.Text := dmZlogGlobal.MyCall;

   EnableEveryThing;

   ContestNumber := dmZlogGlobal.ContestMenuNo;

   if rbGeneral.Checked then begin
      SelectButton.Enabled := True;
   end;

   OpGroup.OnClick(Self); // enables or disables TXNrEdit
end;

procedure TMenuForm.rbCQWWClick(Sender: TObject);
begin
   if ModeGroup.ItemIndex in [0, 3] then begin
      ModeGroup.ItemIndex := 1;
   end;
end;

procedure TMenuForm.rbGeneralEnter(Sender: TObject);
begin
// SelectButton.Enabled := True;
end;

procedure TMenuForm.rbGeneralExit(Sender: TObject);
begin
   OKButton.Enabled := True;
end;

procedure TMenuForm.SelectButtonClick(Sender: TObject);
begin
   CFGOpenDialog.InitialDir := dmZlogGlobal.Settings._cfgdatpath;
   if CFGOpenDialog.Execute then begin
      FCFGFileName := CFGOpenDialog.FileName;

      rbGeneral.Caption := GetContestName(CFGFileName);
      if UsesCoeff(CFGFileName) then begin
         ScoreCoeffEdit.Enabled := True;
      end
      else begin
         ScoreCoeffEdit.Enabled := False;
      end;

      OKButton.Enabled := True;
   end;
end;

procedure TMenuForm.EnableEveryThing;
var
   i: Integer;
begin
   for i := 0 to BandGroup.Items.Count - 1 do begin
      BandGroup.Controls[i].Enabled := True;
   end;

   for i := 0 to OpGroup.Items.Count - 1 do begin
      OpGroup.Controls[i].Enabled := True;
   end;

   for i := 0 to ModeGroup.Items.Count - 1 do begin
      ModeGroup.Controls[i].Enabled := True;
   end;

   TXNrEdit.Enabled := True;
   OpGroup.OnClick(Self);
   SelectButton.Enabled := False;
   ScoreCoeffEdit.Enabled := False;
   OKButton.Enabled := True;
end;

procedure TMenuForm.rbALLJAClick(Sender: TObject);
var
   i: Integer;
begin
   EnableEveryThing;
   BandGroup.Controls[1].Enabled := False;
   for i := 8 to 13 do begin
      BandGroup.Controls[i].Enabled := False;
   end;

// ModeGroup.Controls[2].Enabled := False;
   ModeGroup.Controls[3].Enabled := False;

   SelectFirstBand();
end;

procedure TMenuForm.rbPediClick(Sender: TObject);
begin
   EnableEveryThing;
end;

procedure TMenuForm.rbACAGClick(Sender: TObject);
begin
   EnableEveryThing;
   BandGroup.Controls[1].Enabled := False;
// ModeGroup.Controls[2].Enabled := False;
   ModeGroup.Controls[3].Enabled := False;

   SelectFirstBand();
end;

procedure TMenuForm.rb6DClick(Sender: TObject);
var
   i: Integer;
begin
   EnableEveryThing;
   for i := 1 to 6 do begin
      BandGroup.Controls[i].Enabled := False;
   end;

// ModeGroup.Controls[2].Enabled := False;
   ModeGroup.Controls[3].Enabled := False;

   SelectFirstBand();
end;

procedure TMenuForm.rbFDClick(Sender: TObject);
begin
   EnableEveryThing;
   ScoreCoeffEdit.Enabled := True;
   BandGroup.Controls[1].Enabled := False;
// ModeGroup.Controls[2].Enabled := False;
   ModeGroup.Controls[3].Enabled := False;

   SelectFirstBand();
end;

procedure TMenuForm.rbJA0inClick(Sender: TObject);
var
   i: Integer;
begin
   EnableEveryThing;

   // ALL, 1.9M
   for i := 0 to 1 do begin
      BandGroup.Controls[i].Enabled := False;
   end;

   // 14M
   BandGroup.Controls[4].Enabled := False;

   // 50M and upper
   for i := 7 to 13 do begin
      BandGroup.Controls[i].Enabled := False;
   end;

   SelectFirstBand();

   ModeGroup.Controls[2].Enabled := False;
   ModeGroup.Controls[3].Enabled := False;
   OpGroup.Controls[1].Enabled := False;
   TXNrEdit.Enabled := False;
end;

procedure TMenuForm.rbARRLWClick(Sender: TObject);
var
   i: Integer;
begin
   EnableEveryThing;

   for i := 7 to 13 do begin
      BandGroup.Controls[i].Enabled := False;
   end;

   SelectFirstBand();

   ModeGroup.Controls[0].Enabled := False;
   ModeGroup.Controls[3].Enabled := False;
end;

procedure TMenuForm.rbAPSprintClick(Sender: TObject);
var
   i: Integer;
begin
   EnableEveryThing;

   for i := 1 to 13 do begin
      BandGroup.Controls[i].Enabled := False;
   end;

   SelectFirstBand();

   ModeGroup.Controls[0].Enabled := False;
   ModeGroup.Controls[3].Enabled := False;
   OpGroup.Controls[1].Enabled := False;
   TXNrEdit.Enabled := False;
end;

procedure TMenuForm.OpGroupClick(Sender: TObject);
begin
   if OpGroup.ItemIndex = 0 then begin
      TXNrEdit.Enabled := False;
   end
   else begin
      TXNrEdit.Enabled := True;
   end;
end;

procedure TMenuForm.TXNrEditKeyPress(Sender: TObject; var Key: Char);
begin
   if CharInSet(Key, ['0' .. '9']) = False then begin
      Key := #0;
   end;
end;

procedure TMenuForm.UserDefClick(Sender: TObject);
begin
   EnableEveryThing;
   if CFGFileName <> '' then begin
      if UsesCoeff(CFGFileName) then begin
         ScoreCoeffEdit.Enabled := True;
      end;
   end;

   if CFGFileName = '' then begin
      OKButton.Enabled := False;
   end;

   SelectButton.Enabled := True;
end;

procedure TMenuForm.rbIARUClick(Sender: TObject);
var
   i: Integer;
begin
   EnableEveryThing;

   for i := 7 to 13 do
      BandGroup.Controls[i].Enabled := False;

   ModeGroup.Controls[3].Enabled := False;
end;

procedure TMenuForm.rbIOTAClick(Sender: TObject);
var
   i: Integer;
begin
   EnableEveryThing;
   BandGroup.Controls[1].Enabled := False;

   for i := 7 to 13 do begin
      BandGroup.Controls[i].Enabled := False;
   end;

   ModeGroup.Controls[3].Enabled := False;
end;

procedure TMenuForm.rbARRL10Click(Sender: TObject);
var
   i: Integer;
begin
   EnableEveryThing;
   for i := 0 to 5 do begin
      BandGroup.Controls[i].Enabled := False;
   end;

   for i := 7 to 13 do begin
      BandGroup.Controls[i].Enabled := False;
   end;

   FBandTemp := BandGroup.ItemIndex;

   BandGroup.ItemIndex := 6;
   ModeGroup.Controls[3].Enabled := False;
end;

procedure TMenuForm.rbARRL10Exit(Sender: TObject);
begin
   BandGroup.ItemIndex := FBandTemp;
end;

procedure TMenuForm.FnugrySingleInstance1AlreadyRunning(Sender: TObject; hPrevInst, hPrevWnd: Integer);
begin
   Close;
end;

procedure TMenuForm.FormKeyPress(Sender: TObject; var Key: Char);
begin
   if Key = ^X then rbKCJ.Visible := True;
   if Key = ^T then rbKCJ.Visible := True;
end;

procedure TMenuForm.rbKCJClick(Sender: TObject);
var i: Integer;
begin
   EnableEveryThing;
   for i := 8 to 13 do
      BandGroup.Controls[i].Enabled := False;

   ModeGroup.Controls[0].Enabled := False;
   ModeGroup.Controls[2].Enabled := False;
   ModeGroup.Controls[3].Enabled := False;
   OpGroup.Controls[1].Enabled := False;
   OpGroup.Controls[2].Enabled := False;
end;

procedure TMenuForm.rbWAEClick(Sender: TObject);
var i: Integer;
begin
   EnableEveryThing;
   BandGroup.Controls[1].Enabled := False;

   for i := 7 to 13 do
      BandGroup.Controls[i].Enabled := False;

   ModeGroup.Controls[0].Enabled := False;
   ModeGroup.Controls[3].Enabled := False;
end;

function TMenuForm.GetOpGroupIndex(): Integer;
begin
   Result := OpGroup.ItemIndex;
end;

// WARCバンドを考慮した番号を返す
// ALL:0  → 0
// 1.9:1     1
// 3.5:2     2
// 7  :3     3
// 10M:      4
// 14 :4     5  +1
// 18 :      6
// 21 :5     7  +2
// 24 :      8
// 28 :6     9  +3
// 50 :7     10
function TMenuForm.GetBandGroupIndex(): Integer;
begin
   case BandGroup.ItemIndex of
      0 .. 3:  Result := BandGroup.ItemIndex;
      4:       Result := BandGroup.ItemIndex + 1;
      5:       Result := BandGroup.ItemIndex + 2;
      6 .. 13: Result := BandGroup.ItemIndex + 3;
      else     Result := BandGroup.ItemIndex;
   end;
end;

function TMenuForm.GetModeGroupIndex(): Integer;
begin
   Result := ModeGroup.ItemIndex;
end;

function TMenuForm.GetCallsign(): string;
begin
   Result := editCallsign.Text;
end;

function TMenuForm.GetContestNumber(): Integer;
var
   i: Integer;
begin
   for i := Low(FSelectContest) to High(FSelectContest) do begin
      if TRadioButton(FSelectContest[i]).Checked then begin
         Result := i;
         Exit;
      end;
   end;
   Result := -1;
end;

procedure TMenuForm.SetContestNumber(v: Integer);
begin
   TRadioButton(FSelectContest[v]).Checked := True;
end;

function TMenuForm.GetTxNumber(): Integer;
begin
   Result := StrToIntDef(TXNrEdit.Text, 0);
end;

function TMenuForm.GetScoreCoeff(): Extended;
var
   E: Extended;
begin
   if ScoreCoeffEdit.Enabled then begin
      E := StrToFloatDef(ScoreCoeffEdit.Text, 1);
   end
   else begin
      E := 0;
   end;

   Result := E;
end;

function TMenuForm.GetGeneralName(): string;
begin
   Result := rbGeneral.Caption;
end;

function TMenuForm.GetPostContest(): Boolean;
begin
   Result := CheckBox1.Checked;
end;

procedure TMenuForm.SelectFirstBand();
var
   i: Integer;
begin
   for i := 0 to BandGroup.Items.Count - 1 do begin
      if BandGroup.Controls[i].Enabled = True then begin
         BandGroup.ItemIndex := i;
         Exit;
      end;
   end;
end;

end.
