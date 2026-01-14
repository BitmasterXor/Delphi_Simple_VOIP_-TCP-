unit uMain;

{
  ============================================================================
  VOIP Phone Application
  ============================================================================
  A simple peer-to-peer voice calling app using TCP sockets.

  How it works:
  - One instance acts as SERVER (clicks "Listen" to wait for calls)
  - Another instance acts as CLIENT (enters IP:Port and clicks "Call")
  - When a call comes in, the server can Accept or Decline
  - Once connected, microphone audio streams both ways in real-time

  Protocol (simple 1-byte commands):
    1 = CALL_REQUEST  - "Hey, I want to call you"
    2 = CALL_ACCEPT   - "OK, I'll take the call"
    3 = CALL_DECLINE  - "No thanks, hanging up"
    4 = HANGUP        - "I'm ending this call"
    5 = AUDIO         - Audio data follows this byte

  State Machine:
    0 = Idle     - Waiting, not in a call
    1 = Ringing  - Incoming call, waiting for user to Accept/Decline
    2 = InCall   - Active call, audio streaming
    3 = Calling  - Outgoing call, waiting for other side to answer
  ============================================================================
}

interface

uses
  System.SysUtils, System.Classes, System.StrUtils, Vcl.Controls, Vcl.Forms,
  Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.Dialogs, Vcl.ComCtrls, ncSockets, MicInput,
  SpeakerOutput;

type
  TfrmVOIP = class(TForm)
    // --- UI Controls ---
    pnlTop: TPanel;        // Top bar with IP/Port inputs
    edtIP: TEdit;          // IP:Port to call (e.g., "192.168.1.5:5000")
    edtPort: TEdit;        // Port to listen on
    btnListen: TButton;    // Start/Stop listening for incoming calls

    pnlDev: TPanel;        // Device selection panel
    cmbMic: TComboBox;     // Microphone dropdown
    cmbSpk: TComboBox;     // Speaker dropdown
    tbMic: TTrackBar;      // Microphone volume slider
    tbSpk: TTrackBar;      // Speaker volume slider
    lblMic: TLabel;        // Shows mic volume %
    lblSpk: TLabel;        // Shows speaker volume %

    lblStatus: TLabel;     // Shows current state (Idle, Ringing, In Call, etc.)

    pnlBtn: TPanel;        // Button panel
    btnCall: TButton;      // Initiate outgoing call
    btnHangup: TButton;    // End current call
    btnAccept: TButton;    // Accept incoming call
    btnDecline: TButton;   // Decline incoming call

    // --- Network & Audio Components ---
    Srv: TncTCPServer;     // TCP Server - listens for incoming connections
    Cli: TncTCPClient;     // TCP Client - connects to remote server
    Mic: TMicInput;        // Captures audio from microphone
    Spk: TSpeakerOutput;   // Plays audio to speakers

    // --- Event Handlers ---
    procedure FormCreate(Sender: TObject);
    procedure btnListenClick(Sender: TObject);
    procedure btnCallClick(Sender: TObject);
    procedure btnAcceptClick(Sender: TObject);
    procedure btnDeclineClick(Sender: TObject);
    procedure btnHangupClick(Sender: TObject);
    procedure SrvConnected(Sender: TObject; aLine: TncLine);
    procedure SrvDisconnected(Sender: TObject; aLine: TncLine);
    procedure SrvReadData(Sender: TObject; aLine: TncLine; const aBuf: TBytes; aBufCount: Integer);
    procedure CliConnected(Sender: TObject; aLine: TncLine);
    procedure CliDisconnected(Sender: TObject; aLine: TncLine);
    procedure CliReadData(Sender: TObject; aLine: TncLine; const aBuf: TBytes; aBufCount: Integer);
    procedure MicData(Sender: TObject; const Buffer: TBytes);
    procedure cmbMicChange(Sender: TObject);
    procedure cmbSpkChange(Sender: TObject);
    procedure tbMicChange(Sender: TObject);
    procedure tbSpkChange(Sender: TObject);

  private
    FLine: TncLine;   // The active connection (either from server or client)
    FState: Byte;     // Current state: 0=Idle, 1=Ringing, 2=InCall, 3=Calling
    FIsSrv: Boolean;  // True if we're the server side of this call

    procedure SetState(S: Byte);
    procedure Send(Cmd: Byte; const Data: TBytes = nil);
    procedure Process(const B: TBytes; Len: Integer);
  end;

var
  frmVOIP: TfrmVOIP;

implementation

{$R *.dfm}

// ============================================================================
// INITIALIZATION
// ============================================================================

procedure TfrmVOIP.FormCreate(Sender: TObject);
var
  M: TMicDeviceArray;
  S: TSpeakerDeviceArray;
  I: Integer;
begin
  // Configure audio format: 16kHz mono 16-bit
  // This is a good balance between quality and bandwidth for voice
  Mic.SampleRate := 16000;
  Mic.Channels := 1;
  Mic.BitsPerSample := 16;
  Spk.SampleRate := 16000;
  Spk.Channels := 1;
  Spk.BitsPerSample := 16;

  // Populate microphone dropdown with available devices
  M := Mic.GetDevices;
  for I := 0 to High(M) do
    cmbMic.Items.AddObject(M[I].Name, TObject(M[I].ID));

  // Populate speaker dropdown with available devices
  S := Spk.GetDevices;
  for I := 0 to High(S) do
    cmbSpk.Items.AddObject(S[I].Name, TObject(S[I].ID));

  // Select first device by default (if any exist)
  if cmbMic.Items.Count > 0 then
    cmbMic.ItemIndex := 0;
  if cmbSpk.Items.Count > 0 then
    cmbSpk.ItemIndex := 0;

  // Start in idle state
  SetState(0);
end;

// ============================================================================
// STATE MANAGEMENT
// ============================================================================

procedure TfrmVOIP.SetState(S: Byte);
const
  // Human-readable state names for the status label
  Str: array[0..3] of string = ('Idle', 'Incoming Call...', 'In Call', 'Calling...');
begin
  FState := S;

  // Update UI on main thread (events can fire from background threads)
  TThread.Queue(nil,
    procedure
    begin
      lblStatus.Caption := Str[FState];

      // Enable/disable buttons based on current state
      btnCall.Enabled := FState = 0;           // Can only call when idle
      btnAccept.Enabled := FState = 1;         // Can only accept when ringing
      btnDecline.Enabled := FState = 1;        // Can only decline when ringing
      btnHangup.Enabled := FState in [2, 3];   // Can hangup during call or while calling
      btnListen.Caption := IfThen(Srv.Active, 'Stop', 'Listen');
    end);
end;

// ============================================================================
// NETWORK COMMUNICATION
// ============================================================================

procedure TfrmVOIP.Send(Cmd: Byte; const Data: TBytes);
{
  Sends a command (and optional data) to the remote peer.

  Packet format:
    [1 byte: Command] [N bytes: Data (optional)]

  For audio, Cmd=5 and Data contains the raw PCM samples.
  For control messages (1-4), Data is empty.
}
var
  P: TBytes;
begin
  // Build packet: command byte + optional data
  SetLength(P, 1 + Length(Data));
  P[0] := Cmd;
  if Length(Data) > 0 then
    Move(Data[0], P[1], Length(Data));

  // Send via appropriate socket (server or client)
  if FIsSrv and (FLine <> nil) then
    Srv.Send(FLine, P)      // We're the server, send to connected client
  else if Cli.Active then
    Cli.Send(P);            // We're the client, send to server
end;

procedure TfrmVOIP.Process(const B: TBytes; Len: Integer);
{
  Processes incoming data from the remote peer.
  Handles both control commands and audio data.
}
var
  A: TBytes;
begin
  if Len < 1 then
    Exit;

  // First byte is always the command
  case B[0] of

    1: // CALL_REQUEST - Someone wants to call us
      if FState = 0 then
        SetState(1);  // Go to ringing state

    2: // CALL_ACCEPT - Our call was accepted
      if FState = 3 then
      begin
        // Start audio streaming
        Spk.Active := True;
        Mic.Active := True;
        SetState(2);  // Go to in-call state
      end;

    3, 4: // CALL_DECLINE or HANGUP - Call ended
      begin
        // Stop audio
        Mic.Active := False;
        Spk.Active := False;
        // Disconnect client socket if we initiated the call
        if not FIsSrv then
          Cli.Active := False;
        FLine := nil;
        SetState(0);  // Back to idle
      end;

    5: // AUDIO - Voice data
      if (FState = 2) and (Len > 1) then
      begin
        // Extract audio data (everything after the command byte)
        SetLength(A, Len - 1);
        Move(B[1], A[0], Len - 1);
        // Play it through the speaker
        if Spk.Active then
          Spk.PlayBufferBytes(A);
      end;
  end;
end;

// ============================================================================
// BUTTON HANDLERS
// ============================================================================

procedure TfrmVOIP.btnListenClick(Sender: TObject);
{
  Toggle server listening on/off.
  When listening, we can receive incoming calls.
}
begin
  if Srv.Active then
  begin
    // Stop listening - clean up any active call
    Mic.Active := False;
    Spk.Active := False;
    Srv.Active := False;
  end
  else
  begin
    // Start listening on the specified port
    Srv.Port := StrToIntDef(edtPort.Text, 5000);
    Srv.Active := True;
  end;
  SetState(0);
end;

procedure TfrmVOIP.btnCallClick(Sender: TObject);
{
  Initiate an outgoing call.
  Parses IP:Port from the input field and connects.
}
var
  P: Integer;
begin
  // Parse "IP:Port" format
  P := Pos(':', edtIP.Text);
  if P = 0 then
  begin
    ShowMessage('Enter IP:Port');
    Exit;
  end;

  // Extract host and port
  Cli.Host := Copy(edtIP.Text, 1, P - 1);
  Cli.Port := StrToIntDef(Copy(edtIP.Text, P + 1, 10), 5000);

  // Connect (this triggers CliConnected when successful)
  Cli.Active := True;
  FIsSrv := False;
  SetState(3);  // Go to "Calling..." state
end;

procedure TfrmVOIP.btnAcceptClick(Sender: TObject);
{
  Accept an incoming call.
  Starts audio streaming and notifies the caller.
}
begin
  if FLine = nil then
    Exit;

  Send(2);  // Tell caller we accepted

  // Start audio streaming
  Spk.Active := True;
  Mic.Active := True;
  SetState(2);  // Go to in-call state
end;

procedure TfrmVOIP.btnDeclineClick(Sender: TObject);
{
  Decline an incoming call.
  Notifies the caller and resets to idle.
}
begin
  Send(3);  // Tell caller we declined
  FLine := nil;
  SetState(0);
end;

procedure TfrmVOIP.btnHangupClick(Sender: TObject);
{
  End the current call (works for both caller and receiver).
}
begin
  Send(4);  // Tell other side we're hanging up

  // Stop audio
  Mic.Active := False;
  Spk.Active := False;

  // Disconnect client socket if we initiated the call
  if not FIsSrv then
    Cli.Active := False;

  FLine := nil;
  SetState(0);
end;

// ============================================================================
// SERVER EVENTS (when we're receiving a call)
// ============================================================================

procedure TfrmVOIP.SrvConnected(Sender: TObject; aLine: TncLine);
{
  Called when someone connects to our server.
  We store their connection so we can send responses.
}
begin
  if FState = 0 then
  begin
    FLine := aLine;
    FIsSrv := True;
  end;
end;

procedure TfrmVOIP.SrvDisconnected(Sender: TObject; aLine: TncLine);
{
  Called when the remote client disconnects.
  Clean up and return to idle.
}
begin
  if aLine = FLine then
  begin
    Mic.Active := False;
    Spk.Active := False;
    FLine := nil;
    SetState(0);
  end;
end;

procedure TfrmVOIP.SrvReadData(Sender: TObject; aLine: TncLine;
  const aBuf: TBytes; aBufCount: Integer);
{
  Called when we receive data from a connected client.
  Only process data from our active call partner.
}
begin
  if aLine = FLine then
    Process(aBuf, aBufCount);
end;

// ============================================================================
// CLIENT EVENTS (when we're making a call)
// ============================================================================

procedure TfrmVOIP.CliConnected(Sender: TObject; aLine: TncLine);
{
  Called when we successfully connect to a server.
  Immediately send a call request.
}
begin
  FLine := aLine;
  Send(1);  // Send CALL_REQUEST
end;

procedure TfrmVOIP.CliDisconnected(Sender: TObject; aLine: TncLine);
{
  Called when we get disconnected from the server.
  Clean up and return to idle.
}
begin
  Mic.Active := False;
  Spk.Active := False;
  FLine := nil;
  SetState(0);
end;

procedure TfrmVOIP.CliReadData(Sender: TObject; aLine: TncLine;
  const aBuf: TBytes; aBufCount: Integer);
{
  Called when we receive data from the server.
}
begin
  Process(aBuf, aBufCount);
end;

// ============================================================================
// AUDIO EVENTS
// ============================================================================

procedure TfrmVOIP.MicData(Sender: TObject; const Buffer: TBytes);
{
  Called continuously when the microphone captures audio.
  We send it to the remote peer if we're in an active call.
}
begin
  if FState = 2 then  // Only send audio during active call
    Send(5, Buffer);  // 5 = AUDIO command
end;

// ============================================================================
// DEVICE SELECTION
// ============================================================================

procedure TfrmVOIP.cmbMicChange(Sender: TObject);
{
  User selected a different microphone.
}
begin
  if cmbMic.ItemIndex >= 0 then
    Mic.DeviceID := Integer(cmbMic.Items.Objects[cmbMic.ItemIndex]);
end;

procedure TfrmVOIP.cmbSpkChange(Sender: TObject);
{
  User selected a different speaker.
}
begin
  if cmbSpk.ItemIndex >= 0 then
    Spk.DeviceID := Integer(cmbSpk.Items.Objects[cmbSpk.ItemIndex]);
end;

// ============================================================================
// VOLUME CONTROL
// ============================================================================

procedure TfrmVOIP.tbMicChange(Sender: TObject);
{
  User adjusted microphone volume.
}
begin
  Mic.Volume := tbMic.Position;
  lblMic.Caption := IntToStr(tbMic.Position) + '%';
end;

procedure TfrmVOIP.tbSpkChange(Sender: TObject);
{
  User adjusted speaker volume.
}
begin
  Spk.Volume := tbSpk.Position;
  lblSpk.Caption := IntToStr(tbSpk.Position) + '%';
end;

end.
