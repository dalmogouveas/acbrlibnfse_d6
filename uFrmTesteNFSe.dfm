object FrmTesteNFSe: TFrmTesteNFSe
  Left = 192
  Top = 124
  Width = 1088
  Height = 563
  Caption = 'Teste biblioteca NFSe'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 1072
    Height = 57
    Align = alTop
    BevelOuter = bvNone
    TabOrder = 0
    object btnInicializar: TButton
      Left = 6
      Top = 6
      Width = 112
      Height = 46
      Caption = 'Inicializar'
      TabOrder = 0
      OnClick = btnInicializarClick
    end
    object btnNome: TButton
      Left = 120
      Top = 6
      Width = 112
      Height = 46
      Caption = 'Nome'
      Enabled = False
      TabOrder = 1
      OnClick = btnNomeClick
    end
    object btnVersao: TButton
      Left = 235
      Top = 6
      Width = 112
      Height = 46
      Caption = 'Vers'#227'o'
      Enabled = False
      TabOrder = 2
      OnClick = btnVersaoClick
    end
    object btnConsultarSituacao: TButton
      Left = 352
      Top = 6
      Width = 112
      Height = 46
      Caption = 'Consultar Situa'#231#227'o'
      Enabled = False
      TabOrder = 3
      OnClick = btnConsultarSituacaoClick
    end
    object btnCarregarXML: TButton
      Left = 472
      Top = 6
      Width = 112
      Height = 46
      Caption = 'Carregar XML'
      Enabled = False
      TabOrder = 4
      OnClick = btnCarregarXMLClick
    end
    object btnEmitir: TButton
      Left = 699
      Top = 6
      Width = 112
      Height = 46
      Caption = 'Emitir'
      Enabled = False
      TabOrder = 5
      OnClick = btnEmitirClick
    end
    object btnCarregarINI: TButton
      Left = 586
      Top = 6
      Width = 112
      Height = 46
      Caption = 'Carregar INI'
      Enabled = False
      TabOrder = 6
      OnClick = btnCarregarINIClick
    end
  end
  object MemoLog: TMemo
    Left = 0
    Top = 57
    Width = 887
    Height = 468
    Align = alClient
    ScrollBars = ssVertical
    TabOrder = 1
    OnKeyUp = MemoLogKeyUp
  end
  object Panel2: TPanel
    Left = 887
    Top = 57
    Width = 185
    Height = 468
    Align = alRight
    BevelOuter = bvNone
    TabOrder = 2
    object GroupCert: TGroupBox
      Left = 0
      Top = 0
      Width = 185
      Height = 265
      Align = alTop
      Caption = 'Certificado'
      TabOrder = 0
      object lblCertSerie: TLabel
        Left = 8
        Top = 42
        Width = 80
        Height = 13
        Caption = 'N'#250'mero de s'#233'rie:'
      end
      object lblPFXPath: TLabel
        Left = 8
        Top = 110
        Width = 44
        Height = 13
        Caption = 'Caminho:'
      end
      object lblPFXSenha: TLabel
        Left = 8
        Top = 154
        Width = 34
        Height = 13
        Caption = 'Senha:'
      end
      object rbCertWinStore: TRadioButton
        Left = 8
        Top = 20
        Width = 169
        Height = 17
        Caption = 'Windows (A1 instalado)'
        TabOrder = 0
      end
      object edtCertSerie: TEdit
        Left = 8
        Top = 58
        Width = 169
        Height = 21
        TabOrder = 1
      end
      object rbCertPFX: TRadioButton
        Left = 8
        Top = 84
        Width = 169
        Height = 17
        Caption = 'Arquivo PFX'
        Checked = True
        TabOrder = 2
        TabStop = True
      end
      object edtPFXPath: TEdit
        Left = 8
        Top = 126
        Width = 169
        Height = 21
        TabOrder = 3
        Text = 
          'D:\Certificado A1 Info Ideias\173049851_INFO_IDEIAS_SOFTWARE_E_C' +
          'ONSULTORIA_LTDA_02906540000164.pfx'
      end
      object edtPFXSenha: TEdit
        Left = 8
        Top = 170
        Width = 169
        Height = 21
        PasswordChar = '*'
        TabOrder = 4
        Text = 'Info24'
      end
      object btnAplicarCert: TButton
        Left = 8
        Top = 202
        Width = 169
        Height = 30
        Caption = 'Aplicar Certificado'
        Enabled = False
        TabOrder = 5
        OnClick = btnAplicarCertClick
      end
    end
    object btnCarregarXMLTeste: TButton
      Left = 2
      Top = 270
      Width = 181
      Height = 55
      Caption = 'Teste de Carregamento XML'
      Enabled = False
      TabOrder = 1
      OnClick = btnCarregarXMLTesteClick
    end
  end
  object Od: TOpenDialog
    DefaultExt = '*.*'
    Filter = 'Todos os arquivos (*.*)|*.*|Arquivo XML (*.xml)|*.xml'
    Title = 'Abrir arquivo para teste de carregamento DPS...'
    Left = 999
    Top = 27
  end
end
