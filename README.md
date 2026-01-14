# 📞 Delphi Simple VOIP Phone
**Minimal Peer-to-Peer Voice Calling Application for Delphi**

<div align="center">

![Version](https://img.shields.io/badge/Version-1.0-blue?style=for-the-badge)
![Delphi](https://img.shields.io/badge/Delphi-12.2%20Athens-red?style=for-the-badge)
![Platform](https://img.shields.io/badge/Platform-Windows-green?style=for-the-badge)
![License](https://img.shields.io/badge/License-MIT-orange?style=for-the-badge)

*A lightweight, fully-functional VOIP phone application using NetCom7 TCP sockets and WASAPI audio components*

</div>

---

## 🚀 Overview

Delphi VOIP Phone is a minimal yet complete peer-to-peer voice calling application. It demonstrates how to build real-time audio communication using TCP sockets with surprisingly little code. Each instance can act as both a server (receive calls) and client (make calls), enabling true peer-to-peer communication.

### 🎯 What's Included

- **📞 Full VOIP Functionality** - Make and receive voice calls over TCP/IP
- **🔄 Dual-Mode Operation** - Acts as both server and client simultaneously
- **🎤 Device Selection** - Choose from available microphones and speakers
- **🔊 Volume Controls** - Independent mic and speaker volume sliders
- **📱 Minimal UI** - Clean, simple interface with all essential controls
- **📝 Fully Commented Code** - Human-readable, well-documented source

---

## 🏗️ Architecture

```mermaid
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
📡 Protocol Specification
Command Bytes
Command	Value	Direction	Description
CALL_REQUEST	1	Client → Server	"I want to call you"
CALL_ACCEPT	2	Server → Client	"I'll take the call"
CALL_DECLINE	3	Server → Client	"No thanks"
HANGUP	4	Bidirectional	"Ending the call"
AUDIO	5	Bidirectional	Audio data follows
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
Audio-Link Components - WASAPI Audio I/O
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
🎛️ Audio Configuration
Parameter	Value	Description
Sample Rate	16000 Hz	Optimized for voice
Channels	1 (Mono)	Single channel
Bit Depth	16-bit	Standard PCM
Bandwidth	~260 kbps	Per direction
🔧 Code Structure
File	Description
VOIPPhone.dpr	Project file
uMain.pas	Main unit (~300 lines, fully commented)
uMain.dfm	Form definition
📝 License
MIT License - see LICENSE file.

👨‍💻 Author
BitmasterXor

GitHub: @BitmasterXor
🤝 Dependencies
Component	Purpose	Source
NetCom7	TCP Sockets	GitHub
Audio-Link	WASAPI Audio	GitHub
<div align="center">
⭐ Star this repository if you find it useful!

Made with ❤️ By BitmasterXor For the Delphi Community

</div> ```
