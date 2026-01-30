{===============================================================================
  CÓDIGO EXEMPLO - LISTAR CERTIFICADOS
  
  Este código está pronto para ser copiado no seu formulário.
  
  PASSO 1: Adicionar componentes no formulário
  PASSO 2: Copiar código abaixo
  PASSO 3: Compilar e testar
===============================================================================}

{===============================================================================
  PASSO 1: ADICIONAR COMPONENTES NO .DFM
===============================================================================}

(*
  Adicione dentro do GroupCert, após o btnAplicarCert:

  object lblListaCerts: TLabel
    Left = 8
    Top = 238
    Width = 100
    Height = 13
    Caption = 'Certificados Instalados:'
  end
  
  object btnListarCertificados: TButton
    Left = 8
    Top = 254
    Width = 85
    Height = 25
    Caption = 'Listar'
    TabOrder = 6
    OnClick = btnListarCertificadosClick
  end
  
  object cbCertificados: TComboBox
    Left = 98
    Top = 254
    Width = 279
    Height = 21
    Style = csDropDownList
    TabOrder = 7
    OnChange = cbCertificadosChange
  end
*)

{===============================================================================
  PASSO 2: CÓDIGO PARA ADICIONAR NO .PAS
===============================================================================}

// ===== ADICIONAR NA SEÇÃO TYPE =====

type
  // Estrutura para armazenar info do certificado
  TCertInfo = record
    Nome: string;
    Serie: string;
    Validade: string;
  end;

  TFrmTesteNFSeEscola = class(TForm)
    // ... componentes existentes ...
    btnListarCertificados: TButton;
    cbCertificados: TComboBox;
    lblListaCerts: TLabel;
    
    procedure btnListarCertificadosClick(Sender: TObject);
    procedure cbCertificadosChange(Sender: TObject);
  private
    FListaCerts: array of TCertInfo;
    function ExtrairInfoCert(const ALinha: string): TCertInfo;
  public
    { Public declarations }
  end;

// ===== IMPLEMENTAÇÃO DOS MÉTODOS =====

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

{===============================================================================
  Botão: Listar Certificados
  Busca certificados instalados no Windows Store
===============================================================================}
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
      // *** CHAMA A DLL PARA OBTER CERTIFICADOS ***
      ListaCerts := ObterCertificados;
      
      if Trim(ListaCerts) = '' then
      begin
        LogarMensagem('Nenhum certificado encontrado no Windows Store.');
        ShowMessage('Nenhum certificado encontrado no Windows Store.' + #13#10 +
                    'Verifique se há certificados A1 instalados.');
        Exit;
      end;
      
      // Processa a lista
      Lista := TStringList.Create;
      try
        Lista.Text := ListaCerts;
        
        // Aloca array
        SetLength(FListaCerts, Lista.Count);
        
        // Processa cada linha
        for I := 0 to Lista.Count - 1 do
        begin
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
        
        // Seleciona o primeiro
        if cbCertificados.Items.Count > 0 then
        begin
          cbCertificados.ItemIndex := 0;
          cbCertificadosChange(nil);
          
          LogarMensagem(Format('Certificados encontrados: %d', 
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
    on E: Exception do
    begin
      LogarErro('Erro ao listar certificados', E);
      ShowMessage('Erro ao listar certificados: ' + E.Message);
    end;
  end;
end;

{===============================================================================
  ComboBox: Change
  Quando seleciona um certificado, preenche o número de série automaticamente
===============================================================================}
procedure TFrmTesteNFSeEscola.cbCertificadosChange(Sender: TObject);
var
  Idx: Integer;
begin
  if cbCertificados.ItemIndex < 0 then
    Exit;
    
  try
    // Obtém o índice do certificado
    Idx := Integer(cbCertificados.Items.Objects[cbCertificados.ItemIndex]);
    
    if (Idx >= 0) and (Idx < Length(FListaCerts)) then
    begin
      // *** PREENCHE AUTOMATICAMENTE O NÚMERO DE SÉRIE ***
      edtCertSerie.Text := FListaCerts[Idx].Serie;
      
      // Marca o radio button Windows Store
      rbCertWinStore.Checked := True;
      
      LogarMensagem(Format('Certificado selecionado: %s (Série: %s)', [
        FListaCerts[Idx].Nome,
        FListaCerts[Idx].Serie
      ]));
    end;
    
  except
    on E: Exception do
      LogarErro('Erro ao selecionar certificado', E);
  end;
end;

{===============================================================================
  EXEMPLO DE USO ALTERNATIVO: Listar em um Memo
  
  Se preferir mostrar em um Memo ao invés de ComboBox:
===============================================================================}

(*
procedure TFrmTesteNFSeEscola.btnListarCertificadosClick(Sender: TObject);
var
  ListaCerts: string;
begin
  try
    ListaCerts := ObterCertificados;
    
    if Trim(ListaCerts) = '' then
    begin
      ShowMessage('Nenhum certificado encontrado.');
      Exit;
    end;
    
    // Exibe em um Memo
    MemoCertificados.Lines.Text := ListaCerts;
    
    // Ou em uma mensagem
    ShowMessage('Certificados instalados:'#13#10#13#10 + ListaCerts);
    
  except
    on E: Exception do
      ShowMessage('Erro: ' + E.Message);
  end;
end;
*)

{===============================================================================
  EXEMPLO DE USO: StringGrid
  
  Se preferir mostrar em uma Grid:
===============================================================================}

(*
procedure TFrmTesteNFSeEscola.btnListarCertificadosClick(Sender: TObject);
var
  ListaCerts: string;
  Lista: TStringList;
  I: Integer;
  Info: TCertInfo;
begin
  try
    ListaCerts := ObterCertificados;
    
    if Trim(ListaCerts) = '' then
    begin
      ShowMessage('Nenhum certificado encontrado.');
      Exit;
    end;
    
    Lista := TStringList.Create;
    try
      Lista.Text := ListaCerts;
      
      // Configura Grid
      StringGrid1.RowCount := Lista.Count + 1;
      StringGrid1.ColCount := 3;
      StringGrid1.Cells[0, 0] := 'Nome';
      StringGrid1.Cells[1, 0] := 'Série';
      StringGrid1.Cells[2, 0] := 'Validade';
      
      // Preenche Grid
      for I := 0 to Lista.Count - 1 do
      begin
        Info := ExtrairInfoCert(Lista[I]);
        StringGrid1.Cells[0, I + 1] := Info.Nome;
        StringGrid1.Cells[1, I + 1] := Info.Serie;
        StringGrid1.Cells[2, I + 1] := Info.Validade;
      end;
      
    finally
      Lista.Free;
    end;
    
  except
    on E: Exception do
      ShowMessage('Erro: ' + E.Message);
  end;
end;
*)

{===============================================================================
  NOTAS IMPORTANTES:
  
  1. O método ObterCertificados já está implementado em uACBrNFSeLib.pas
  
  2. A função retorna uma string com linhas separadas por #13#10
  
  3. Cada linha tem o formato:
     "Nome do Certificado | Serie: XXXXX | Validade: DD/MM/YYYY"
  
  4. O separador entre campos é " | " (pipe com espaços)
  
  5. Alguns certificados podem não ter o campo Validade
  
  6. O número de série é o identificador único do certificado
  
  7. A função ExtrairInfoCert é robusta e trata vários formatos
===============================================================================}

{===============================================================================
  TROUBLESHOOTING:
  
  Problema: "Nenhum certificado encontrado"
  Solução: 
    - Verificar se há certificados A1 instalados no Windows
    - Ir em: Painel de Controle > Certificados > Pessoal
    - Deve haver pelo menos 1 certificado instalado
  
  Problema: ComboBox vazio
  Solução:
    - Verificar se a DLL está carregada corretamente
    - Verificar logs para mensagens de erro
    - Testar com ShowMessage(ObterCertificados) direto
  
  Problema: Número de série não preenche
  Solução:
    - Verificar se o evento cbCertificadosChange está conectado
    - Verificar se edtCertSerie existe e está acessível
    - Adicionar breakpoint em cbCertificadosChange
===============================================================================}
