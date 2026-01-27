unit uFrmTesteNFSe;

interface

uses
  Windows, SysUtils, Classes, Forms, Controls, StdCtrls,
  uACBrNFSeLib, ExtCtrls, Dialogs;

type
  TFrmTesteNFSe = class(TForm)
    btnInicializar: TButton;
    btnNome: TButton;
    btnVersao: TButton;
    MemoLog: TMemo;
    Panel2: TPanel;
    btnConsultarSituacao: TButton;
    btnCarregarXML: TButton;
    btnEmitir: TButton;
    GroupCert: TGroupBox;
    rbCertWinStore: TRadioButton;
    rbCertPFX: TRadioButton;
    lblPFXPath: TLabel;
    edtPFXPath: TEdit;
    lblPFXSenha: TLabel;
    edtPFXSenha: TEdit;
    lblCertSerie: TLabel;
    edtCertSerie: TEdit;
    btnAplicarCert: TButton;
    btnCarregarINI: TButton;
    btnCarregarXMLTeste: TButton;
    Od: TOpenDialog;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure btnInicializarClick(Sender: TObject);
    procedure btnNomeClick(Sender: TObject);
    procedure btnVersaoClick(Sender: TObject);
    procedure btnConsultarSituacaoClick(Sender: TObject);
    procedure btnCarregarXMLClick(Sender: TObject);
    procedure btnEmitirClick(Sender: TObject);
    procedure btnAplicarCertClick(Sender: TObject);
    procedure MemoLogKeyUp(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure btnCarregarINIClick(Sender: TObject);
    procedure btnCarregarXMLTesteClick(Sender: TObject);
  private
    FUltimaResposta: AnsiString;

    function GetLibString(Func: Pointer): string;

    // Chamadas que retornam texto via (buffer, bufferLen).
    // - Retorna o codigo retornado pela DLL.
    // - AOut recebe o texto retornado (se houver).
    function CallWithBuffer(Func: Pointer; const AArg1, AArg2: AnsiString; out AOut: AnsiString): Integer;
    function CallWithBuffer3(Func: Pointer; const AArg1: AnsiString; AArgInt1, AArgInt2: Integer; out AOut: AnsiString): Integer;

    function CallUltimoRetorno: string;

    function ACBrGetConfigValue(const Sessao, Chave: AnsiString): AnsiString;
    procedure ACBrSetConfigValue(const Sessao, Chave, Valor: AnsiString);
    procedure ConfigurarPathsBasicos;
    procedure ConfigurarCertificado;

    procedure habilitarBotoes(valor: boolean);
  end;

var
  FrmTesteNFSe: TFrmTesteNFSe;

implementation

{$R *.DFM}

uses uTesteRapidoNFSe;

procedure AddPath(const APath: string);
var
  Buffer: array[0..32767] of Char;
  CurrentPath: string;
begin
  GetEnvironmentVariable('PATH', Buffer, SizeOf(Buffer));
  CurrentPath := Buffer;

  if Pos(UpperCase(APath), UpperCase(CurrentPath)) = 0 then
    SetEnvironmentVariable('PATH', PChar(APath + ';' + CurrentPath));
end;

function TFrmTesteNFSe.CallUltimoRetorno: string;
var
  BufferLen: Integer;
  Buffer: PAnsiChar;
begin
  Result := '';
  if not Assigned(NFSE_UltimoRetorno) then
    Exit;

  BufferLen := 0;
  NFSE_UltimoRetorno(nil, BufferLen);
  if BufferLen <= 0 then
    Exit;

  GetMem(Buffer, BufferLen);
  try
    FillChar(Buffer^, BufferLen, 0);
    if NFSE_UltimoRetorno(Buffer, BufferLen) = 0 then
      Result := string(AnsiString(Buffer));
  finally
    FreeMem(Buffer);
  end;
end;

procedure TFrmTesteNFSe.FormCreate(Sender: TObject);
var
  BaseDir: string;
begin
  BaseDir := ExtractFilePath(Application.ExeName);

  AddPath(BaseDir + 'acbr');
  AddPath(BaseDir + 'acbr\libxml2');
  AddPath(BaseDir + 'acbr\openssl');

  if not CarregarACBrNFSe(BaseDir + 'acbr\ACBrNFSe32.dll') then begin
    btnInicializar.Enabled := False;
    MemoLog.Lines.Add('Erro ao carregar ACBrNFSe32.dll')
  end else begin
    btnInicializar.Enabled := True;
    MemoLog.Lines.Add('DLL carregada com sucesso');
  end;

  // Padrão - Windows Store
  if Assigned(rbCertWinStore)
    then rbCertWinStore.Checked := True;

  // Interface desabilitada  
  habilitarBotoes(False);    
end;

procedure TFrmTesteNFSe.FormDestroy(Sender: TObject);
begin
  if Assigned(NFSE_Finalizar)
    then NFSE_Finalizar;

  DescarregarACBrNFSe;
end;

procedure TFrmTesteNFSe.btnInicializarClick(Sender: TObject);
var
  IniPath: string;
  Ret: Integer;
begin
  IniPath := ExtractFilePath(Application.ExeName) +
             'acbr\config\acbrnfse.ini';

  ForceDirectories(ExtractFilePath(IniPath));

  Ret := NFSE_Inicializar(PAnsiChar(AnsiString(IniPath)), nil);
  MemoLog.Lines.Add('Inicializar retorno: ' + IntToStr(Ret));

  if Ret <> 0 then Exit;

  Ret := NFSE_ConfigImportar(PAnsiChar(AnsiString(IniPath)));
  MemoLog.Lines.Add('ConfigImportar retorno: ' + IntToStr(Ret));

  if Ret = 0 then
    ConfigurarPathsBasicos;

  habilitarBotoes(True);
end;

function TFrmTesteNFSe.GetLibString(Func: Pointer): string;
type
  TACBrGetStringFunc = function(
    const buffer: PAnsiChar;
    var bufferLen: Integer
  ): Integer; stdcall;
var
  BufferLen: Integer;
  Buffer: PAnsiChar;
  GetFunc: TACBrGetStringFunc;
  Ret: Integer;
begin
  Result := '';
  if not Assigned(Func) then
    Exit;

  GetFunc := TACBrGetStringFunc(Func);

  // Tamanho inicial seguro
  BufferLen := 256;

  GetMem(Buffer, BufferLen);
  try
    FillChar(Buffer^, BufferLen, 0);
    Ret := GetFunc(Buffer, BufferLen);

    // Se o buffer foi pequeno, a lib ajusta BufferLen
    if BufferLen > 256 then begin
      FreeMem(Buffer);
      GetMem(Buffer, BufferLen);
      FillChar(Buffer^, BufferLen, 0);
      Ret := GetFunc(Buffer, BufferLen);
    end;

    Result := string(Buffer);
  finally
    FreeMem(Buffer);
  end;
end;

function TFrmTesteNFSe.CallWithBuffer(Func: Pointer; const AArg1, AArg2: AnsiString; out AOut: AnsiString): Integer;
type
  TFunc2 = function(const a1, a2: PAnsiChar; const buffer: PAnsiChar; var bufferLen: Integer): Integer; stdcall;
var
  F: TFunc2;
  BufferLen: Integer;
  Buffer: PAnsiChar;
begin
  AOut := '';
  Result := -9999;
  if not Assigned(Func) then
    Exit;

  F := TFunc2(Func);
  BufferLen := 1024;
  GetMem(Buffer, BufferLen);
  try
    FillChar(Buffer^, BufferLen, 0);
    Result := F(PAnsiChar(AArg1), PAnsiChar(AArg2), Buffer, BufferLen);
    if BufferLen > 1024 then
    begin
      FreeMem(Buffer);
      GetMem(Buffer, BufferLen);
      FillChar(Buffer^, BufferLen, 0);
      Result := F(PAnsiChar(AArg1), PAnsiChar(AArg2), Buffer, BufferLen);
    end;
    AOut := AnsiString(Buffer);
  finally
    FreeMem(Buffer);
  end;
end;

function TFrmTesteNFSe.CallWithBuffer3(Func: Pointer; const AArg1: AnsiString; AArgInt1, AArgInt2: Integer; out AOut: AnsiString): Integer;
type
  TFunc3 = function(const a1: PAnsiChar; aInt1, aInt2: Integer; const buffer: PAnsiChar; var bufferLen: Integer): Integer; stdcall;
var
  F: TFunc3;
  BufferLen: Integer;
  Buffer: PAnsiChar;
begin
  AOut := '';
  Result := -9999;
  if not Assigned(Func) then
    Exit;

  F := TFunc3(Func);
  BufferLen := 4096;
  GetMem(Buffer, BufferLen);
  try
    FillChar(Buffer^, BufferLen, 0);
    Result := F(PAnsiChar(AArg1), AArgInt1, AArgInt2, Buffer, BufferLen);
    if BufferLen > 4096 then
    begin
      FreeMem(Buffer);
      GetMem(Buffer, BufferLen);
      FillChar(Buffer^, BufferLen, 0);
      Result := F(PAnsiChar(AArg1), AArgInt1, AArgInt2, Buffer, BufferLen);
    end;
    AOut := AnsiString(Buffer);
  finally
    FreeMem(Buffer);
  end;
end;

procedure TFrmTesteNFSe.btnNomeClick(Sender: TObject);
begin
  MemoLog.Lines.Add('Nome: ' + GetLibString(@NFSE_Nome));
end;

procedure TFrmTesteNFSe.btnVersaoClick(Sender: TObject);
begin
  MemoLog.Lines.Add('Versão: ' + GetLibString(@NFSE_Versao));
end;

function TFrmTesteNFSe.ACBrGetConfigValue(const Sessao, Chave: AnsiString): AnsiString;
type
  TACBrGetCfgFunc = function(
    const eSessao, eChave: PAnsiChar;
    const buffer: PAnsiChar;
    var bufferLen: Integer
  ): Integer; stdcall;
var
  BufferLen: Integer;
  Buffer: PAnsiChar;
  Ret: Integer;
  F: TACBrGetCfgFunc;
begin
  Result := '';
  if not Assigned(NFSE_ConfigLerValor) then
    Exit;

  F := TACBrGetCfgFunc(@NFSE_ConfigLerValor);

  BufferLen := 256;
  GetMem(Buffer, BufferLen);
  try
    FillChar(Buffer^, BufferLen, 0);
    Ret := F(PAnsiChar(Sessao), PAnsiChar(Chave), Buffer, BufferLen);

    // Se a lib ajustou o tamanho para algo maior, realoca e tenta novamente
    if BufferLen > 256 then begin
      FreeMem(Buffer);
      GetMem(Buffer, BufferLen);
      FillChar(Buffer^, BufferLen, 0);
      Ret := F(PAnsiChar(Sessao), PAnsiChar(Chave), Buffer, BufferLen);
    end;

    // Mesmo que Ret <> 0, verifica se devolveu em UltimoRetorno.
    Result := AnsiString(Buffer);
  finally
    FreeMem(Buffer);
  end;
end;

procedure TFrmTesteNFSe.ACBrSetConfigValue(const Sessao, Chave, Valor: AnsiString);
var
  Ret: Integer;
begin
  if not Assigned(NFSE_ConfigGravarValor) then
    raise Exception.Create('NFSE_ConfigGravarValor não está¡ carregada.');

  Ret := NFSE_ConfigGravarValor(PAnsiChar(Sessao), PAnsiChar(Chave), PAnsiChar(Valor));
  MemoLog.Lines.Add(Format('ConfigGravarValor [%s/%s] = "%s" | Ret=%d', [string(Sessao), string(Chave), string(Valor), Ret]));
end;

procedure TFrmTesteNFSe.ConfigurarPathsBasicos;
var
  BaseDir, PathSchemas, PathSalvar, PathLogLib, IniServicos: string;
begin
  BaseDir := ExtractFilePath(Application.ExeName);

  // Proposta de Estrutura de Diretórios (a partir do EXE)
  PathSchemas := BaseDir + 'acbr\schemas\NFSe\';
  PathSalvar  := BaseDir + 'log\';
  IniServicos := BaseDir + 'acbr\ACBrNFSeXServicosRTC.ini';
  PathLogLib  := BaseDir + 'log\'; // log da própria lib (Principal/LogPath)

  ForceDirectories(PathSchemas);
  ForceDirectories(PathSalvar);

  // 1) Log da LIB (seção Principal)
  ACBrSetConfigValue('Principal', 'LogPath', AnsiString(PathLogLib));

  // 2) NFSe: paths corretos (seção NFSe)
  ACBrSetConfigValue('NFSe', 'PathSchemas', AnsiString(PathSchemas));
  ACBrSetConfigValue('NFSe', 'PathSalvar',  AnsiString(PathSalvar));
  ACBrSetConfigValue('NFSe', 'IniServicos', AnsiString(IniServicos));

  // 3) Emissor Nacional (Padrão Nacional)
  // Conforme exemplo oficial VB6: 0=Provedor, 1=Padrão Nacional
  ACBrSetConfigValue('NFSe', 'LayoutNFSe', '1');

  // 4) Homologação (mantém seguro para testes)
  ACBrSetConfigValue('NFSe', 'Ambiente', '2');

  MemoLog.Lines.Add('--- Leitura de volta (ConfigLerValor) ---');
  MemoLog.Lines.Add('Principal/LogPath   = ' + string(ACBrGetConfigValue('Principal', 'LogPath')));
  MemoLog.Lines.Add('NFSe/PathSchemas    = ' + string(ACBrGetConfigValue('NFSe', 'PathSchemas')));
  MemoLog.Lines.Add('NFSe/PathSalvar     = ' + string(ACBrGetConfigValue('NFSe', 'PathSalvar')));
  MemoLog.Lines.Add('NFSe/IniServicos    = ' + string(ACBrGetConfigValue('NFSe', 'IniServicos')));
  MemoLog.Lines.Add('NFSe/LayoutNFSe     = ' + string(ACBrGetConfigValue('NFSe', 'LayoutNFSe')));
  MemoLog.Lines.Add('NFSe/Ambiente       = ' + string(ACBrGetConfigValue('NFSe', 'Ambiente')));

  // Configuração do Município e Emitente (OBRIGATÓRIO!)
  ACBrSetConfigValue('NFSe', 'CodigoMunicipio', '3304557');
  ACBrSetConfigValue('NFSe', 'Emitente.CNPJ', '33636499000187');
  ACBrSetConfigValue('NFSe', 'Emitente.InscMun', '4178670');
  ACBrSetConfigValue('NFSe', 'Emitente.RazSocial', 'PRESTADOR TESTE LTDA');

  // Certificado: por padrao usa Windows Store (A1 instalado)
  ConfigurarCertificado;
end;

procedure TFrmTesteNFSe.ConfigurarCertificado;
var
  NumeroSerie, ArquivoPFX, SenhaPFX: AnsiString;
begin
  // IMPORTANTE:
  // Para ACBrLibNFSe (VB6 demo oficial), as chaves do certificado ficam na seção [DFe]
  // e tem os nomes abaixo:
  //   DFe/NumeroSerie
  //   DFe/ArquivoPFX
  //   DFe/Senha
  //   DFe/SSLCryptLib / DFe/SSLHttpLib / DFe/SSLXmlSignLib
  NumeroSerie := '';
  ArquivoPFX  := '';
  SenhaPFX    := '';

  if (Assigned(rbCertPFX) and rbCertPFX.Checked) then begin
    ArquivoPFX := AnsiString(Trim(edtPFXPath.Text));
    SenhaPFX   := AnsiString(Trim(edtPFXSenha.Text));
  end else begin
    // Windows Store (A1 instalado): aqui o usuario informa o Numero de Serie.
    // Obs: a DLL usa apenas o NumeroSerie (sem espacos). Ex: 0123ABCD...
    NumeroSerie := AnsiString(Trim(edtCertSerie.Text));
  end;

  ACBrSetConfigValue('DFe', 'NumeroSerie', NumeroSerie);
  ACBrSetConfigValue('DFe', 'ArquivoPFX',  ArquivoPFX);
  ACBrSetConfigValue('DFe', 'Senha',       SenhaPFX);

  // Mantem os defaults do ACBrLib.ini
  // 0 costuma significar OpenSSL em varios modulos ACBrLib.
  ACBrSetConfigValue('DFe', 'SSLCryptLib',  ACBrGetConfigValue('DFe', 'SSLCryptLib'));
  ACBrSetConfigValue('DFe', 'SSLHttpLib',   ACBrGetConfigValue('DFe', 'SSLHttpLib'));
  ACBrSetConfigValue('DFe', 'SSLXmlSignLib',ACBrGetConfigValue('DFe', 'SSLXmlSignLib'));

  MemoLog.Lines.Add('--- Certificado (resumo) ---');
  MemoLog.Lines.Add('DFe/NumeroSerie = ' + string(ACBrGetConfigValue('DFe', 'NumeroSerie')));
  MemoLog.Lines.Add('DFe/ArquivoPFX  = ' + string(ACBrGetConfigValue('DFe', 'ArquivoPFX')));
end;

procedure TFrmTesteNFSe.btnAplicarCertClick(Sender: TObject);
begin
  try
    ConfigurarCertificado;
  except
    on E: Exception do
      MemoLog.Lines.Add('Erro ao configurar certificado: ' + E.Message);
  end;
end;

procedure TFrmTesteNFSe.btnConsultarSituacaoClick(Sender: TObject);
var
  Ret: Integer;
  Resp: AnsiString;
begin
  // Padrão ACBrLib (VB6 demo): NFSE_ConsultarSituacao(Protocolo, NumeroLote, buffer, bufferLen)
  Ret := CallWithBuffer(@NFSE_ConsultarSituacao, '', '', Resp);
  MemoLog.Lines.Add('NFSE_ConsultarSituacao retorno: ' + IntToStr(Ret));
  if Resp <> '' then
    MemoLog.Lines.Add('Resposta: ' + string(Resp));

  if Ret <> 0 then
    MemoLog.Lines.Add('Erro: ' + CallUltimoRetorno);
end;

procedure TFrmTesteNFSe.btnCarregarXMLClick(Sender: TObject);
var
  IniPath: string;
  Ret: Integer;
begin
  IniPath := ExtractFilePath(Application.ExeName) + 'xml\dps_pf.xml';
  
  MemoLog.Lines.Add('=== TESTE DE CARREGAMENTO ===');
  MemoLog.Lines.Add('Arquivo: ' + IniPath);
  MemoLog.Lines.Add('Existe? ' + BoolToStr(FileExists(IniPath), True));
  
  if not FileExists(IniPath) then begin
    MemoLog.Lines.Add('ERRO: Arquivo não encontrado!');
    Exit;
  end;
  
  // Limpa lista anterior
  if Assigned(NFSE_LimparLista) then
    NFSE_LimparLista;
  
  // Carrega o XML
  Ret := NFSE_CarregarXML(PAnsiChar(AnsiString(IniPath)));
  
  MemoLog.Lines.Add('Retorno: ' + IntToStr(Ret));
  
  if Ret = 0 then begin
    MemoLog.Lines.Add('? SUCESSO! XML carregado corretamente.');
    btnEmitir.Enabled := True;
  end else begin
    MemoLog.Lines.Add('? ERRO ao carregar XML');
    MemoLog.Lines.Add('Detalhes:');
    MemoLog.Lines.Add(CallUltimoRetorno);
    btnEmitir.Enabled := False;
  end;
end;

procedure TFrmTesteNFSe.btnEmitirClick(Sender: TObject);
var
  Ret: Integer;
  Resp: AnsiString;
begin
  btnEmitir.Enabled := False;

  // Padrão ACBrLib (VB6 demo): NFSE_Emitir(Lote, ModoEnvio, Imprimir, buffer, bufferLen)
  // ModoEnvio (demo): 0=Sincrono, 1=LoteAssincrono
  Ret := CallWithBuffer3(@NFSE_Emitir, '1', 1, 0, Resp);
  MemoLog.Lines.Add('NFSE_Emitir retorno: ' + IntToStr(Ret));
  if Resp <> '' then begin
    FUltimaResposta := Resp;
    MemoLog.Lines.Add('Resposta: ' + string(Resp));
  end;

  if Ret <> 0 then
    MemoLog.Lines.Add('Erro: ' + CallUltimoRetorno);
end;

procedure TFrmTesteNFSe.MemoLogKeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if (ssctrl in shift) and (Chr(Key) in ['a', 'A']) then begin
    TMemo(Sender).SelectAll;
  end;
end;

procedure TFrmTesteNFSe.btnCarregarINIClick(Sender: TObject);
var
  IniPath: string;
  Ret: Integer;
begin
  // Layout Nacional (Emissor Nacional)
  // Evita problemas de schema/encoding no Delphi 6 e segue o modelo do ACBr.
  IniPath := ExtractFilePath(Application.ExeName) + 'xml\dps_minimo_pf.ini';
  MemoLog.Lines.Add('INI Usado: ' + IniPath);

  if not FileExists(IniPath) then begin
    MemoLog.Lines.Add('Arquivo nao encontrado: ' + IniPath);
    Exit;
  end;

  if Assigned(NFSE_LimparLista) then
    NFSE_LimparLista;

  // A DLL aceita "arquivo OU conteudo"; para evitar encoding no Delphi 6,
  // passamos o CAMINHO do arquivo.
  Ret := NFSE_CarregarINI(PAnsiChar(AnsiString(IniPath)));
  MemoLog.Lines.Add('NFSE_CarregarINI retorno: ' + IntToStr(Ret));

  if Ret <> 0 then begin
    btnEmitir.Enabled := False;
    MemoLog.Lines.Add('Erro: ' + CallUltimoRetorno);
  end else
    btnEmitir.Enabled := True;
end;

procedure TFrmTesteNFSe.btnCarregarXMLTesteClick(Sender: TObject);
begin
  if not Od.Execute then Exit;
  TestarCarregamentoXML(Od.FileName, MemoLog.Lines);
end;

procedure TFrmTesteNFSe.habilitarBotoes(valor: boolean);
begin
  btnNome.enabled              := valor;
  btnVersao.enabled            := valor;
  btnConsultarSituacao.enabled := valor;
  btnCarregarXML.enabled       := valor;
  btnCarregarINI.enabled       := valor;
  btnAplicarCert.enabled       := valor;
  btnCarregarXMLTeste.enabled  := valor;
end;

end.
