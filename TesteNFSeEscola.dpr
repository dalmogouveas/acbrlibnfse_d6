program TesteNFSeEscola;

uses
  Forms,
  uFrmTesteNFSeEscola in 'uFrmTesteNFSeEscola.pas' {FrmTesteNFSeEscola},
  uLogNFSe in 'uLogNFSe.pas',
  uACBrNFSeLib in 'uACBrNFSeLib.pas',
  uCertificadoHelper in 'uCertificadoHelper.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.Title := 'Teste de Emissão NFS-e Nacional - Escola';
  Application.CreateForm(TFrmTesteNFSeEscola, FrmTesteNFSeEscola);
  Application.Run;
end.
