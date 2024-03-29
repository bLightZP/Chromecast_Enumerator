//
// Released under the MPL 2.0 license.
//
// Code by Yaron Gur with contributions and support from Robert Jedrzejczyk
//

unit mainunit;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls,
  Forms, Dialogs, ExtCtrls, StdCtrls, Menus, ComCtrls, SyncObjs,
  PasLibVlcUnit, PasLibVlcClassUnit, PasLibVlcPlayerUnit, tntclasses;

type
  TOptionsForm = class(TForm)
    ScanButton: TButton;
    SetOPVLCCastDeviceList: TListBox;
    StopButton: TButton;
    LabelDevices: TLabel;
    LabelDebugLog: TLabel;
    DebugLB: TListBox;
    LogLB: TListBox;
    LabelVLCLog: TLabel;
    procedure ScanButtonClick(Sender: TObject);
    procedure StopButtonClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  OptionsForm               : TOptionsForm;
  vlcDiscoverer             : libvlc_renderer_discoverer_t_ptr = nil;
  vlcDiscovererEventManager : libvlc_event_manager_t_ptr = nil;
  vlcInstance               : libvlc_instance_t_ptr = nil;


  function  UTF8StringToWideString(Const S : UTF8String) : WideString;
  procedure libvlc_log_cb(data : Pointer; level : libvlc_log_level_t; const ctx : libvlc_log_t_ptr; const fmt : PAnsiChar; args : TVaPtrListPtr); cdecl;


implementation

{$R *.dfm}


procedure vlc_renderer_event_hdlr(p_event: libvlc_event_t_ptr; data: Pointer); cdecl;
var
  I : Integer;
begin
  OptionsForm.DebugLB.Items.Add('Event: Triggered');

  If data = nil then
  Begin
    OptionsForm.DebugLB.Items.Add('Event: No Data!');
    exit;
  End;

  with p_event^ do
  begin
    case event_type of
      libvlc_RendererDiscovererItemAdded :
      Begin
        // libvlc_renderer_item_name(item) - Should also work
        OptionsForm.SetOPVLCCastDeviceList.Items.Add('"'+UTF8StringToWideString(PAnsiChar(renderer_discoverer_item_added.item^))+'"');
      End;
      libvlc_RendererDiscovererItemDeleted :
      Begin
        For I := 0 to OptionsForm.SetOPVLCCastDeviceList.Items.Count-1 do
          If OptionsForm.SetOPVLCCastDeviceList.Items[I] = UTF8StringToWideString(PAnsiChar(renderer_discoverer_item_deleted.item^)) then
        Begin
          OptionsForm.SetOPVLCCastDeviceList.Items.Delete(I);
          Break;
        End;
      End;
    End;
  end;
end;


procedure TOptionsForm.ScanButtonClick(Sender: TObject);
begin
  ScanButton.Enabled := False;
  DebugLB.Items.Add('Starting Device Scanner');

  SetOPVLCCastDeviceList.Clear;

  If Assigned(vlcInstance) then
  Begin
    DebugLB.Items.Add('Log set');

    // Create a new media discoverer for renderer discovery
    vlcDiscoverer := libvlc_renderer_discoverer_new(vlcInstance,'microdns_renderer');

    If Assigned(vlcDiscoverer) then
    begin
      DebugLB.Items.Add('Device Discoverer created at '+IntToHex(Integer(vlcDiscoverer),8));

      vlcDiscovererEventManager := libvlc_renderer_discoverer_event_manager(vlcDiscoverer);

      DebugLB.Items.Add('Device list event manager created at '+IntToHex(Integer(vlcDiscovererEventManager),8));

      // Attach event handlers
      libvlc_event_attach(vlcDiscovererEventManager, libvlc_RendererDiscovererItemAdded  , vlc_renderer_event_hdlr, self);
      libvlc_event_attach(vlcDiscovererEventManager, libvlc_RendererDiscovererItemDeleted, vlc_renderer_event_hdlr, self);

      DebugLB.Items.Add('Events attached to Event Manager');

      // Start discovery
      libvlc_renderer_discoverer_start(vlcDiscoverer);

      StopButton.Enabled := True;
      DebugLB.Items.Add('Device Scanner Started');
    end;
  End;
  If StopButton.Enabled = False then ScanButton.Enabled := True;
end;


procedure TOptionsForm.StopButtonClick(Sender: TObject);
begin
  StopButton.Enabled := False;
  DebugLB.Items.Add('Stopping Device Scanner');

  vlcDiscovererEventManager := nil;

  DebugLB.Items.Add('Interfaces released');

  libvlc_renderer_discoverer_release(vlcDiscoverer);
  vlcDiscoverer := nil;

  DebugLB.Items.Add('Device Discovery stopped');

  DebugLB.Items.Add('Device Scanner Stopped');
  ScanButton.Enabled := True;
end;


procedure libvlc_log_cb(
    data      : Pointer;
    level     : libvlc_log_level_t;
    const ctx : libvlc_log_t_ptr;
    const fmt : PAnsiChar;
    args      : TVaPtrListPtr); cdecl;
var
  fmt_chr : AnsiChar;
  fmt_idx : Integer;

  out_str : AnsiString;
  tmp_str : AnsiString;
  fmt_str : AnsiString;
  fmt_spc : AnsiString;
  tmp_chr : PAnsiChar;
begin
  out_str := '';
  fmt_str := fmt;

  while (fmt_str <> '') do
  begin
    fmt_idx := Pos('%', fmt_str);
    if (fmt_idx < 1) then break;

    out_str := out_str + Copy(fmt_str, 1, fmt_idx-1);
    Delete(fmt_str, 1, fmt_idx);

    fmt_spc := '';
    while (fmt_str <> '') and (fmt_str[1] in ['0'..'9', '.', 'z', 'l', ' ', '+', '-', '#']) do
    begin
      fmt_spc := fmt_spc + fmt_str[1];
      Delete(fmt_str, 1, 1);
    end;
    if (fmt_str = '') then break;

    fmt_chr := fmt_str[1];
    Delete(fmt_str, 1, 1);

    case fmt_chr of
      '%' : begin
        out_str := out_str + '%';
        continue;
      end;
      's' : begin
        tmp_chr := PAnsiChar(args^);
        tmp_str := '';

        if (fmt_spc = '4.4') then
        begin
          if (tmp_chr^ <> #00) then
          begin
            tmp_str := tmp_str + tmp_chr^; Inc(tmp_chr);
          end;
          if (tmp_chr^ <> #00) then
          begin
            tmp_str := tmp_str + tmp_chr^; Inc(tmp_chr);
          end;
          if (tmp_chr^ <> #00) then
          begin
            tmp_str := tmp_str + tmp_chr^; Inc(tmp_chr);
          end;
          if (tmp_chr^ <> #00) then
          begin
            tmp_str := tmp_str + tmp_chr^; // Inc(tmp_chr);
          end;
          while (Length(tmp_str) < 4) do
          begin
            tmp_str := ' ' + tmp_str;
          end;
        end
        else
        begin
          while (tmp_chr <> NIL) and (tmp_chr^ <> #00) do
          begin
            tmp_str := tmp_str + tmp_chr^;
            Inc(tmp_chr);
          end;
        end;
        out_str := out_str + tmp_str;
      end;
      'd' : begin
        if (fmt_spc = 'll') then
        begin
          tmp_str := IntToStr(Integer(args^));
        end
        else
        if (fmt_spc = 'l') then
        begin
          tmp_str := IntToStr(Integer(args^));
        end
        else
        if (fmt_spc = 'z') then
        begin
          tmp_str := IntToStr(SmallInt(args^));
        end
        else
        begin
          tmp_str := IntToStr(Integer(args^));
        end;
        out_str := out_str + tmp_str;
      end;
      'i' : begin
        tmp_str := IntToStr(Integer(args^));
        out_str := out_str + tmp_str;
      end;
      'u' : begin
        if (fmt_spc = 'll') then
        begin
          tmp_str := IntToStr(Cardinal(args^));
        end
        else
        if (fmt_spc = 'z') then
        begin
          tmp_str := IntToStr(Word(args^));
        end
        else
        begin
          tmp_str := IntToStr(Cardinal(args^));
        end;
        out_str := out_str + tmp_str;
      end;
      'x', 'X' : begin
        tmp_str := IntToHex(Cardinal(args^), 8);
        out_str := out_str + tmp_str;
      end;
      'f' : begin
        tmp_str := Format('%' + fmt_spc + fmt_chr, [Single(args^)]);
        out_str := out_str + tmp_str;
      end;
    end;

    Inc(args);
  end;
  out_str := out_str + fmt_str;

  OptionsForm.LogLB.Items.Add(out_str);
end;


procedure TOptionsForm.FormCreate(Sender: TObject);
begin
  libvlc_dynamic_dll_init();

  if (libvlc_dynamic_dll_error <> '') then
  begin
    DebugLB.Items.Add('ERROR: '+libvlc_dynamic_dll_error);
    exit;
  end;

  with TArgcArgs.Create([
    libvlc_dynamic_dll_path,
    '--intf=dummy',
    '--ignore-config',
    '--quiet',
    '--no-video-title-show'
  ]) do
  begin
    vlcInstance := libvlc_new(ARGC, ARGS);
    Free;
  end;

  DebugLB.Items.Add('libVLC loaded');

  libvlc_log_set(vlcInstance, libvlc_log_cb, NIL);

  DebugLB.Items.Add('Logging enabled');
end;


procedure TOptionsForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  libvlc_log_unset(vlcInstance);
  If vlcInstance <> nil then libvlc_release(vlcInstance);
end;


function UTF8StringToWideString(Const S : UTF8String) : WideString;
var
  iLen :Integer;
  sw   :WideString;
begin
  if Length(S) = 0 then
  Begin
    Result := '';
    Exit;
  End;
  iLen := MultiByteToWideChar(CP_UTF8,0,PAnsiChar(s),-1,nil,0);
  SetLength(sw,iLen);
  MultiByteToWideChar(CP_UTF8,0,PAnsiChar(s),-1,PWideChar(sw),iLen);
  iLen := Pos(#0,sw);
  If iLen > 0 then SetLength(sw,iLen-1);
  Result := sw;
end;


end.
