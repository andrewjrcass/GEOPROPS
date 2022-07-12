unit UAbout;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, Buttons, JvExStdCtrls, JvBehaviorLabel;

type
  TfrmAbout = class(TForm)
    BitBtn1: TBitBtn;
    jvLabel: TJvBehaviorLabel;
    procedure FormShow(Sender: TObject);
    procedure BitBtn1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmAbout: TfrmAbout;

implementation

{$R *.dfm}

procedure TfrmAbout.FormShow(Sender: TObject);
begin
  jvLabel.BehaviorOptions.Active:= True;
end;

procedure TfrmAbout.BitBtn1Click(Sender: TObject);
begin
jvLabel.BehaviorOptions.Active:= False;
end;

end.
