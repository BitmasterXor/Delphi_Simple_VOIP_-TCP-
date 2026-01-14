# 📞 Delphi VOIP Phone
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

┌─────────────────────────────────────────────────────────────────┐
│                        VOIP PHONE FLOW                          │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  INSTANCE A (Server)              INSTANCE B (Client)           │
│  ┌─────────────────┐              ┌─────────────────┐          │
│  │ Click "Listen"  │              │ Enter IP:Port   │          │
│  │ on Port 5000    │              │ Click "Call"    │          │
│  └────────┬────────┘              └────────┬────────┘          │
│           │                                │                    │
│           │◄───── TCP Connection ──────────┤                    │
│           │                                │                    │
│           │◄───── CALL_REQUEST (1) ────────┤                    │
│           │                                │                    │
│  ┌────────▼────────┐                       │                    │
│  │ "Incoming Call" │                       │                    │
│  │ Accept/Decline? │                       │                    │
│  └────────┬────────┘                       │                    │
│           │                                │                    │
│           ├────── CALL_ACCEPT (2) ────────►│                    │
│           │                                │                    │
│  ┌────────▼────────┐              ┌────────▼────────┐          │
│  │   IN CALL       │◄── AUDIO ──►│    IN CALL      │          │
│  │ Mic ──► Speaker │   (5)       │ Mic ──► Speaker │          │
│  └─────────────────┘              └─────────────────┘          │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘



---

## ⭐ Key Features

### 📞 Call Management
- **Listen Mode** - Start server to receive incoming calls on specified port
- **Outgoing Calls** - Connect to remote peer using IP:Port format
- **Accept/Decline** - Handle incoming calls with user interaction
- **Hang Up** - End active calls cleanly from either side

### 🎤 Audio System
- **WASAPI Integration** - Low-latency audio capture and playback
- **Device Enumeration** - List all available microphones and speakers
- **Real-time Streaming** - Continuous audio transmission during calls
- **Volume Control** - Independent sliders for input and output (0-100%)

### 🌐 Network Protocol
- **Simple Protocol** - 5 single-byte commands for all operations
- **TCP Reliability** - Guaranteed delivery using NetCom7 sockets
- **Minimal Overhead** - 1-byte header for command identification

---

## 📡 Protocol Specification

### Command Bytes

| Command | Value | Direction | Description |
|---------|-------|-----------|-------------|
| CALL_REQUEST | 1 | Client to Server | I want to call you |
| CALL_ACCEPT | 2 | Server to Client | I accept the call |
| CALL_DECLINE | 3 | Server to Client | I decline the call |
| HANGUP | 4 | Bidirectional | Ending the call |
| AUDIO | 5 | Bidirectional | Audio data follows |

### State Machine


     ┌──────────────────────────────────────┐
     │                                      │
     ▼                                      │
┌─────────┐   Incoming      ┌──────────┐   │
│  IDLE   │───Connection───►│ RINGING  │   │
│   (0)   │                 │   (1)    │   │
└────┬────┘                 └────┬─────┘   │
     │                           │         │
     │ Call                Accept│Decline  │
     │ Button                    │         │
     ▼                           ▼         │
┌─────────┐   CALL_ACCEPT   ┌──────────┐   │
│ CALLING │◄───────────────►│ IN_CALL  │───┘
│   (3)   │                 │   (2)    │
└─────────┘                 └──────────┘


---

## 📦 Installation

### Prerequisites
- **Delphi 12.2 Athens** (or compatible version)
- **Windows Vista+** (WASAPI requirement)

### Required Components

| Component | Purpose | Source |
|-----------|---------|--------|
| NetCom7 | TCP Sockets | [GitHub](https://github.com/DelphiBuilder/NetCom7) |
| Audio-Link | WASAPI Audio | [GitHub](https://github.com/BitmasterXor/Delphi_AudioComponents) |

### Installation Steps
1. Install NetCom7 components in Delphi IDE
2. Install Audio-Link components in Delphi IDE
3. Open `VOIPPhone.dproj` in Delphi
4. Add component source paths to Project Search Path
5. Build and Run!

---

## 🚀 Usage

### Making a Call

Instance A: Click "Listen" (starts server on port 5000)
Instance B: Enter "192.168.1.100:5000" in Call IP field
Instance B: Click "Call"
Instance A: Sees "Incoming Call..." - Click "Accept"
Both instances: Now in active voice call!
Either instance: Click "Hang Up" to end


---

## 🎛️ Audio Configuration

| Parameter | Value | Description |
|-----------|-------|-------------|
| Sample Rate | 16000 Hz | Optimized for voice |
| Channels | 1 (Mono) | Single channel |
| Bit Depth | 16-bit | Standard PCM |
| Bandwidth | ~260 kbps | Per direction |

---

## 🔧 Code Structure

| File | Description |
|------|-------------|
| `VOIPPhone.dpr` | Project file |
| `uMain.pas` | Main unit (~300 lines, fully commented) |
| `uMain.dfm` | Form definition |

---

## 📝 License

MIT License - see [LICENSE](LICENSE) file.

---

## 👨‍💻 Author

**BitmasterXor**
- GitHub: [@BitmasterXor](https://github.com/BitmasterXor)

---

<div align="center">

**⭐ Star this repository if you find it useful!**

**Made with ❤️ By BitmasterXor For the Delphi Community**

</div>
