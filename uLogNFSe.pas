unit uLogNFSe;

interface

uses
  SysUtils, Classes, StdCtrls, Windows, Messages;

type
  TLogNFSe = class
  private
    FArquivoLog: string;
    FMemoLog: TStrings;
    procedure GravarArquivo(const ATexto: string);
    function CensurarDadosSensiveis(const ATexto: string): string;
  public
    constructor Create(AMemoLog: TStrings; const APastaLog: string);
    procedure Log(const ATexto: string);
    procedure LogSeparador;
    procedure LogSecao(const ATitulo: string);
    procedure LogErro(const ATexto: string);
    procedure LogSucesso(const ATexto: string);
    procedure LogAviso(const ATexto: string);
    procedure LogConfiguracao(const ASecao, AChave, AValor: string);
  end;

implementation

{ TLogNFSe }

constructor TLogNFSe.Create(AMemoLog: TStrings; const APastaLog: string);
var
  NomeArq: string;
begin
  FMemoLog := AMemoLog;
  
  // Criar pasta de log se não existir
  if not DirectoryExists(APastaLog) then
    ForceDirectories(APastaLog);
  
  // Nome do arquivo: Log_AAAAMMDD_HHNNSS.txt
  NomeArq := 'Log_' + FormatDateTime('YYYYMMDD_HHNNSS', Now) + '.txt';
  FArquivoLog := APastaLog + '\' + NomeArq;
end;

function TLogNFSe.CensurarDadosSensiveis(const ATexto: string): string;
var
  Temp: string;
  Pos1, Pos2: Integer;
begin
  Result := ATexto;
  
  // Censurar senhas
  if (Pos('senha', LowerCase(Result)) > 0) or 
     (Pos('password', LowerCase(Result)) > 0) then
  begin
    // Procurar padrão: Senha] = "valor"
    Pos1 := Pos('= "', Result);
    if Pos1 > 0 then
    begin
      // Buscar próximo " após Pos1 + 3
      Temp := Copy(Result, Pos1 + 3, Length(Result));
      Pos2 := Pos('"', Temp);
      if Pos2 > 0 then
      begin
        Temp := Copy(Temp, 1, Pos2 - 1);
        if Length(Temp) > 0 then
          Result := StringReplace(Result, Temp, '***CENSURADO***', [rfReplaceAll]);
      end;
    end;
    
    // Procurar padrão: senha: valor
    if Pos(':', Result) > 0 then
    begin
      Pos1 := Pos(':', Result);
      Temp := Trim(Copy(Result, Pos1 + 1, Length(Result)));
      if (Length(Temp) > 0) and (Length(Temp) < 50) then
        Result := Copy(Result, 1, Pos1) + ' ***CENSURADO***';
    end;
  end;
  
  // Censurar certificado (mostrar só inicio e fim)
  if (Pos('certificado', LowerCase(Result)) > 0) or
     (Pos('.pfx', LowerCase(Result)) > 0) then
  begin
    Pos1 := Pos('.pfx', LowerCase(Result));
    if Pos1 > 0 then
    begin
      // Mostrar só o nome do arquivo, não o caminho completo
      Pos2 := Pos1;
      while (Pos2 > 0) and (Result[Pos2] <> '\') do
        Dec(Pos2);
      if Pos2 > 0 then
      begin
        Temp := Copy(Result, 1, Pos2) + '***\' + Copy(Result, Pos2 + 1, 20) + '...';
        Result := Temp;
      end;
    end;
  end;
  
  // Censurar CPF (manter só os 3 primeiros dígitos)
  Temp := Result;
  while Pos('CPF', UpperCase(Temp)) > 0 do
  begin
    Pos1 := Pos('CPF', UpperCase(Temp));
    // Procurar sequência de 11 dígitos
    Pos2 := Pos1 + 3;
    while (Pos2 <= Length(Temp)) and not (Temp[Pos2] in ['0'..'9']) do
      Inc(Pos2);
    
    if Pos2 <= Length(Temp) then
    begin
      Pos1 := Pos2;
      Pos2 := Pos1;
      while (Pos2 <= Length(Temp)) and (Temp[Pos2] in ['0'..'9', '.', '-']) do
        Inc(Pos2);
      
      if Pos2 - Pos1 >= 11 then
      begin
        // Censurar do 4º dígito em diante
        Result := Copy(Result, 1, Pos1 + 2) + '.***.***-**';
        Break;
      end;
    end;
    
    Temp := Copy(Temp, Pos1 + 3, Length(Temp));
  end;
end;

procedure TLogNFSe.GravarArquivo(const ATexto: string);
var
  F: TextFile;
  TextoCensurado: string;
begin
  TextoCensurado := CensurarDadosSensiveis(ATexto);
  
  try
    AssignFile(F, FArquivoLog);
    if FileExists(FArquivoLog) then
      Append(F)
    else
      Rewrite(F);
    
    try
      WriteLn(F, TextoCensurado);
    finally
      CloseFile(F);
    end;
  except
    // Se falhar ao gravar, continua (não trava a aplicação)
  end;
end;

procedure TLogNFSe.Log(const ATexto: string);
var
  Linha: string;
begin
  Linha := FormatDateTime('[hh:nn:ss] ', Now) + ATexto;
  
  if Assigned(FMemoLog) then
  begin
    FMemoLog.Add(Linha);
    // Auto-scroll
//    if FMemoLog is TMemo then
//      TMemo(FMemoLog).Perform(EM_SCROLLCARET, 0, 0);
  end;
  
  GravarArquivo(Linha);
end;

procedure TLogNFSe.LogSeparador;
begin
  Log('');
  Log('================================================');
  Log('');
end;

procedure TLogNFSe.LogSecao(const ATitulo: string);
begin
  Log('');
  Log('=== ' + UpperCase(ATitulo) + ' ===');
  Log('');
end;

procedure TLogNFSe.LogErro(const ATexto: string);
begin
  Log('? ERRO: ' + ATexto);
end;

procedure TLogNFSe.LogSucesso(const ATexto: string);
begin
  Log('? SUCESSO: ' + ATexto);
end;

procedure TLogNFSe.LogAviso(const ATexto: string);
begin
  Log('? AVISO: ' + ATexto);
end;

procedure TLogNFSe.LogConfiguracao(const ASecao, AChave, AValor: string);
var
  ValorExibir: string;
begin
  ValorExibir := AValor;
  
  // Censurar valores sensíveis
  if (Pos('senha', LowerCase(AChave)) > 0) or
     (Pos('password', LowerCase(AChave)) > 0) then
    ValorExibir := '***CENSURADO***';
  
  Log('Config [' + ASecao + '/' + AChave + '] = "' + ValorExibir + '"');
end;

end.
