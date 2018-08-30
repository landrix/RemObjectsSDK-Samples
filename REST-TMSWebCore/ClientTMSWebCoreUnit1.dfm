object Form1: TForm1
  Left = 0
  Top = 0
  Width = 640
  Height = 480
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  TabOrder = 1
  OnCreate = WebFormCreate
  object WebLabel1: TWebLabel
    Left = 240
    Top = 53
    Width = 44
    Height = 13
    Caption = 'Calculate'
    Transparent = True
  end
  object WebLabel2: TWebLabel
    Left = 240
    Top = 72
    Width = 6
    Height = 13
    Caption = 'a'
    Transparent = True
  end
  object WebLabel3: TWebLabel
    Left = 240
    Top = 96
    Width = 6
    Height = 13
    Caption = 'b'
    Transparent = True
  end
  object WebLabel4: TWebLabel
    Left = 240
    Top = 152
    Width = 27
    Height = 13
    Caption = 'result'
    Transparent = True
  end
  object WebLoginPanel1: TWebLoginPanel
    Left = 24
    Top = 24
    Width = 185
    Height = 155
    CaptionLabel = 'Login'
    LoginLabel = 'Login'
    PasswordLabel = 'Password:'
    UserLabel = 'User:'
    OnClick = WebLoginPanel1Click
  end
  object WebSpinEdit1: TWebSpinEdit
    Left = 320
    Top = 72
    Width = 150
    Height = 22
    AutoSize = False
    BorderStyle = bsSingle
    Color = clWhite
    Increment = 1
    MaxValue = 100
    MinValue = 0
    TabOrder = 1
    Value = 0
  end
  object WebSpinEdit2: TWebSpinEdit
    Left = 320
    Top = 96
    Width = 150
    Height = 22
    AutoSize = False
    BorderStyle = bsSingle
    Color = clWhite
    Increment = 1
    MaxValue = 100
    MinValue = 0
    TabOrder = 2
    Value = 0
  end
  object WebButton1: TWebButton
    Left = 328
    Top = 124
    Width = 96
    Height = 25
    Caption = 'Calculate'
    TabOrder = 3
    OnClick = WebButton1Click
  end
  object WebMemo1: TWebMemo
    Left = 320
    Top = 155
    Width = 185
    Height = 89
    AutoSize = False
    Lines.Strings = (
      'WebMemo1')
    SelLength = 0
    SelStart = 0
    TabOrder = 4
  end
  object WebRESTClient1: TWebRESTClient
    OnResponse = WebRESTClient1Response
    Left = 264
    Top = 256
  end
  object WebHttpRequest1: TWebHttpRequest
    Headers.Strings = (
      'Cache-Control=no-cache')
    OnResponse = WebRESTClient1Response
    OnRequestResponse = WebHttpRequest1RequestResponse
    Left = 344
    Top = 264
  end
end
