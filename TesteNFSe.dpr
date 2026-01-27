program TesteNFSe;

uses
  Forms,
  uFrmTesteNFSe in 'uFrmTesteNFSe.pas' {FrmTesteNFSe},
  uACBrNFSeLib in 'uACBrNFSeLib.pas',
  uTesteRapidoNFSe in 'uTesteRapidoNFSe.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TFrmTesteNFSe, FrmTesteNFSe);
  Application.Run;
end.
