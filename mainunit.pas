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
    procedure ScanButtonClick(Sender: TObject);
    procedure StopButtonClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  OptionsForm: TOptionsForm;
  vlcDiscoverer             : libvlc_media_discoverer_t_ptr = nil;
  vlcDiscovererList         : libvlc_media_list_t_ptr = nil;
  vlcDiscovererEventManager : libvlc_event_manager_t_ptr = nil;
  vlcDiscovererPlayer       : TPasLibVlcPlayer = nil;


implementation

{$R *.dfm}


procedure VLCRendererItemAdded(Sender: TObject; mrl: WideString; item: libvlc_media_t_ptr; userData: Pointer);
begin
  // This event is triggered when a new renderer is found
  // Use this to list the available Chromecast devices
  OptionsForm.SetOPVLCCastDeviceList.Items.Add(mrl);
end;


procedure VLCRendererItemDeleted(Sender: TObject; mrl: WideString; item: libvlc_media_t_ptr; userData: Pointer);
var
  I : Integer;
begin
  // This event is triggered when a renderer is no longer available
  For I := 0 to OptionsForm.SetOPVLCCastDeviceList.Items.Count-1 do
    If OptionsForm.SetOPVLCCastDeviceList.Items[I] = mrl then
  Begin
    OptionsForm.SetOPVLCCastDeviceList.Items.Delete(I);
    Break;
  End;
end;


procedure LogCallback(
    data      : Pointer;
    level     : libvlc_log_level_t;
    const ctx : libvlc_log_t_ptr;
    const fmt : PAnsiChar;
    args      : TVaPtrListPtr); cdecl;
var
  msg : String;
begin
  //msg := Format(fmt, args);
end;


procedure TOptionsForm.ScanButtonClick(Sender: TObject);
var
  ErrCode : HResult;
  vlcHandle : libvlc_media_player_t_ptr;
begin
  ErrCode := S_OK;

  SetOPVLCCastDeviceList.Clear;

  Try
    vlcDiscovererPlayer := TPasLibVlcPlayer.Create(OptionsForm);
  Except
    On E : Exception do
    Begin
      ErrCode := E_FAIL;
    End;
  End;

  If libvlc_dynamic_dll_error <> '' then ShowMessage(libvlc_dynamic_dll_error);

  If ErrCode = S_OK then
  Begin
    //libvlc_log_set(vlcDiscovererPlayer.GetPlayerHandle, @LogCallback, nil);

    // Get player handle
    vlcHandle := vlcDiscovererPlayer.GetPlayerHandle; // to make sure this isn't the freeze trigger

    // Create a new media discoverer for renderer discovery
    Try
      vlcDiscoverer := libvlc_media_discoverer_new(vlcHandle,'microdns_renderer'); // Triggers freeze
    Except
      ErrCode := E_FAIL;
    End;

    If ErrCode = S_OK then
    begin
      vlcDiscovererList         := libvlc_media_discoverer_media_list(vlcDiscoverer);
      vlcDiscovererEventManager := libvlc_media_list_event_manager(vlcDiscovererList);

      // Attach event handlers
      libvlc_event_attach(vlcDiscovererEventManager, libvlc_MediaListItemAdded, @VLCRendererItemAdded, nil);
      libvlc_event_attach(vlcDiscovererEventManager, libvlc_MediaListItemDeleted, @VLCRendererItemDeleted, nil);

      // Start discovery
      libvlc_media_discoverer_start(vlcDiscoverer);
    end
      else
    Begin
    End;
  End;
end;


procedure TOptionsForm.StopButtonClick(Sender: TObject);
begin
  libvlc_media_discoverer_stop(vlcDiscoverer);
  vlcDiscovererList := nil;
  vlcDiscovererEventManager := nil;
  libvlc_media_discoverer_release(vlcDiscoverer);
  vlcDiscoverer := nil;
end;

end.
