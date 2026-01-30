object FrmTesteNFSeEscola: TFrmTesteNFSeEscola
  Left = 192
  Top = 107
  Width = 1024
  Height = 700
  Caption = 'Teste de Emiss'#227'o NFS-e Nacional - Escola'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  object PageControl1: TPageControl
    Left = 0
    Top = 0
    Width = 1008
    Height = 662
    ActivePage = TabConfig
    Align = alClient
    TabIndex = 0
    TabOrder = 0
    object TabConfig: TTabSheet
      Caption = '1. Configura'#231#227'o'
      object GroupDadosEscola: TGroupBox
        Left = 8
        Top = 8
        Width = 977
        Height = 145
        Caption = ' Dados da Escola (Prestador) '
        TabOrder = 0
        object Label1: TLabel
          Left = 16
          Top = 15
          Width = 30
          Height = 13
          Caption = 'CNPJ:'
        end
        object Label2: TLabel
          Left = 16
          Top = 56
          Width = 94
          Height = 13
          Caption = 'Inscri'#231#227'o Municipal:'
        end
        object Label3: TLabel
          Left = 16
          Top = 98
          Width = 66
          Height = 13
          Caption = 'Raz'#227'o Social:'
        end
        object Label4: TLabel
          Left = 400
          Top = 15
          Width = 86
          Height = 13
          Caption = 'C'#243'digo Munic'#237'pio:'
        end
        object Label5: TLabel
          Left = 400
          Top = 56
          Width = 17
          Height = 13
          Caption = 'UF:'
        end
        object Label6: TLabel
          Left = 400
          Top = 98
          Width = 27
          Height = 13
          Caption = 'S'#233'rie:'
        end
        object Label7: TLabel
          Left = 544
          Top = 15
          Width = 47
          Height = 13
          Caption = 'Ambiente:'
        end
        object edtCNPJEscola: TEdit
          Left = 16
          Top = 31
          Width = 200
          Height = 21
          TabOrder = 0
          Text = '02906540000164'
        end
        object edtInscMunEscola: TEdit
          Left = 16
          Top = 72
          Width = 200
          Height = 21
          TabOrder = 1
          Text = '36166639'
        end
        object edtRazaoSocialEscola: TEdit
          Left = 16
          Top = 114
          Width = 360
          Height = 21
          TabOrder = 2
          Text = 'INFO IDEIAS SOFTWARE E CONSULTORIA LTDA'
        end
        object edtCodMunicipio: TEdit
          Left = 400
          Top = 31
          Width = 120
          Height = 21
          TabOrder = 3
          Text = '3304557'
        end
        object cbUF: TComboBox
          Left = 400
          Top = 72
          Width = 120
          Height = 21
          Style = csDropDownList
          ItemHeight = 13
          TabOrder = 4
          Items.Strings = (
            'AC'
            'AL'
            'AP'
            'AM'
            'BA'
            'CE'
            'DF'
            'ES'
            'GO'
            'MA'
            'MT'
            'MS'
            'MG'
            'PA'
            'PB'
            'PR'
            'PE'
            'PI'
            'RJ'
            'RN'
            'RS'
            'RO'
            'RR'
            'SC'
            'SP'
            'SE'
            'TO')
        end
        object edtSerie: TEdit
          Left = 400
          Top = 114
          Width = 120
          Height = 21
          TabOrder = 5
          Text = 'UNICA'
        end
        object cbAmbiente: TComboBox
          Left = 544
          Top = 31
          Width = 145
          Height = 21
          Style = csDropDownList
          ItemHeight = 13
          TabOrder = 6
          Items.Strings = (
            'Produ'#231#227'o'
            'Homologa'#231#227'o')
        end
      end
      object GroupCertificado: TGroupBox
        Left = 8
        Top = 159
        Width = 977
        Height = 157
        Caption = ' Certificado Digital (OBRIGAT'#211'RIO) '
        TabOrder = 1
        object Label8: TLabel
          Left = 16
          Top = 18
          Width = 77
          Height = 13
          Caption = 'Tipo Certificado:'
        end
        object Label9: TLabel
          Left = 16
          Top = 60
          Width = 97
          Height = 13
          Caption = 'Caminho Certificado:'
        end
        object Label10: TLabel
          Left = 16
          Top = 101
          Width = 34
          Height = 13
          Caption = 'Senha:'
        end
        object lblListaCerts: TLabel
          Left = 661
          Top = 59
          Width = 109
          Height = 13
          Caption = 'Certificados Instalados:'
        end
        object lblNumCert: TLabel
          Left = 663
          Top = 110
          Width = 79
          Height = 13
          Caption = 'N'#250'mero de S'#233'rie'
        end
        object Bevel1: TBevel
          Left = 639
          Top = 15
          Width = 7
          Height = 136
        end
        object rbCertPFX: TRadioButton
          Left = 16
          Top = 35
          Width = 161
          Height = 17
          Caption = 'Arquivo PFX (A1)'
          TabOrder = 0
          OnClick = rbCertPFXClick
        end
        object rbCertWinStore: TRadioButton
          Left = 200
          Top = 35
          Width = 217
          Height = 17
          Caption = 'Windows Store (Certificado Instalado)'
          Checked = True
          TabOrder = 1
          TabStop = True
          OnClick = rbCertWinStoreClick
        end
        object edtCertPath: TEdit
          Left = 16
          Top = 76
          Width = 520
          Height = 21
          TabOrder = 2
        end
        object btnSelecionarCert: TButton
          Left = 544
          Top = 74
          Width = 75
          Height = 25
          Caption = '...'
          TabOrder = 3
          OnClick = btnSelecionarCertClick
        end
        object edtCertSenha: TEdit
          Left = 16
          Top = 117
          Width = 200
          Height = 21
          PasswordChar = '*'
          TabOrder = 4
        end
        object btnTestarCert: TButton
          Left = 224
          Top = 115
          Width = 120
          Height = 25
          Caption = 'Testar Certificado'
          TabOrder = 5
          OnClick = btnTestarCertClick
        end
        object btnListarCertificados: TButton
          Left = 663
          Top = 18
          Width = 295
          Height = 33
          Caption = 'Listar'
          TabOrder = 6
          OnClick = btnListarCertificadosClick
        end
        object cbCertificados: TComboBox
          Left = 661
          Top = 80
          Width = 294
          Height = 21
          Style = csDropDownList
          ItemHeight = 13
          TabOrder = 7
          OnChange = cbCertificadosChange
        end
        object edtCertSerie: TEdit
          Left = 663
          Top = 126
          Width = 292
          Height = 21
          TabOrder = 8
        end
      end
      object btnInicializar: TButton
        Left = 8
        Top = 319
        Width = 200
        Height = 40
        Caption = 'INICIALIZAR BIBLIOTECA'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'MS Sans Serif'
        Font.Style = [fsBold]
        ParentFont = False
        TabOrder = 2
        OnClick = btnInicializarClick
      end
      object Panel1: TPanel
        Left = 0
        Top = 368
        Width = 1000
        Height = 266
        Align = alBottom
        BevelOuter = bvNone
        TabOrder = 3
        object Label11: TLabel
          Left = 8
          Top = 8
          Width = 190
          Height = 13
          Caption = 'Log de Configura'#231#227'o (scroll autom'#225'tico):'
        end
        object MemoLogConfig: TMemo
          Left = 8
          Top = 24
          Width = 976
          Height = 234
          ScrollBars = ssVertical
          TabOrder = 0
        end
      end
    end
    object TabEmissao: TTabSheet
      Caption = '2. Emiss'#227'o'
      ImageIndex = 1
      object GroupDPS: TGroupBox
        Left = 8
        Top = 8
        Width = 977
        Height = 145
        Caption = ' Carregar DPS (Documento de Presta'#231#227'o de Servi'#231'o) '
        TabOrder = 0
        object Label12: TLabel
          Left = 16
          Top = 19
          Width = 66
          Height = 13
          Caption = 'Formato DPS:'
        end
        object Label13: TLabel
          Left = 16
          Top = 58
          Width = 39
          Height = 13
          Caption = 'Arquivo:'
        end
        object rbDPSIni: TRadioButton
          Left = 16
          Top = 37
          Width = 113
          Height = 17
          Caption = 'Arquivo INI'
          Checked = True
          TabOrder = 0
          TabStop = True
        end
        object rbDPSXml: TRadioButton
          Left = 136
          Top = 37
          Width = 113
          Height = 17
          Caption = 'Arquivo XML'
          TabOrder = 1
        end
        object edtDPSArquivo: TEdit
          Left = 16
          Top = 75
          Width = 520
          Height = 21
          ReadOnly = True
          TabOrder = 2
        end
        object btnSelecionarDPS: TButton
          Left = 544
          Top = 73
          Width = 120
          Height = 25
          Caption = 'Selecionar...'
          Enabled = False
          TabOrder = 3
          OnClick = btnSelecionarDPSClick
        end
        object btnCarregarDPS: TButton
          Left = 672
          Top = 73
          Width = 120
          Height = 25
          Caption = 'Carregar DPS'
          Enabled = False
          TabOrder = 4
          OnClick = btnCarregarDPSClick
        end
        object btnDPSExemploPF: TButton
          Left = 16
          Top = 107
          Width = 150
          Height = 25
          Caption = 'Usar Exemplo PF'
          Enabled = False
          TabOrder = 5
          OnClick = btnDPSExemploPFClick
        end
        object btnDPSExemploPJ: TButton
          Left = 176
          Top = 107
          Width = 150
          Height = 25
          Caption = 'Usar Exemplo PJ'
          Enabled = False
          TabOrder = 6
          OnClick = btnDPSExemploPJClick
        end
      end
      object GroupEmissao: TGroupBox
        Left = 8
        Top = 160
        Width = 977
        Height = 145
        Caption = ' Emiss'#227'o da NFS-e '
        TabOrder = 1
        object Label14: TLabel
          Left = 16
          Top = 21
          Width = 79
          Height = 13
          Caption = 'N'#250'mero do Lote:'
        end
        object Label15: TLabel
          Left = 16
          Top = 64
          Width = 75
          Height = 13
          Caption = 'Modo de Envio:'
        end
        object edtNumeroLote: TEdit
          Left = 16
          Top = 37
          Width = 120
          Height = 21
          TabOrder = 0
          Text = '1'
        end
        object cbModoEnvio: TComboBox
          Left = 16
          Top = 80
          Width = 200
          Height = 21
          Style = csDropDownList
          ItemHeight = 13
          TabOrder = 1
          Items.Strings = (
            'Autom'#225'tico'
            'Lote Ass'#237'ncrono'
            'S'#237'ncrono (Padr'#227'o Nacional)'
            'Unit'#225'rio'
            'Teste')
        end
        object btnEmitir: TButton
          Left = 16
          Top = 112
          Width = 200
          Height = 25
          Caption = 'EMITIR NFS-e'
          Enabled = False
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'MS Sans Serif'
          Font.Style = [fsBold]
          ParentFont = False
          TabOrder = 2
          OnClick = btnEmitirClick
        end
      end
      object Panel2: TPanel
        Left = 0
        Top = 320
        Width = 1000
        Height = 314
        Align = alBottom
        BevelOuter = bvNone
        TabOrder = 2
        object Label16: TLabel
          Left = 8
          Top = 8
          Width = 166
          Height = 13
          Caption = 'Log de Emiss'#227'o (scroll autom'#225'tico):'
        end
        object MemoLogEmissao: TMemo
          Left = 8
          Top = 24
          Width = 976
          Height = 282
          ScrollBars = ssVertical
          TabOrder = 0
        end
      end
    end
    object TabAjuda: TTabSheet
      Caption = '3. Ajuda'
      ImageIndex = 2
      object Memo1: TMemo
        Left = 0
        Top = 0
        Width = 1000
        Height = 634
        Align = alClient
        Ctl3D = True
        Lines.Strings = (
          'TESTE DE EMISS'#195'O NFS-e NACIONAL - ESCOLA'
          '========================================='
          ''
          
            'IMPORTANTE: Este '#233' um programa de TESTE para valida'#231#227'o da emiss'#227 +
            'o.'
          'Antes de usar em PRODU'#195'O, certifique-se de:'
          ''
          '1. CERTIFICADO DIGITAL'
          '   - Usar o certificado A1 do CNPJ da ESCOLA'
          '   - Verificar se a senha est'#225' correta'
          ''
          '2. CREDENCIAMENTO'
          '   - Escola deve estar cadastrada no sistema nacional'
          '   - Ambiente de homologa'#231#227'o deve estar liberado'
          '   - IM (Inscri'#231#227'o Municipal) deve estar regularizada'
          ''
          '3. CONFIGURA'#195'O'
          '   - Preencher todos os dados da escola'
          '   - Verificar c'#243'digo do munic'#237'pio (3304557 = Rio de Janeiro)'
          '   - Confirmar ambiente (Homologa'#231#227'o para testes)'
          ''
          '4. DPS DE TESTE'
          '   - Use os exemplos fornecidos (PF ou PJ)'
          '   - Ou crie seu pr'#243'prio arquivo seguindo o modelo'
          '   - Verificar se os c'#243'digos de servi'#231'o est'#227'o corretos:'
          '     * 080102 = Ensino Fundamental'
          '     * 080101 = Pr'#233'-escola/Maternal'
          '     * 080103 = Ensino M'#233'dio'
          '     * 041702 = Creche'
          ''
          '5. MODO DE ENVIO'
          '   - Para Padr'#227'o Nacional: usar "S'#237'ncrono"'
          '   - N'#195'O usar "Autom'#225'tico" (pode dar erro)'
          ''
          '6. LOGS'
          '   - Todos os logs s'#227'o gravados na pasta "logs"'
          '   - XMLs s'#227'o salvos automaticamente'
          '   - Ao final enviar a pasta "logs" completa'
          ''
          '7. SUPORTE'
          
            '   - Erros de "Servi'#231'o n'#227'o implementado": verificar modo de envi' +
            'o'
          '   - Erros de certificado: verificar se '#233' o certificado correto'
          '   - Erros de credenciamento: verificar no portal nacional'
          ''
          'ARQUIVOS INCLU'#205'DOS:'
          
            '- DPS_Escola_TomadorPF.ini / .xml = Exemplo com tomador pessoa f' +
            #237'sica'
          
            '- DPS_Escola_TomadorPJ.ini / .xml = Exemplo com tomador pessoa j' +
            'ur'#237'dica'
          ''
          'PASSOS PARA TESTAR:'
          '1. Aba "Configura'#231#227'o":'
          '   - Preencher dados da escola'
          '   - Selecionar certificado digital'
          '   - Clicar em "Inicializar Biblioteca"'
          ''
          '2. Aba "Emiss'#227'o":'
          '   - Selecionar formato (INI ou XML)'
          '   - Carregar DPS de exemplo ou pr'#243'prio'
          '   - Verificar modo de envio (S'#237'ncrono)'
          '   - Clicar em "Emitir NFS-e"'
          ''
          '3. Verificar logs e XMLs gerados'
          ''
          'Em caso de d'#250'vidas, consultar o arquivo LEIA-ME.txt')
        ParentCtl3D = False
        ReadOnly = True
        ScrollBars = ssVertical
        TabOrder = 0
      end
    end
  end
  object OpenDialog1: TOpenDialog
    Filter = 'Certificado PFX (*.pfx)|*.pfx|Todos os arquivos (*.*)|*.*'
    Title = 'Selecionar Certificado Digital'
    Left = 920
    Top = 8
  end
  object OpenDialog2: TOpenDialog
    Filter = 
      'Arquivo INI (*.ini)|*.ini|Arquivo XML (*.xml)|*.xml|Todos os arq' +
      'uivos (*.*)|*.*'
    Title = 'Selecionar DPS'
    Left = 920
    Top = 40
  end
end
