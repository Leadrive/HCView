{*******************************************************}
{                                                       }
{               HCView V1.0  ���ߣ���ͨ                 }
{                                                       }
{      ��������ѭBSDЭ�飬����Լ���QQȺ 649023932      }
{            ����ȡ����ļ������� 2018-5-4              }
{                                                       }
{        �ĵ�CheckBoxItem(��ѡ��)����ʵ�ֵ�Ԫ           }
{                                                       }
{*******************************************************}

unit HCCheckBoxItem;

interface

uses
  Windows, SysUtils, Classes, Controls, Graphics, HCItem, HCRectItem, HCStyle,
  HCCommon;

type
  TCheckBoxItem = class(THCTextRectItem)
  private
    FText: string;
    FChecked, FMouseIn: Boolean;
    function GetBoxRect: TRect;
  protected
    procedure SetChecked(const Value: Boolean);
    //
    procedure MouseEnter; override;
    procedure MouseLeave; override;
    procedure FormatToDrawItem(const AStyle: THCStyle); override;
    procedure DoPaint(const AStyle: THCStyle; const ADrawRect: TRect;
      const ADataDrawBottom, ADataScreenTop, ADataScreenBottom: Integer;
      const ACanvas: TCanvas; const APaintInfo: TPaintInfo); override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure SaveToStream(const AStream: TStream; const AStart, AEnd: Integer); override;
    procedure LoadFromStream(const AStream: TStream; const AStyle: THCStyle;
      const AFileVersion: Word); override;
  public
    constructor Create(const ATextStyleNo: Integer; const AText: string;
      const AChecked: Boolean);
    property Checked: Boolean read FChecked write SetChecked;
    property Text: string read FText write FText;
  end;

implementation

uses
  Math;

{ TCheckBoxItem }

function TCheckBoxItem.GetBoxRect: TRect;
begin
  Result := Classes.Bounds(2, (Height - 16) div 2, 16, 16)
end;

constructor TCheckBoxItem.Create(const ATextStyleNo: Integer; const AText: string;
  const AChecked: Boolean);
begin
  inherited Create;
  FMouseIn := False;
  Self.StyleNo := THCStyle.RsControl;
  FChecked := AChecked;
  TextStyleNo := ATextStyleNo;
  FText := AText;
end;

procedure TCheckBoxItem.DoPaint(const AStyle: THCStyle; const ADrawRect: TRect;
  const ADataDrawBottom, ADataScreenTop, ADataScreenBottom: Integer;
  const ACanvas: TCanvas; const APaintInfo: TPaintInfo);
var
  vBoxRect: TRect;
begin
  inherited;
  vBoxRect := GetBoxRect;
  OffsetRect(vBoxRect, ADrawRect.Left + 2, ADrawRect.Top);

  if Self.IsSelectComplate then
  begin
    ACanvas.Brush.Color := AStyle.SelColor;
    ACanvas.FillRect(ADrawRect);
  end;
  AStyle.TextStyles[TextStyleNo].ApplyStyle(ACanvas);
  ACanvas.TextOut(ADrawRect.Left + 2 + 16 + 2, ADrawRect.Top + (Height - ACanvas.TextHeight('��')) div 2 + 1, FText);

  if FChecked then  // ��ѡ
  begin
    ACanvas.Font.Size := 12;
    ACanvas.TextOut(vBoxRect.Left, vBoxRect.Top, '��');
  end;

  if FMouseIn then  // ���������
  begin
    ACanvas.Pen.Color := clBlue;
    ACanvas.Rectangle(vBoxRect.Left, vBoxRect.Top, vBoxRect.Right, vBoxRect.Bottom);
    InflateRect(vBoxRect, 1, 1);
    ACanvas.Pen.Color := clBtnFace;
    ACanvas.Rectangle(vBoxRect.Left, vBoxRect.Top, vBoxRect.Right, vBoxRect.Bottom);
  end
  else  // ��겻������
  begin
    ACanvas.Pen.Color := clBlack;
    ACanvas.Rectangle(vBoxRect.Left, vBoxRect.Top, vBoxRect.Right, vBoxRect.Bottom);
  end;
end;

procedure TCheckBoxItem.FormatToDrawItem(const AStyle: THCStyle);
var
  vSize: TSize;
begin
  AStyle.TextStyles[TextStyleNo].ApplyStyle(AStyle.DefCanvas);
  vSize := AStyle.DefCanvas.TextExtent(FText);
  Width := vSize.cx + 16 + 6;  // ���2 + 2 + 2
  Height := Max(vSize.cy, 16) + AStyle.ParaStyles[ParaNo].LineSpace;
end;

procedure TCheckBoxItem.MouseDown(Button: TMouseButton; Shift: TShiftState; X,
  Y: Integer);
begin
  inherited;

end;

procedure TCheckBoxItem.MouseEnter;
begin
  inherited;
  FMouseIn := True;
end;

procedure TCheckBoxItem.MouseLeave;
begin
  inherited;
  FMouseIn := False;
end;

procedure TCheckBoxItem.MouseMove(Shift: TShiftState; X, Y: Integer);
begin
  inherited;
  //if PtInRect(GetBoxRect, Point(X, Y)) then
  GCursor := crArrow;
end;

procedure TCheckBoxItem.MouseUp(Button: TMouseButton; Shift: TShiftState; X,
  Y: Integer);
begin
  inherited;
  if PtInRect(GetBoxRect, Point(X, Y)) then
    Checked := not FChecked;
end;

procedure TCheckBoxItem.LoadFromStream(const AStream: TStream;
  const AStyle: THCStyle; const AFileVersion: Word);
var
  vSize: Word;
  vBuffer: TBytes;
begin
  inherited LoadFromStream(AStream, AStyle, AFileVersion);
  AStream.ReadBuffer(FChecked, SizeOf(FChecked));
  AStream.ReadBuffer(vSize, SizeOf(vSize));
  if vSize > 0 then
  begin
    SetLength(vBuffer, vSize);
    AStream.Read(vBuffer[0], vSize);
    FText := StringOf(vBuffer);
  end;
end;

procedure TCheckBoxItem.SaveToStream(const AStream: TStream; const AStart,
  AEnd: Integer);
var
  vBuffer: TBytes;
  vSize: Word;  // ���65536���ֽڣ��������65536����ʹ��д���ı�����дһ��������ʶ(��#9)������ʱ����ֱ���˱�ʶ
begin
  inherited SaveToStream(AStream, AStart, AEnd);
  AStream.WriteBuffer(FChecked, SizeOf(FChecked));
  vBuffer := BytesOf(FText);
  if System.Length(vBuffer) > MAXWORD then
    raise Exception.Create(CFE_EXCEPTION + 'TextItem�����ݳ�������ַ����ݣ�');
  vSize := System.Length(vBuffer);
  AStream.WriteBuffer(vSize, SizeOf(vSize));
  if vSize > 0 then
    AStream.WriteBuffer(vBuffer[0], vSize);
end;

procedure TCheckBoxItem.SetChecked(const Value: Boolean);
begin
  if FChecked <> Value then
  begin
    FChecked := Value;
  end;
end;

end.
