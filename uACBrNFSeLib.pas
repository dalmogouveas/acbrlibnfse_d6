unit uACBrNFSeLib;

interface

uses
  Windows, SysUtils;

// IMPORTANT:
// - Estas declaracoes DEVEM bater com a DLL (ACBrNFSe32.dll) que voce esta usando.
// - Alinhado com o DEMO oficial VB6 do ACBrLibNFSe (build StdCall).
// - Divergencias aqui causam corrupcao de pilha (AV) mesmo quando o retorno parece OK.

type
  // Basico
  TACBrNFSe_Inicializar = function(const eArqConfig, eChaveCrypt: PAnsiChar): Integer; stdcall;
  TACBrNFSe_Finalizar   = function: Integer; stdcall;
  TACBrNFSe_Nome        = function(const buffer: PAnsiChar; var bufferLen: Integer): Integer; stdcall;
  TACBrNFSe_Versao      = function(const buffer: PAnsiChar; var bufferLen: Integer): Integer; stdcall;
  TACBrNFSe_UltimoRetorno = function(const buffer: PAnsiChar; var bufferLen: Integer): Integer; stdcall;

  // Configuracao
  TACBrNFSe_ConfigImportar = function(const eArqConfig: PAnsiChar): Integer; stdcall;
  TACBrNFSe_ConfigExportar = function(const buffer: PAnsiChar; var bufferLen: Integer): Integer; stdcall;
  TACBrNFSe_ConfigLer      = function(const eArqConfig: PAnsiChar): Integer; stdcall;
  TACBrNFSe_ConfigGravar   = function(const eArqConfig: PAnsiChar): Integer; stdcall;
  TACBrNFSe_ConfigLerValor = function(const eSessao, eChave: PAnsiChar; const buffer: PAnsiChar; var bufferLen: Integer): Integer; stdcall;
  TACBrNFSe_ConfigGravarValor = function(const eSessao, eChave, eValor: PAnsiChar): Integer; stdcall;

  // Documentos (carregamento)
  TNFSe_CarregarXML     = function(const eArquivoOuXml: PAnsiChar): Integer; stdcall;
  TNFSe_CarregarLoteXML = function(const eArquivoOuXml: PAnsiChar): Integer; stdcall;
  TNFSe_CarregarINI     = function(const eArquivoOuIni: PAnsiChar): Integer; stdcall;
  TNFSe_LimparLista     = function: Integer; stdcall;

  // Operacoes
  TNFSe_Emitir = function(const aLote: PAnsiChar; aModoEnvio: Integer; aImprimir: Integer;
                          const buffer: PAnsiChar; var bufferLen: Integer): Integer; stdcall;

  TNFSe_ConsultarSituacao = function(const aProtocolo, aNumeroLote: PAnsiChar;
                                     const buffer: PAnsiChar; var bufferLen: Integer): Integer; stdcall;

var
  // Basico
  NFSE_Inicializar: TACBrNFSe_Inicializar;
  NFSE_Finalizar: TACBrNFSe_Finalizar;
  NFSE_Nome: TACBrNFSe_Nome;
  NFSE_Versao: TACBrNFSe_Versao;
  NFSE_UltimoRetorno: TACBrNFSe_UltimoRetorno;

  // Configuracao
  NFSE_ConfigImportar: TACBrNFSe_ConfigImportar;
  NFSE_ConfigExportar: TACBrNFSe_ConfigExportar;
  NFSE_ConfigLer: TACBrNFSe_ConfigLer;
  NFSE_ConfigGravar: TACBrNFSe_ConfigGravar;
  NFSE_ConfigGravarValor: TACBrNFSe_ConfigGravarValor;
  NFSE_ConfigLerValor: TACBrNFSe_ConfigLerValor;

  // Documentos
  NFSE_CarregarXML: TNFSe_CarregarXML;
  NFSE_CarregarLoteXML: TNFSe_CarregarLoteXML;
  NFSE_CarregarINI: TNFSe_CarregarINI;
  NFSE_LimparLista: TNFSe_LimparLista;

  // Operacoes
  NFSE_Emitir: TNFSe_Emitir;
  NFSE_ConsultarSituacao: TNFSe_ConsultarSituacao;

function CarregarACBrNFSe(const ADllPath: string): Boolean;
procedure DescarregarACBrNFSe;

implementation

var
  hLib: THandle = 0;

function GetProc(const AName: PChar): Pointer;
begin
  if hLib = 0 then
    Result := nil
  else
    Result := GetProcAddress(hLib, AName);
end;

function CarregarACBrNFSe(const ADllPath: string): Boolean;
begin
  Result := False;

  if hLib <> 0 then
  begin
    Result := True;
    Exit;
  end;

  hLib := LoadLibrary(PChar(ADllPath));
  if hLib = 0 then
    Exit;

  // Basico
  @NFSE_Inicializar   := GetProc('NFSE_Inicializar');
  @NFSE_Finalizar     := GetProc('NFSE_Finalizar');
  @NFSE_Nome          := GetProc('NFSE_Nome');
  @NFSE_Versao        := GetProc('NFSE_Versao');
  @NFSE_UltimoRetorno := GetProc('NFSE_UltimoRetorno');

  // Config
  @NFSE_ConfigImportar    := GetProc('NFSE_ConfigImportar');
  @NFSE_ConfigExportar    := GetProc('NFSE_ConfigExportar');
  @NFSE_ConfigLer         := GetProc('NFSE_ConfigLer');
  @NFSE_ConfigGravar      := GetProc('NFSE_ConfigGravar');
  @NFSE_ConfigLerValor    := GetProc('NFSE_ConfigLerValor');
  @NFSE_ConfigGravarValor := GetProc('NFSE_ConfigGravarValor');

  // Documentos
  @NFSE_CarregarXML       := GetProc('NFSE_CarregarXML');
  @NFSE_CarregarLoteXML   := GetProc('NFSE_CarregarLoteXML');
  @NFSE_CarregarINI       := GetProc('NFSE_CarregarINI');
  @NFSE_LimparLista       := GetProc('NFSE_LimparLista');

  // Operacoes
  @NFSE_Emitir            := GetProc('NFSE_Emitir');
  @NFSE_ConsultarSituacao := GetProc('NFSE_ConsultarSituacao');

  Result :=
    Assigned(NFSE_Inicializar) and
    Assigned(NFSE_Finalizar) and
    Assigned(NFSE_Nome) and
    Assigned(NFSE_Versao) and
    Assigned(NFSE_UltimoRetorno) and
    Assigned(NFSE_ConfigImportar) and
    Assigned(NFSE_ConfigExportar) and
    Assigned(NFSE_ConfigLerValor) and
    Assigned(NFSE_ConfigGravarValor) and
    Assigned(NFSE_CarregarXML) and
    Assigned(NFSE_CarregarINI) and
    Assigned(NFSE_LimparLista) and
    Assigned(NFSE_Emitir) and
    Assigned(NFSE_ConsultarSituacao);

  if not Result then
    DescarregarACBrNFSe;
end;

procedure DescarregarACBrNFSe;
begin
  if hLib <> 0 then
  begin
    FreeLibrary(hLib);
    hLib := 0;
  end;

  // Basico
  NFSE_Inicializar := nil;
  NFSE_Finalizar := nil;
  NFSE_Nome := nil;
  NFSE_Versao := nil;
  NFSE_UltimoRetorno := nil;

  // Config
  NFSE_ConfigImportar := nil;
  NFSE_ConfigExportar := nil;
  NFSE_ConfigLer := nil;
  NFSE_ConfigGravar := nil;
  NFSE_ConfigGravarValor := nil;
  NFSE_ConfigLerValor := nil;

  // Docs
  NFSE_CarregarXML := nil;
  NFSE_CarregarLoteXML := nil;
  NFSE_CarregarINI := nil;
  NFSE_LimparLista := nil;

  // Ops
  NFSE_Emitir := nil;
  NFSE_ConsultarSituacao := nil;
end;

end.
