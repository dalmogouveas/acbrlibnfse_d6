unit uCertificadoHelper;

{===============================================================================
  Unit: uCertificadoHelper
  Descricao: Funcoes auxiliares para listar e manipular certificados
  Autor: Dalmo Gouveas
  Data: 27/01/2026
===============================================================================}

interface

uses
  SysUtils, Classes;

type
  TCertificadoInfo = record
    NomeCertificado: string;
    NumeroSerie: string;
    Validade: string;
    LinhaCompleta: string;
  end;

  TCertificadoList = array of TCertificadoInfo;

function ListarCertificados(const AResultado: string): TCertificadoList;
function ExtrairNumeroSerie(const ALinha: string): string;
function FormatarParaComboBox(const ACertList: TCertificadoList): TStringList;
function ObterInfoCertificado(const ALinha: string): TCertificadoInfo;

implementation

{===============================================================================
  Funcao: ListarCertificados
  Descricao: Converte o resultado do NFSE_ObterCertificados em array estruturado
  Parametros:
    AResultado: String retornada pela DLL (linhas separadas por #13#10)
  Retorno: Array de TCertificadoInfo
===============================================================================}
function ListarCertificados(const AResultado: string): TCertificadoList;
var
  Lista: TStringList;
  I: Integer;
begin
  SetLength(Result, 0);
  
  if Trim(AResultado) = '' then
    Exit;
    
  Lista := TStringList.Create;
  try
    Lista.Text := AResultado;
    
    SetLength(Result, Lista.Count);
    
    for I := 0 to Lista.Count - 1 do begin
      if Trim(Lista[I]) <> '' then
        Result[I] := ObterInfoCertificado(Lista[I]);
    end;
  finally
    Lista.Free;
  end;
end;

{===============================================================================
  Funcao: ExtrairNumeroSerie
  Descricao: Extrai o numero de serie da linha do certificado
  Formato esperado: "Nome do Certificado | Serie: XXXXXXXX | Validade: DD/MM/YYYY"
  Parametros:
    ALinha: Linha do certificado
  Retorno: Numero de serie (apenas os caracteres)
===============================================================================}
function ExtrairNumeroSerie(const ALinha: string): string;
var
  PosInicio, PosFim: Integer;
  Temp: string;
begin
  Result := '';
  
  // Procura por "Serie:" ou "Serial:" ou "S/N:"
  PosInicio := Pos('Serie:', ALinha);
  if PosInicio = 0 then
    PosInicio := Pos('Serial:', ALinha);
  if PosInicio = 0 then
    PosInicio := Pos('S/N:', ALinha);
    
  if PosInicio > 0 then
  begin
    // Pula ate o : e espacos
    Temp := Copy(ALinha, PosInicio, Length(ALinha));
    PosInicio := Pos(':', Temp) + 1;
    Temp := Copy(Temp, PosInicio, Length(Temp));
    Temp := Trim(Temp);
    
    // Pega ate o proximo | ou fim da linha
    PosFim := Pos('|', Temp);
    if PosFim > 0 then
      Result := Trim(Copy(Temp, 1, PosFim - 1))
    else
      Result := Trim(Temp);
  end;
end;

{===============================================================================
  Funcao: ObterInfoCertificado
  Descricao: Extrai todas as informacoes de uma linha de certificado
  Parametros:
    ALinha: Linha completa do certificado
  Retorno: Record com informacoes estruturadas
===============================================================================}
function ObterInfoCertificado(const ALinha: string): TCertificadoInfo;
var
  PosDiv1, PosDiv2: Integer;
  Temp: string;
begin
  Result.LinhaCompleta := ALinha;
  Result.NumeroSerie := ExtrairNumeroSerie(ALinha);
  
  // Tenta extrair nome (ate o primeiro |)
  PosDiv1 := Pos('|', ALinha);
  if PosDiv1 > 0 then
  begin
    Result.NomeCertificado := Trim(Copy(ALinha, 1, PosDiv1 - 1));
    
    // Tenta extrair validade (ultimo campo apos |)
    Temp := Copy(ALinha, PosDiv1 + 1, Length(ALinha));
    PosDiv2 := Pos('|', Temp);
    if PosDiv2 > 0 then
    begin
      Temp := Copy(Temp, PosDiv2 + 1, Length(Temp));
      // Remove "Validade:" se existir
      if Pos('Validade:', Temp) > 0 then
        Temp := StringReplace(Temp, 'Validade:', '', [rfIgnoreCase]);
      Result.Validade := Trim(Temp);
    end;
  end
  else
    Result.NomeCertificado := ALinha;
end;

{===============================================================================
  Funcao: FormatarParaComboBox
  Descricao: Formata a lista de certificados para exibicao em ComboBox
  Parametros:
    ACertList: Array de certificados
  Retorno: TStringList com descricoes formatadas
===============================================================================}
function FormatarParaComboBox(const ACertList: TCertificadoList): TStringList;
var
  I: Integer;
  Descricao: string;
begin
  Result := TStringList.Create;
  
  for I := 0 to High(ACertList) do
  begin
    if ACertList[I].Validade <> '' then
      Descricao := Format('%s - Serie: %s - Val: %s', [
        ACertList[I].NomeCertificado,
        ACertList[I].NumeroSerie,
        ACertList[I].Validade
      ])
    else
      Descricao := Format('%s - Serie: %s', [
        ACertList[I].NomeCertificado,
        ACertList[I].NumeroSerie
      ]);
      
    Result.AddObject(Descricao, TObject(I));
  end;
end;

end.
