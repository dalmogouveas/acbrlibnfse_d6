unit uTesteRapidoNFSe;

interface

uses
  Windows, SysUtils, Classes;

// Teste mínimo para validar se o XML está correto
procedure TestarCarregamentoXML(const ACaminhoXML: string; AMemoLog: TStrings);

function GetFileSize(const AFileName: string): Word;

implementation

uses
  uACBrNFSeLib;

procedure TestarCarregamentoXML(const ACaminhoXML: string; AMemoLog: TStrings);
var
  Ret: Integer;
  BufferLen: Integer;
  Buffer: PAnsiChar;
begin
  AMemoLog.Add('====================================');
  AMemoLog.Add('TESTE RÁPIDO DE CARREGAMENTO XML');
  AMemoLog.Add('====================================');
  AMemoLog.Add('');
  
  // 1. Verificar se arquivo existe
  AMemoLog.Add('1. Verificando arquivo...');
  AMemoLog.Add('   Caminho: ' + ACaminhoXML);
  
  if not FileExists(ACaminhoXML) then begin
    AMemoLog.Add('   ? ERRO: Arquivo não encontrado!');
    Exit;
  end;
  
  AMemoLog.Add('   ? Arquivo existe');
  AMemoLog.Add('');

  // 2. Verificar tamanho do arquivo
  AMemoLog.Add('2. Informações do arquivo...');
  AMemoLog.Add('   Tamanho: ' + IntToStr(GetFileSize(ACaminhoXML)) + ' bytes');
  AMemoLog.Add('');

  // 3. Limpar lista
  AMemoLog.Add('3. Limpando lista anterior...');
  if Assigned(NFSE_LimparLista) then begin
    Ret := NFSE_LimparLista;
    AMemoLog.Add('   Retorno: ' + IntToStr(Ret));
  end else
    AMemoLog.Add('   ? NFSE_LimparLista não está carregada!');
  
  AMemoLog.Add('');
  
  // 4. Tentar carregar XML
  AMemoLog.Add('4. Carregando XML...');
  
  if not Assigned(NFSE_CarregarXML) then begin
    AMemoLog.Add('   ? ERRO: NFSE_CarregarXML não está carregada!');
    Exit;
  end;
  
  Ret := NFSE_CarregarXML(PAnsiChar(AnsiString(ACaminhoXML)));
  AMemoLog.Add('   Retorno: ' + IntToStr(Ret));
  AMemoLog.Add('');
  
  // 5. Analisar resultado
  if Ret = 0 then begin
    AMemoLog.Add('====================================');
    AMemoLog.Add('??? SUCESSO! ???');
    AMemoLog.Add('====================================');
    AMemoLog.Add('');
    AMemoLog.Add('O XML foi carregado com sucesso!');
    AMemoLog.Add('Agora você pode tentar emitir.');
  end else begin
    AMemoLog.Add('====================================');
    AMemoLog.Add('??? ERRO! ???');
    AMemoLog.Add('====================================');
    AMemoLog.Add('');
    AMemoLog.Add('Código do erro: ' + IntToStr(Ret));

    // Buscar mensagem de erro detalhada
    if Assigned(NFSE_UltimoRetorno) then begin
      BufferLen := 0;
      NFSE_UltimoRetorno(nil, BufferLen);
      
      if BufferLen > 0 then begin
        GetMem(Buffer, BufferLen);
        try
          FillChar(Buffer^, BufferLen, 0);
          NFSE_UltimoRetorno(Buffer, BufferLen);
          AMemoLog.Add('');
          AMemoLog.Add('Detalhes do erro:');
          AMemoLog.Add(string(AnsiString(Buffer)));
        finally
          FreeMem(Buffer);
        end;
      end;
    end;

    AMemoLog.Add('');
    AMemoLog.Add('====================================');
    AMemoLog.Add('DIAGNÓSTICO');
    AMemoLog.Add('====================================');

    case Ret of
      -10: begin
        AMemoLog.Add('Erro -10 = Validação de Schema XML');
        AMemoLog.Add('');
        AMemoLog.Add('Causas comuns:');
        AMemoLog.Add('• XML no formato antigo (municipal)');
        AMemoLog.Add('• Campos obrigatórios faltando');
        AMemoLog.Add('• Tags com nomes incorretos');
        AMemoLog.Add('• Estrutura hierárquica errada');
        AMemoLog.Add('• Schemas XSD não encontrados');
        AMemoLog.Add('');
        AMemoLog.Add('SOLUÇÃO:');
        AMemoLog.Add('Use o XML corrigido fornecido:');
        AMemoLog.Add('dps_pf.xml');
      end;

      -6: begin
        AMemoLog.Add('Erro -6 = Erro na biblioteca');
        AMemoLog.Add('');
        AMemoLog.Add('Causas comuns:');
        AMemoLog.Add('• DLL corrompida ou incompatível');
        AMemoLog.Add('• Falta de dependências (OpenSSL, LibXML2)');
        AMemoLog.Add('• Certificado inválido');
        AMemoLog.Add('');
        AMemoLog.Add('SOLUÇÃO:');
        AMemoLog.Add('Reinstale a DLL e dependências');
      end;

      -3: begin
        AMemoLog.Add('Erro -3 = Parâmetro inválido');
        AMemoLog.Add('');
        AMemoLog.Add('Causas comuns:');
        AMemoLog.Add('• Caminho do arquivo incorreto');
        AMemoLog.Add('• Arquivo vazio ou corrompido');
        AMemoLog.Add('• Encoding incorreto');
        AMemoLog.Add('');
        AMemoLog.Add('SOLUÇÃO:');
        AMemoLog.Add('Verifique o caminho e o conteúdo do arquivo');
      end;
    else
      AMemoLog.Add('Erro desconhecido: ' + IntToStr(Ret));
      AMemoLog.Add('Consulte a documentação do ACBrLib');
    end;
  end;

  AMemoLog.Add('');
  AMemoLog.Add('====================================');
  AMemoLog.Add('FIM DO TESTE');
  AMemoLog.Add('====================================');
end;

function GetFileSize(const AFileName: string): Word;
var
  SearchRec: TSearchRec;
begin
  Result := 0;
  if FindFirst(AFileName, faAnyFile, SearchRec) = 0 then begin
    Result := SearchRec.Size;
    FindClose(SearchRec);
  end;
end;

end.
