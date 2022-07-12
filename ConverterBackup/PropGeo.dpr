program PropGeo;

uses
  Forms,
  Unit1 in 'Unit1.pas' {Form1},
  Polig in 'Polig.pas',
  UAbout in 'UAbout.pas' {frmAbout};

{$R *.res}

begin
  Application.Initialize;
  Application.Title := 'Propriedade Geometricas';
  Application.CreateForm(TForm1, Form1);
  Application.CreateForm(TfrmAbout, frmAbout);
  Application.Run;
end.
