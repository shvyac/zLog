unit UZlinkTelnetSet;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls, Spin;

type
  TformZLinkTelnetSet = class(TForm)
    Bevel1: TBevel;
    Label1: TLabel;
    Label2: TLabel;
    buttonOK: TButton;
    buttonCancel: TButton;
    comboHostName: TComboBox;
    comboLineBreak: TComboBox;
    checkLocalEcho: TCheckBox;
  private
    { Private declarations }
    function GetHostName(): string;
    procedure SetHostName(v: string);
    function GetLineBreak(): Integer;
    procedure SetLineBreak(v: Integer);
    function GetLocalEcho(): Boolean;
    procedure SetLocalEcho(v: Boolean);
  public
    { Public declarations }
    property HostName: string read GetHostName write SetHostName;
    property LineBreak: Integer read GetLineBreak write SetLineBreak;
    property LocalEcho: Boolean read GetLocalEcho write SetLocalEcho;
  end;

implementation

{$R *.DFM}

function TformZLinkTelnetSet.GetHostName(): string;
begin
   Result := comboHostName.Text;
end;

procedure TformZLinkTelnetSet.SetHostName(v: string);
begin
   comboHostName.Text := v;
end;

function TformZLinkTelnetSet.GetLineBreak(): Integer;
begin
   Result := comboLineBreak.ItemIndex;
end;

procedure TformZLinkTelnetSet.SetLineBreak(v: Integer);
begin
   comboLineBreak.ItemIndex := v;
end;

function TformZLinkTelnetSet.GetLocalEcho(): Boolean;
begin
   Result := checkLocalEcho.Checked;
end;

procedure TformZLinkTelnetSet.SetLocalEcho(v: Boolean);
begin
   checkLocalEcho.Checked := v;
end;

end.
