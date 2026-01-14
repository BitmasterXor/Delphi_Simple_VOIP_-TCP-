📞 Delphi VOIP Phone
Minimal Peer-to-Peer Voice Calling Application for Delphi

<div align="center">
[Image]
[Image]
[Image]
[Image]

A lightweight, fully-functional VOIP phone application using NetCom7 TCP sockets and WASAPI audio components

</div>
🚀 Overview
Delphi VOIP Phone is a minimal yet complete peer-to-peer voice calling application. It demonstrates how to build real-time audio communication using TCP sockets with surprisingly little code. Each instance can act as both a server (receive calls) and client (make calls), enabling true peer-to-peer communication.

🎯 What's Included
📞 Full VOIP Functionality - Make and receive voice calls over TCP/IP
🔄 Dual-Mode Operation - Acts as both server and client simultaneously
🎤 Device Selection - Choose from available microphones and speakers
🔊 Volume Controls - Independent mic and speaker volume sliders
📱 Minimal UI - Clean, simple interface with all essential controls
📝 Fully Commented Code - Human-readable, well-documented source
🏗️ Architecture

graph TD
    subgraph "Instance A - Server Mode"
        A1[TCP Server] --> A2[Listens on Port]
        A2 --> A3[Accepts Connection]
        A3 --> A4[Receives CALL_REQUEST]
        A4 --> A5{User Decision}
        A5 -->|Accept| A6[Send CALL_ACCEPT]
        A5 -->|Decline| A7[Send CALL_DECLINE]
        A6 --> A8[Start Audio Stream]
    end
    
    subgraph "Instance B - Client Mode"
        B1[TCP Client] --> B2[Connects to IP:Port]
        B2 --> B3[Send CALL_REQUEST]
        B3 --> B4{Wait for Response}
        B4 -->|CALL_ACCEPT| B5[Start Audio Stream]
        B4 -->|CALL_DECLINE| B6[Return to Idle]
    end
    
    A8 <-->|Bidirectional Audio| B5
    
    subgraph "Audio Pipeline"
        M[Microphone] --> MC[TMicInput]
        MC --> TX[TCP Send]
        RX[TCP Receive] --> SP[TSpeakerOutput]
        SP --> S[Speakers]
    end
⭐ Key Features
📞 Call Management
Listen Mode - Start server to receive incoming calls on specified port
Outgoing Calls - Connect to remote peer using IP:Port format
Accept/Decline - Handle incoming calls with user interaction
Hang Up - End active calls cleanly from either side
🎤 Audio System
WASAPI Integration - Low-latency audio capture and playback
Device Enumeration - List all available microphones and speakers
Real-time Streaming - Continuous audio transmission during calls
Volume Control - Independent sliders for input and output (0-100%)
🌐 Network Protocol
Simple Protocol - 5 single-byte commands for all operations
TCP Reliability - Guaranteed delivery using NetCom7 sockets
Minimal Overhead - 1-byte header for command identification
Efficient Audio - Raw PCM streaming with minimal latency
💻 Clean Implementation
~300 Lines of Code - Complete VOIP in minimal code
Fully Commented - Every function and section documented
State Machine - Clear 4-state call management
Thread-Safe UI - Proper main thread synchronization
📡 Protocol Specification
Command Bytes
Command	Value	Direction	Description
CALL_REQUEST	1	Client → Server	"I want to call you"
CALL_ACCEPT	2	Server → Client	"I'll take the call"
CALL_DECLINE	3	Server → Client	"No thanks"
HANGUP	4	Bidirectional	"Ending the call"
AUDIO	5	Bidirectional	Audio data follows
Packet Format

┌──────────────┬─────────────────────────────┐
│ Command (1B) │ Audio Data (N bytes)        │
└──────────────┴─────────────────────────────┘

Commands 1-4: Single byte, no data
Command 5:    1 byte + raw PCM audio samples
State Machine

┌─────────┐  Incoming    ┌──────────┐
│  IDLE   │─────────────>│ RINGING  │
│   (0)   │  Connection  │   (1)    │
└────┬────┘              └────┬─────┘
     │                        │
     │ Call Button       Accept│Decline
     │                        │
     v                        v
┌─────────┐  CALL_ACCEPT ┌──────────┐
│ CALLING │<────────────>│ IN_CALL  │
│   (3)   │              │   (2)    │
└─────────┘              └──────────┘
📦 Installation
Prerequisites
Delphi 12.2 Athens (or compatible version)
Windows Vista+ (WASAPI requirement)
Required Components
NetCom7 - TCP Socket Components

Source: NetCom7-master\Source
Audio-Link Components - WASAPI Audio I/O

Source: Delphi_Audio-Link_Components-main
Installation Steps
Install NetCom7 components in Delphi IDE
Install Audio-Link components in Delphi IDE
Open VOIPPhone.dproj in Delphi
Add component source paths to Project Search Path
Build and Run!
🚀 Usage
Making a Call

1. Instance A: Click "Listen" (starts server on port 5000)
2. Instance B: Enter "192.168.1.100:5000" in Call IP field
3. Instance B: Click "Call"
4. Instance A: Sees "Incoming Call..." - Click "Accept"
5. Both instances: Now in active voice call!
6. Either instance: Click "Hang Up" to end
Audio Settings

- Select microphone from dropdown
- Select speaker from dropdown  
- Adjust mic volume with slider (0-100%)
- Adjust speaker volume with slider (0-100%)
Network Configuration

Call IP Field:  IP:Port format (e.g., "192.168.1.5:5000")
Listen Port:    Port number for incoming calls (default: 5000)
🎛️ Audio Configuration
Format Settings
Parameter	Value	Description
Sample Rate	16000 Hz	Optimized for voice
Channels	1 (Mono)	Single channel for voice
Bit Depth	16-bit	Standard PCM quality
Bandwidth Estimate

16000 samples/sec × 16 bits × 1 channel = 256 kbps
+ Protocol overhead (~1%) ≈ 260 kbps per direction
🔧 Code Structure
Files
File	Description
VOIPPhone.dpr	Project file
uMain.pas	Main unit with all VOIP logic
uMain.dfm	Form definition
VOIPPhone.dproj	Delphi project configuration
Code Sections

// ============================================================================
// INITIALIZATION        - Form setup, device enumeration
// STATE MANAGEMENT      - 4-state call state machine  
// NETWORK COMMUNICATION - Send/Process commands and audio
// BUTTON HANDLERS       - UI interaction handlers
// SERVER EVENTS         - Incoming connection handling
// CLIENT EVENTS         - Outgoing connection handling
// AUDIO EVENTS          - Microphone data streaming
// DEVICE SELECTION      - Mic/Speaker device changes
// VOLUME CONTROL        - Volume slider handlers
// ============================================================================
📈 Technical Specifications
Supported Configurations
Sample Rates: 8kHz - 48kHz (16kHz default)
Channels: Mono or Stereo (Mono default)
Bit Depths: 16-bit or 32-bit PCM
Network: TCP/IPv4
Performance
Audio Latency: ~50ms (depends on network)
CPU Usage: Minimal (<5% on modern systems)
Memory: ~10MB runtime footprint
Bandwidth: ~260 kbps per direction
🧪 Testing
Local Testing (Same Machine)

1. Run two instances of VOIPPhone.exe
2. Instance A: Listen on port 5000
3. Instance B: Call 127.0.0.1:5000
4. Accept call and verify audio
Network Testing (Different Machines)

1. Machine A: Run VOIPPhone, Listen on port 5000
2. Machine B: Run VOIPPhone, Call [Machine_A_IP]:5000
3. Ensure firewall allows port 5000 TCP
4. Accept call and verify audio
🛠️ Customization
Change Audio Quality

// In FormCreate - Higher quality
Mic.SampleRate := 48000;
Mic.Channels := 2;
Mic.BitsPerSample := 32;

// In FormCreate - Lower bandwidth  
Mic.SampleRate := 8000;
Mic.Channels := 1;
Mic.BitsPerSample := 16;
Change Default Port

// In DFM or FormCreate
Srv.Port := 12345;  // Your preferred port
🤝 Dependencies
Component	Purpose	Source
NetCom7	TCP Client/Server	GitHub
Audio-Link	WASAPI Audio I/O	GitHub
📝 License
This project is licensed under the MIT License - see the LICENSE file for complete details.

👨‍💻 Author
BitmasterXor

GitHub: @BitmasterXor
Discord: BitmasterXor
🙏 Acknowledgments
NetCom7 Team - Excellent TCP socket components
Microsoft WASAPI Team - Low-latency audio API
Delphi Community - Continuous support and inspiration
📚 Additional Resources
Documentation
NetCom7 Documentation
Windows Audio Session API (WASAPI)
Delphi Audio-Link Components
Related Projects
Delphi Audio Components - The audio components used in this project
<div align="center">
⭐ Star this repository if you find it useful!

Made with ❤️ By BitmasterXor For the Delphi Community

</div>
