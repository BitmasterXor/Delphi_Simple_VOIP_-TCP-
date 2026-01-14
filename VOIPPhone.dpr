program VOIPPhone;

uses
  Vcl.Forms,
  uMain in 'uMain.pas' {frmVOIP},
  Vcl.Themes,
  Vcl.Styles;

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  TStyleManager.TrySetStyle('Cobalt XEMedia');
  Application.CreateForm(TfrmVOIP, frmVOIP);
  Application.Run;
end.
