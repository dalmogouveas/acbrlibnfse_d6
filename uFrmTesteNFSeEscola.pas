unit uFrmTesteNFSeEscola;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ComCtrls, ExtCtrls, uLogNFSe;

type
  // Estrutura para armazenar info do certificado
  TCertInfo = record
    Nome: string;
    Serie: string;
    Validade: string;
  end;

  TFrmTesteNFSeEscola = class(TForm)
    PageControl1: TPageControl;
    TabConfig: TTabSheet;
    TabEmissao: TTabSheet;
    TabAjuda: TTabSheet;
    
    // Aba Configuração
    GroupDadosEscola: TGroupBox;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    edtCNPJEscola: TEdit;
    edtInscMunEscola: TEdit;
    edtRazaoSocialEscola: TEdit;
    edtCodMunicipio: TEdit;
    cbUF: TComboBox;
    edtSerie: TEdit;
    cbAmbiente: TComboBox;
    
    GroupCertificado: TGroupBox;
    Label8: TLabel;
    Label9: TLabel;
    Label10: TLabel;
    rbCertPFX: TRadioButton;
    rbCertWinStore: TRadioButton;
    edtCertPath: TEdit;
    btnSelecionarCert: TButton;
    edtCertSenha: TEdit;
    btnTestarCert: TButton;
    
    btnInicializar: TButton;
    Panel1: TPanel;
    Label11: TLabel;
    MemoLogConfig: TMemo;
    
    // Aba Emissão
    GroupDPS: TGroupBox;
    Label12: TLabel;
    Label13: TLabel;
    rbDPSIni: TRadioButton;
    rbDPSXml: TRadioButton;
    edtDPSArquivo: TEdit;
    btnSelecionarDPS: TButton;
    btnCarregarDPS: TButton;
    btnDPSExemploPF: TButton;
    btnDPSExemploPJ: TButton;
    
    GroupEmissao: TGroupBox;
    Label14: TLabel;
    Label15: TLabel;
    edtNumeroLote: TEdit;
    cbModoEnvio: TComboBox;
    btnEmitir: TButton;
    
    Panel2: TPanel;
    Label16: TLabel;
    MemoLogEmissao: TMemo;
    
    // Aba Ajuda
    Memo1: TMemo;
    
    // Diálogos
    OpenDialog1: TOpenDialog;
    OpenDialog2: TOpenDialog;

    btnListarCertificados: TButton;
    cbCertificados: TComboBox;
    lblListaCerts: TLabel;
    edtCertSerie: TEdit;
    lblNumCert: TLabel;
    Bevel1: TBevel;

    procedure btnListarCertificadosClick(Sender: TObject);
    procedure cbCertificadosChange(Sender: TObject);


    // Eventos
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure btnInicializarClick(Sender: TObject);
    procedure btnSelecionarCertClick(Sender: TObject);
    procedure btnTestarCertClick(Sender: TObject);
    procedure btnSelecionarDPSClick(Sender: TObject);
    procedure btnCarregarDPSClick(Sender: TObject);
    procedure btnDPSExemploPFClick(Sender: TObject);
    procedure btnDPSExemploPJClick(Sender: TObject);
    procedure btnEmitirClick(Sender: TObject);
    procedure rbCertPFXClick(Sender: TObject);
    procedure rbCertWinStoreClick(Sender: TObject);
    
  private
    { Private declarations }
    FLogConfig: TLogNFSe;
    FLogEmissao: TLogNFSe;
    FInicializado: Boolean;
    FDPSCarregada: Boolean;
    FPastaBase: string;
    FPastaLogs: string;
    FPastaExemplos: string;

    FListaCerts: array of TCertInfo;

    function ConfigGravarValor(const ASecao, AChave, AValor: string): Integer;
    function CallUltimoRetorno: string;
    function CallWithBuffer1(AFuncao: Pointer; const P1: PAnsiChar; var AResp: AnsiString): Integer;
    function CallWithBuffer3(AFuncao: Pointer; const P1: PAnsiChar; P2, P3: Integer; var AResp: AnsiString): Integer;

    procedure InicializarComponentes;
    procedure ConfigurarPastas;
    procedure CriarArquivosExemplo;
    procedure HabilitarControlesPosInicializacao;
    procedure ConfigurarNFSeNacional;
    procedure AplicarCertificado;
    procedure CarregarDPS(const AArquivo: string);
    function GetModoEnvio: Integer;

    function ExtrairInfoCert(const ALinha: string): TCertInfo;

  public
    { Public declarations }
  end;

var
  FrmTesteNFSeEscola: TFrmTesteNFSeEscola;

implementation

uses
  uACBrNFSeLib, IniFiles;

{$R *.dfm}


{ TFrmTesteNFSeEscola }

procedure TFrmTesteNFSeEscola.FormCreate(Sender: TObject);
begin
  FInicializado := False;
  FDPSCarregada := False;
  
  // Definir pastas
  FPastaBase := ExtractFilePath(Application.ExeName);
  FPastaLogs := FPastaBase + 'logs';
  FPastaExemplos := FPastaBase + 'exemplos';
  
  ConfigurarPastas;
  
  // Inicializar logs
  FLogConfig := TLogNFSe.Create(MemoLogConfig.Lines, FPastaLogs);
  FLogEmissao := TLogNFSe.Create(MemoLogEmissao.Lines, FPastaLogs);
  
  InicializarComponentes;
  
  FLogConfig.LogSecao('SISTEMA INICIADO');
  FLogConfig.Log('Versão: 1.0.0 - Teste de Emissão NFS-e Nacional');
  FLogConfig.Log('Data: ' + FormatDateTime('dd/mm/yyyy hh:nn:ss', Now));
  FLogConfig.LogSeparador;
end;

procedure TFrmTesteNFSeEscola.FormDestroy(Sender: TObject);
begin
  if Assigned(NFSE_Finalizar) then
    NFSE_Finalizar;
  
  DescarregarACBrNFSe;
  
  FreeAndNil(FLogConfig);
  FreeAndNil(FLogEmissao);
end;

procedure TFrmTesteNFSeEscola.InicializarComponentes;
begin
  // Configurar combos
  cbAmbiente.ItemIndex := 1; // Homologação
  cbModoEnvio.ItemIndex := 2; // Síncrono
  cbUF.ItemIndex := cbUF.Items.IndexOf('RJ');
  
  // Desabilitar controles de emissão
  btnSelecionarDPS.Enabled := False;
  btnCarregarDPS.Enabled := False;
  btnDPSExemploPF.Enabled := False;
  btnDPSExemploPJ.Enabled := False;
  btnEmitir.Enabled := False;
  
  // Aba ativa
  PageControl1.ActivePageIndex := 0;
end;

procedure TFrmTesteNFSeEscola.ConfigurarPastas;
begin
  // Criar pastas necessárias
  if not DirectoryExists(FPastaLogs) then
    ForceDirectories(FPastaLogs);
  
  if not DirectoryExists(FPastaExemplos) then
    ForceDirectories(FPastaExemplos);
    
  if not DirectoryExists(FPastaBase + 'xml') then
    ForceDirectories(FPastaBase + 'xml');
end;

procedure TFrmTesteNFSeEscola.CriarArquivosExemplo;
var
  ArqPF_INI, ArqPF_XML: string;
  ArqPJ_INI, ArqPJ_XML: string;
  F: TextFile;
begin
  // Os arquivos de exemplo já devem estar na pasta "exemplos"
  // Este método apenas verifica se existem
  
  ArqPF_INI := FPastaExemplos + '\DPS_Escola_TomadorPF.ini';
  ArqPF_XML := FPastaExemplos + '\DPS_Escola_TomadorPF.xml';
  ArqPJ_INI := FPastaExemplos + '\DPS_Escola_TomadorPJ.ini';
  ArqPJ_XML := FPastaExemplos + '\DPS_Escola_TomadorPJ.xml';
  
  if not FileExists(ArqPF_INI) then
    FLogConfig.LogAviso('Arquivo de exemplo não encontrado: DPS_Escola_TomadorPF.ini');
  
  if not FileExists(ArqPJ_INI) then
    FLogConfig.LogAviso('Arquivo de exemplo não encontrado: DPS_Escola_TomadorPJ.ini');
end;

procedure TFrmTesteNFSeEscola.HabilitarControlesPosInicializacao;
begin
  btnSelecionarDPS.Enabled := True;
  btnCarregarDPS.Enabled := False; // Habilita depois de selecionar
  btnDPSExemploPF.Enabled := True;
  btnDPSExemploPJ.Enabled := True;
  
  PageControl1.ActivePage := TabEmissao;
end;

function TFrmTesteNFSeEscola.CallUltimoRetorno: string;
const
  TAM_BUFFER = 65536;
var
  Buffer: AnsiString;
  BufLen: Integer;
begin
  Result := '';
  if not Assigned(NFSE_UltimoRetorno) then
    Exit;
  
  BufLen := TAM_BUFFER;
  SetLength(Buffer, BufLen);
  FillChar(Buffer[1], BufLen, #0);
  
  NFSE_UltimoRetorno(PAnsiChar(Buffer), BufLen);
  
  if BufLen > 0 then
    Result := Copy(string(Buffer), 1, BufLen);
end;

function TFrmTesteNFSeEscola.CallWithBuffer1(AFuncao: Pointer; 
  const P1: PAnsiChar; var AResp: AnsiString): Integer;
const
  TAM_BUFFER = 65536;
type
  TFunc1 = function(P1: PAnsiChar; Buffer: PAnsiChar; var BufLen: Integer): Integer; stdcall;
var
  BufLen: Integer;
begin
  Result := -1;
  AResp := '';
  
  if not Assigned(AFuncao) then
    Exit;
  
  BufLen := TAM_BUFFER;
  SetLength(AResp, BufLen);
  FillChar(AResp[1], BufLen, #0);
  
  Result := TFunc1(AFuncao)(P1, PAnsiChar(AResp), BufLen);
  
  if BufLen > 0
    then SetLength(AResp, BufLen)
    else AResp := '';
end;

function TFrmTesteNFSeEscola.CallWithBuffer3(AFuncao: Pointer; 
  const P1: PAnsiChar; P2, P3: Integer; var AResp: AnsiString): Integer;
const
  TAM_BUFFER = 65536;
type
  TFunc3 = function(P1: PAnsiChar; P2, P3: Integer; Buffer: PAnsiChar; var BufLen: Integer): Integer; stdcall;
var
  BufLen: Integer;
begin
  Result := -1;
  AResp := '';
  
  if not Assigned(AFuncao) then
    Exit;
  
  BufLen := TAM_BUFFER;
  SetLength(AResp, BufLen);
  FillChar(AResp[1], BufLen, #0);
  
  Result := TFunc3(AFuncao)(P1, P2, P3, PAnsiChar(AResp), BufLen);
  
  if BufLen > 0 then
    SetLength(AResp, BufLen)
  else
    AResp := '';
end;

function TFrmTesteNFSeEscola.ConfigGravarValor(const ASecao, AChave, AValor: string): Integer;
begin
  Result := -1;
  if not Assigned(NFSE_ConfigGravarValor) then
    Exit;
  
  Result := NFSE_ConfigGravarValor(
    PAnsiChar(AnsiString(ASecao)),
    PAnsiChar(AnsiString(AChave)),
    PAnsiChar(AnsiString(AValor))
  );
  
  // Log com censura
  FLogConfig.LogConfiguracao(ASecao, AChave, AValor);
end;


procedure TFrmTesteNFSeEscola.ConfigurarNFSeNacional;
var
  Ret: Integer;
  Ambiente: string;
begin
  FLogConfig.LogSecao('CONFIGURANDO PADRÃO NACIONAL');
  
  // Ambiente
  if cbAmbiente.ItemIndex = 0
    then Ambiente := '0'
    else Ambiente := '1';

  // Configurações críticas
  Ret := ConfigGravarValor('NFSe', 'LayoutNFSe', '1'); // Padrão Nacional v1.00
  if Ret <> 0
    then raise Exception.Create('Erro ao configurar Layout: ' + CallUltimoRetorno);

  Ret := ConfigGravarValor('NFSe', 'Ambiente', Ambiente);
  if Ret <> 0
    then raise Exception.Create('Erro ao configurar Ambiente: ' + CallUltimoRetorno);

  Ret := ConfigGravarValor('NFSe', 'CodigoMunicipio', Trim(edtCodMunicipio.Text));
  if Ret <> 0
    then raise Exception.Create('Erro ao configurar Município: ' + CallUltimoRetorno);

  // Emitente
  Ret := ConfigGravarValor('NFSe', 'Emitente.CNPJ', Trim(edtCNPJEscola.Text));
  if Ret <> 0
    then raise Exception.Create('Erro ao configurar CNPJ: ' + CallUltimoRetorno);

  Ret := ConfigGravarValor('NFSe', 'Emitente.InscMun', Trim(edtInscMunEscola.Text));
  if Ret <> 0
    then raise Exception.Create('Erro ao configurar IM: ' + CallUltimoRetorno);
  
  Ret := ConfigGravarValor('NFSe', 'Emitente.RazSocial', Trim(edtRazaoSocialEscola.Text));
  if Ret <> 0 then
    raise Exception.Create('Erro ao configurar Razão Social: ' + CallUltimoRetorno);
  
  // Paths
  Ret := ConfigGravarValor('NFSe', 'PathSalvar', FPastaLogs);
  Ret := ConfigGravarValor('NFSe', 'PathSchemas', FPastaBase + 'acbr\schemas\NFSe');
  Ret := ConfigGravarValor('NFSe', 'IniServicos', FPastaBase + 'acbr\ACBrNFSeXServicosRTC.ini');
  
  // Salvar XMLs
  Ret := ConfigGravarValor('NFSe', 'SalvarGer', '1');
  Ret := ConfigGravarValor('NFSe', 'SalvarWS', '1');
  Ret := ConfigGravarValor('NFSe', 'SalvarArq', '1');
  
  // Separação
  Ret := ConfigGravarValor('NFSe', 'SepararPorCNPJ', '1');
  Ret := ConfigGravarValor('NFSe', 'SepararPorAno', '1');
  Ret := ConfigGravarValor('NFSe', 'SepararPorMes', '1');
  
  // SSL
  Ret := ConfigGravarValor('NFSe', 'SSLType', '5'); // TLSv1.2
  
  // Timeouts
  Ret := ConfigGravarValor('NFSe', 'Timeout', '30000');
  Ret := ConfigGravarValor('NFSe', 'Tentativas', '3');
  Ret := ConfigGravarValor('NFSe', 'IntervaloTentativas', '2000');
  
  // Validações
  Ret := ConfigGravarValor('NFSe', 'ExibirErroSchema', '1');
  Ret := ConfigGravarValor('NFSe', 'ValidarDigest', '1');
  
  // Consultas
  Ret := ConfigGravarValor('NFSe', 'ConsultaLoteAposEnvio', '1');
  Ret := ConfigGravarValor('NFSe', 'ConsultaAposCancelar', '1');
  
  FLogConfig.LogSucesso('Configuração do Padrão Nacional concluída');
end;

procedure TFrmTesteNFSeEscola.AplicarCertificado;
var
  Ret: Integer;
  CertPath, CertSenha: string;
begin
  FLogConfig.LogSecao('CONFIGURANDO CERTIFICADO DIGITAL');

  if rbCertPFX.Checked then begin
    // Certificado PFX
    CertPath  := Trim(edtCertPath.Text);
    CertSenha := Trim(edtCertSenha.Text);

    if CertPath = ''
      then raise Exception.Create('Informe o caminho do certificado PFX!');

    if not FileExists(CertPath)
      then raise Exception.Create('Arquivo de certificado não encontrado: ' + CertPath);
    
    if CertSenha = ''
      then raise Exception.Create('Informe a senha do certificado!');
    
    FLogConfig.Log('Tipo: Arquivo PFX');
    FLogConfig.Log('Caminho: ' + ExtractFileName(CertPath));
    
    Ret := ConfigGravarValor('DFe', 'ArquivoPFX', CertPath);
    if Ret <> 0
      then raise Exception.Create('Erro ao configurar certificado: ' + CallUltimoRetorno);

    Ret := ConfigGravarValor('DFe', 'Senha', CertSenha);
    if Ret <> 0
      then raise Exception.Create('Erro ao configurar senha: ' + CallUltimoRetorno);

    FLogConfig.LogSucesso('Certificado PFX configurado');
  end else begin
    // Windows Store
    FLogConfig.Log('Tipo: Windows Store (certificado instalado)');
    
    Ret := ConfigGravarValor('DFe', 'ArquivoPFX', '');
    Ret := ConfigGravarValor('DFe', 'Senha', '');
    
    FLogConfig.LogAviso('Será usado o certificado instalado no Windows');
    FLogConfig.LogAviso('Certifique-se de que o certificado correto está instalado!');
  end;
end;

procedure TFrmTesteNFSeEscola.btnInicializarClick(Sender: TObject);
var
  Ret: Integer;
  DllPath: string;
begin
  btnInicializar.Enabled := False;
  Screen.Cursor := crHourGlass;
  try
    // Validações
    if Trim(edtCNPJEscola.Text) = '' then begin
      ShowMessage('Informe o CNPJ da escola!');
      Exit;
    end;
    
    if Trim(edtInscMunEscola.Text) = '' then  begin
      ShowMessage('Informe a Inscrição Municipal!');
      Exit;
    end;
    
    FLogConfig.LogSecao('INICIALIZANDO BIBLIOTECA ACBrNFSe');
    
    DllPath := FPastaBase + 'acbr\ACBrNFSe32.dll';

    if not FileExists(DllPath)
      then raise Exception.Create('DLL não encontrada: ' + DllPath);

    FLogConfig.Log('Carregando DLL: ' + DllPath);

    if not CarregarACBrNFSe(DllPath)
      then raise Exception.Create('Erro ao carregar DLL: ' + DllPath);
    
    FLogConfig.LogSucesso('DLL carregada');

    Ret := NFSE_Inicializar(PAnsiChar(''), PAnsiChar(''));
    FLogConfig.Log('NFSE_Inicializar retorno: ' + IntToStr(Ret));

    if Ret <> 0
      then raise Exception.Create('Erro ao inicializar: ' + CallUltimoRetorno);

    FLogConfig.LogSucesso('Biblioteca inicializada');

    ConfigurarNFSeNacional;

    AplicarCertificado;
    
    FInicializado := True;
    
    FLogConfig.LogSeparador;
    FLogConfig.LogSucesso('SISTEMA PRONTO PARA EMISSÃO!');
    FLogConfig.Log('Vá para a aba "Emissão" para carregar uma DPS e emitir');
    
    HabilitarControlesPosInicializacao;
    
    ShowMessage('Sistema inicializado com sucesso!' + #13#10 +
                'Vá para a aba "Emissão" para continuar.');
    
  except
    on E: Exception do begin
      FLogConfig.LogErro(E.Message);
      ShowMessage('ERRO ao inicializar:' + #13#10 + E.Message);
      btnInicializar.Enabled := True;
    end;
  end;
  
  Screen.Cursor := crDefault;
end;


procedure TFrmTesteNFSeEscola.CarregarDPS(const AArquivo: string);
var
  Ret: Integer;
  Ext: string;
begin
  FLogEmissao.LogSecao('CARREGANDO DPS');
  FLogEmissao.Log('Arquivo: ' + ExtractFileName(AArquivo));

  if not FileExists(AArquivo) then
    raise Exception.Create('Arquivo não encontrado: ' + AArquivo);

  if Assigned(NFSE_LimparLista) then begin
    Ret := NFSE_LimparLista;
    FLogEmissao.Log('NFSE_LimparLista retorno: ' + IntToStr(Ret));
  end;

  Ext := LowerCase(ExtractFileExt(AArquivo));

  if Ext = '.ini' then begin
    FLogEmissao.Log('Formato: INI');
    Ret := NFSE_CarregarINI(PAnsiChar(AnsiString(AArquivo)));
  end else if Ext = '.xml' then begin
    FLogEmissao.Log('Formato: XML');
    Ret := NFSE_CarregarXML(PAnsiChar(AnsiString(AArquivo)));
  end else raise Exception.Create('Formato não suportado: ' + Ext);
  
  FLogEmissao.Log('Retorno: ' + IntToStr(Ret));
  
  if Ret <> 0
    then raise Exception.Create('Erro ao carregar DPS:' + #13#10 + CallUltimoRetorno);
  
  FLogEmissao.LogSucesso('DPS carregada com sucesso!');
  
  FDPSCarregada := True;
  btnEmitir.Enabled := True;
  edtDPSArquivo.Text := AArquivo;
end;

function TFrmTesteNFSeEscola.GetModoEnvio: Integer;
begin
  // 0 = Automático
  // 1 = Lote Assíncrono
  // 2 = Síncrono
  // 3 = Unitário
  // 4 = Teste  
  Result := cbModoEnvio.ItemIndex;
end;

procedure TFrmTesteNFSeEscola.btnEmitirClick(Sender: TObject);
var
  Ret: Integer;
  Resp: AnsiString;
  NumLote: string;
  ModoEnvio: Integer;
  RespStr: string;
begin
  if not FDPSCarregada then begin
    ShowMessage('Carregue uma DPS primeiro!');
    Exit;
  end;
  
  btnEmitir.Enabled := False;
  Screen.Cursor := crHourGlass;
  try
    FLogEmissao.LogSeparador;
    FLogEmissao.LogSecao('EMITINDO NFS-e');
    
    NumLote := Trim(edtNumeroLote.Text);
    ModoEnvio := GetModoEnvio;
    
    FLogEmissao.Log('Parâmetros:');
    FLogEmissao.Log('  - Número do lote: ' + NumLote);
    FLogEmissao.Log('  - Modo de envio: ' + IntToStr(ModoEnvio) + ' (' + cbModoEnvio.Text + ')');
    FLogEmissao.Log('  - Imprimir: Não');
    FLogEmissao.Log('');

    if ModoEnvio = 2
      then FLogEmissao.Log('? Modo SÍNCRONO selecionado (correto para Padrão Nacional)')
      else FLogEmissao.LogAviso('Modo diferente de SÍNCRONO! Pode causar erro.');

    FLogEmissao.Log('');
    FLogEmissao.Log('Enviando para o WebService...');

    // Emitir
    Ret := CallWithBuffer3(@NFSE_Emitir,
                          PAnsiChar(AnsiString(NumLote)),
                          ModoEnvio,
                          0, // não imprimir
                          Resp);

    FLogEmissao.Log('');
    FLogEmissao.Log('NFSE_Emitir retorno: ' + IntToStr(Ret));
    FLogEmissao.Log('');

    if Resp <> '' then begin
      RespStr := string(Resp);
      
      FLogEmissao.LogSecao('RESPOSTA DO WEBSERVICE');
      FLogEmissao.Log(RespStr);
      FLogEmissao.LogSeparador;
      
      // Analisar resposta
      if Pos('Sucesso=1', RespStr) > 0 then begin
        FLogEmissao.Log('');
        FLogEmissao.Log('+----------------------------------------+');
        FLogEmissao.Log('¦  ? SUCESSO! NFS-e EMITIDA!            ¦');
        FLogEmissao.Log('+----------------------------------------+');
        FLogEmissao.Log('');
        FLogEmissao.Log('Verifique os XMLs salvos em: ' + FPastaLogs);
        FLogEmissao.Log('');
        
        ShowMessage('? NFS-e emitida com SUCESSO!' + #13#10 + #13#10 +
                    'Verifique os XMLs na pasta "logs".');
      end else if Pos('Erro', RespStr) > 0 then begin
        FLogEmissao.Log('');
        FLogEmissao.Log('+----------------------------------------+');
        FLogEmissao.Log('¦  ? ERRO NA EMISSÃO!                   ¦');
        FLogEmissao.Log('+----------------------------------------+');
        FLogEmissao.Log('');

        // Diagnóstico
        if Pos('não implementado', LowerCase(RespStr)) > 0 then begin
          FLogEmissao.LogAviso('DIAGNÓSTICO:');
          FLogEmissao.LogAviso('  - Erro "serviço não implementado"');
          FLogEmissao.LogAviso('  - Verifique se o modo de envio está SÍNCRONO (modo 2)');
          FLogEmissao.LogAviso('  - Verifique se o Layout está Padrão Nacional');
        end else if Pos('certificado', LowerCase(RespStr)) > 0 then begin
          FLogEmissao.LogAviso('DIAGNÓSTICO:');
          FLogEmissao.LogAviso('  - Problema com certificado digital');
          FLogEmissao.LogAviso('  - Verifique se é o certificado do CNPJ da escola');
          FLogEmissao.LogAviso('  - Verifique se a senha está correta');
        end else if Pos('credenc', LowerCase(RespStr)) > 0 then begin
          FLogEmissao.LogAviso('DIAGNÓSTICO:');
          FLogEmissao.LogAviso('  - Problema de credenciamento');
          FLogEmissao.LogAviso('  - Verifique se a escola está cadastrada');
          FLogEmissao.LogAviso('  - Verifique se o ambiente de homologação está liberado');
        end;
        
        FLogEmissao.Log('');
        FLogEmissao.Log('Último retorno completo:');
        FLogEmissao.Log(CallUltimoRetorno);
        
        ShowMessage('? ERRO na emissão!' + #13#10 + #13#10 +
                    'Verifique o log de emissão para mais detalhes.');
      end else begin
        FLogEmissao.LogAviso('Resposta sem indicação clara de sucesso ou erro.');
        FLogEmissao.Log('Analise a resposta acima para mais detalhes.');
        
        ShowMessage('Emissão concluída.' + #13#10 +
                    'Verifique o log para analisar o resultado.');
      end;
    end else begin
      FLogEmissao.LogAviso('ATENÇÃO: Resposta vazia do webservice!');
      FLogEmissao.Log('');
      FLogEmissao.Log('Último retorno:');
      FLogEmissao.Log(CallUltimoRetorno);
      
      ShowMessage('Resposta vazia do WebService!' + #13#10 +
                  'Verifique o log para mais detalhes.');
    end;
      
  except
    on E: Exception do begin
      FLogEmissao.LogErro(E.Message);
      ShowMessage('ERRO ao emitir:' + #13#10 + E.Message);
    end;
  end;

  btnEmitir.Enabled := True;
  Screen.Cursor := crDefault;
end;

procedure TFrmTesteNFSeEscola.rbCertPFXClick(Sender: TObject);
begin
  edtCertPath.Enabled       := True;
  btnSelecionarCert.Enabled := True;
  edtCertSenha.Enabled      := True;
end;

procedure TFrmTesteNFSeEscola.rbCertWinStoreClick(Sender: TObject);
begin
  edtCertPath.Enabled       := False;
  btnSelecionarCert.Enabled := False;
  edtCertSenha.Enabled      := False;
  edtCertPath.Text          := '';
  edtCertSenha.Text         := '';
end;

procedure TFrmTesteNFSeEscola.btnSelecionarCertClick(Sender: TObject);
begin
  OpenDialog1.InitialDir := FPastaBase;
  
  if OpenDialog1.Execute
    then edtCertPath.Text := OpenDialog1.FileName;
end;

procedure TFrmTesteNFSeEscola.btnTestarCertClick(Sender: TObject);
var
  CertPath: string;
begin
  if rbCertPFX.Checked then begin
    CertPath := Trim(edtCertPath.Text);
    
    if CertPath = '' then begin
      ShowMessage('Informe o caminho do certificado!');
      Exit;
    end;

    if not FileExists(CertPath) then begin
      ShowMessage('Arquivo não encontrado:' + #13#10 + CertPath);
      Exit;
    end;

    ShowMessage('Certificado encontrado:' + #13#10 +
                ExtractFileName(CertPath) + #13#10 + #13#10 +
                'ATENÇÃO: Este deve ser o certificado A1 do CNPJ da escola!');
  end else begin
    ShowMessage('Modo Windows Store selecionado.' + #13#10 + #13#10 +
                'O certificado instalado no Windows será usado.' + #13#10 +
                'Certifique-se de que o certificado correto está instalado!');
  end;
end;

procedure TFrmTesteNFSeEscola.btnSelecionarDPSClick(Sender: TObject);
begin
  OpenDialog2.InitialDir := FPastaExemplos;
  
  if rbDPSIni.Checked
    then OpenDialog2.FilterIndex := 1
    else OpenDialog2.FilterIndex := 2;

  if OpenDialog2.Execute then begin
    edtDPSArquivo.Text := OpenDialog2.FileName;
    btnCarregarDPS.Enabled := True;
  end;
end;

procedure TFrmTesteNFSeEscola.btnCarregarDPSClick(Sender: TObject);
var
  Arquivo: string;
begin
  Arquivo := Trim(edtDPSArquivo.Text);

  if Arquivo = '' then begin
    ShowMessage('Selecione um arquivo DPS primeiro!');
    Exit;
  end;

  Screen.Cursor := crHourGlass;
  try
    CarregarDPS(Arquivo);
    ShowMessage('DPS carregada com sucesso!' + #13#10 +
                'Clique em "Emitir NFS-e" para continuar.');
  except
    on E: Exception do begin
      ShowMessage('ERRO ao carregar DPS:' + #13#10 + E.Message);
      FLogEmissao.LogErro(E.Message);
    end;
  end;
  Screen.Cursor := crDefault;
end;

procedure TFrmTesteNFSeEscola.btnDPSExemploPFClick(Sender: TObject);
var
  Arquivo: string;
  Ext: string;
begin
  if rbDPSIni.Checked then
    Ext := '.ini'
  else
    Ext := '.xml';
  
  Arquivo := FPastaExemplos + '\DPS_Escola_TomadorPF' + Ext;

  if not FileExists(Arquivo) then begin
    ShowMessage('Arquivo de exemplo não encontrado:' + #13#10 + Arquivo);
    Exit;
  end;
  
  Screen.Cursor := crHourGlass;
  try
    CarregarDPS(Arquivo);
    ShowMessage('Exemplo PF carregado!' + #13#10 +
                'Clique em "Emitir NFS-e" para testar.');
  except
    on E: Exception do begin
      ShowMessage('ERRO:' + #13#10 + E.Message);
      FLogEmissao.LogErro(E.Message);
    end;
  end;
  Screen.Cursor := crDefault;
end;

procedure TFrmTesteNFSeEscola.btnDPSExemploPJClick(Sender: TObject);
var
  Arquivo: string;
  Ext: string;
begin
  if rbDPSIni.Checked then
    Ext := '.ini'
  else
    Ext := '.xml';
  
  Arquivo := FPastaExemplos + '\DPS_Escola_TomadorPJ' + Ext;

  if not FileExists(Arquivo) then begin
    ShowMessage('Arquivo de exemplo não encontrado:' + #13#10 + Arquivo);
    Exit;
  end;
  
  Screen.Cursor := crHourGlass;
  try
    CarregarDPS(Arquivo);
    ShowMessage('Exemplo PJ carregado!' + #13#10 +
                'Clique em "Emitir NFS-e" para testar.');
  except
    on E: Exception do begin
      ShowMessage('ERRO:' + #13#10 + E.Message);
      FLogEmissao.LogErro(E.Message);
    end;
  end;
  Screen.Cursor := crDefault;
end;

procedure TFrmTesteNFSeEscola.btnListarCertificadosClick(Sender: TObject);
var
  ListaCerts: string;
  Lista: TStringList;
  I: Integer;
  Linha: string;
  Info: TCertInfo;
  Display: string;
begin
  cbCertificados.Items.Clear;
  SetLength(FListaCerts, 0);
  
  try
    Screen.Cursor := crHourGlass;
    try
      ListaCerts := ObterCertificados;
      
      if Trim(ListaCerts) = '' then begin
        FLogConfig.LogSecao('Certificados');
        FLogConfig.LogAviso('Nenhum certificado encontrado no Windows Store.');
        ShowMessage('Nenhum certificado encontrado no Windows Store.' + #13#10 +
                    'Verifique se há certificados A1 instalados.');
        Exit;
      end;
      
      // Processa a lista
      Lista := TStringList.Create;
      try
        Lista.Text := ListaCerts;

        SetLength(FListaCerts, Lista.Count);

        for I := 0 to Lista.Count - 1 do begin
          Linha := Lista[I];
          
          if Trim(Linha) = '' then
            Continue;
            
          // Extrai informações
          Info := ExtrairInfoCert(Linha);
          FListaCerts[I] := Info;
          
          // Formata para exibição no ComboBox
          if Info.Validade <> '' then
            Display := Format('%s (Série: %s | Val: %s)', [
              Info.Nome, Info.Serie, Info.Validade])
          else
            Display := Format('%s (Série: %s)', [
              Info.Nome, Info.Serie]);
              
          cbCertificados.Items.AddObject(Display, TObject(I));
        end;

        if cbCertificados.Items.Count > 0 then begin
          cbCertificados.ItemIndex := 0;
          cbCertificadosChange(nil);

          FLogConfig.LogSecao('Certificados');
          FLogConfig.LogSucesso(Format('Certificados encontrados: %d',
            [cbCertificados.Items.Count]));

          ShowMessage(Format('Encontrados %d certificado(s).',
            [cbCertificados.Items.Count]));
        end;

      finally
        Lista.Free;
      end;

    finally
      Screen.Cursor := crDefault;
    end;
  except
    on E: Exception do begin
      FLogConfig.LogSecao('Certificados');
      FLogConfig.LogErro('Erro ao listar certificados: ' + E.Message);
      ShowMessage('Erro ao listar certificados: ' + E.Message);
    end;
  end;
end;

procedure TFrmTesteNFSeEscola.cbCertificadosChange(Sender: TObject);
var
  Idx: Integer;
begin
  if cbCertificados.ItemIndex < 0 then
    Exit;

  try
    Idx := Integer(cbCertificados.Items.Objects[cbCertificados.ItemIndex]);
    if (Idx >= 0) and (Idx < Length(FListaCerts)) then begin
      edtCertSerie.Text := FListaCerts[Idx].Serie;
      rbCertWinStore.Checked := True;
      FLogConfig.LogSucesso(Format('Certificado selecionado: %s (Série: %s)', [
        FListaCerts[Idx].Nome,
        FListaCerts[Idx].Serie
      ]));
    end;    
  except
    on E: Exception do
      FLogConfig.LogErro('Erro ao selecionar certificado:' + E.Message);
  end;
end;

{===============================================================================
  Função Auxiliar: ExtrairInfoCert
  Extrai informações de uma linha do certificado
===============================================================================}
function TFrmTesteNFSeEscola.ExtrairInfoCert(const ALinha: string): TCertInfo;
var
  Pos1, Pos2: Integer;
  Temp: string;
begin
  // Inicializa
  Result.Nome := '';
  Result.Serie := '';
  Result.Validade := '';
  
  if Trim(ALinha) = '' then
    Exit;
    
  // Formato esperado: "Nome | Serie: XXXXX | Validade: DD/MM/YYYY"
  
  // Extrai Nome (até o primeiro |)
  Pos1 := Pos('|', ALinha);
  if Pos1 > 0 then
    Result.Nome := Trim(Copy(ALinha, 1, Pos1 - 1))
  else
  begin
    Result.Nome := Trim(ALinha);
    Exit;
  end;
  
  // Extrai Serie
  Temp := Copy(ALinha, Pos1 + 1, Length(ALinha));
  if Pos('Serie:', Temp) > 0 then
  begin
    Temp := Copy(Temp, Pos(':', Temp) + 1, Length(Temp));
    Pos2 := Pos('|', Temp);
    if Pos2 > 0 then
      Result.Serie := Trim(Copy(Temp, 1, Pos2 - 1))
    else
      Result.Serie := Trim(Temp);
  end;
  
  // Extrai Validade (se existir)
  if Pos('Validade:', ALinha) > 0 then
  begin
    Temp := Copy(ALinha, Pos('Validade:', ALinha), Length(ALinha));
    Temp := Copy(Temp, Pos(':', Temp) + 1, Length(Temp));
    Result.Validade := Trim(Temp);
  end;
end;
end.
