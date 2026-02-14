# VSS Rust Examples

This repository contains practical examples of integrating **Ada** with **Rust** using the [VSS (Virtual String System)](https://github.com/AdaCore/vss-text) and the interop layer provided by [vss-rust](https://github.com/SergeyNM/vss-rust).

The project demonstrates how to leverage Rust's ecosystem (Asynchronous I/O, Networking) seamlessly within Ada applications.

## 🚀 Featured Examples

1.  **IP Inspector** 
    A simple tool using Rust's `std::net` to validate IPv4/IPv6 addresses and inspect their properties (loopback, multicast, etc.).
```text
--- VSS Rust IP Inspector ---

Input : 127.0.0.1
Result: [IPv4] Loopback: Yes, Multicast: No, Private: No

Input : 192.168.1.10
Result: [IPv4] Loopback: No, Multicast: No, Private: Yes

Input : 8.8.8.8
Result: [IPv4] Loopback: No, Multicast: No, Private: No

Input : ::1
Result: [IPv6] Loopback: Yes, Multicast: No

Input : 2001:db8::1
Result: [IPv6] Loopback: No, Multicast: No

Input : 224.0.0.1
Result: [IPv4] Loopback: No, Multicast: Yes, Private: No

Input : invalid.ip.address
Result: Error: Invalid IP address format

Input : 256.256.256.256
Result: Error: Invalid IP address format
```
2.  **HTTP Client**  
    A synchronous HTTP GET requester powered by the `reqwest` crate, demonstrating basic string exchange between Ada and Rust.

3.  **HTTP Client Async**  
    An advanced example using **Tokio multi-thread runtime** and Ada **Protected Queues**. It demonstrates non-blocking parallel requests and out-of-order result processing.
```text
--- VSS Rust Async HTTP Client ---
Spawning 5 requests...
All requests spawned. Waiting for incoming data...

[2026-02-14 10:03:13] Result # 1 received:
[https://httpbin.org/get] Status: 200 OK
Body length: 221

[2026-02-14 10:03:13] Result # 2 received:
[https://httpbin.org/status/404] Status: 404 Not Found
Body length: 0

[2026-02-14 10:03:13] Result # 3 received:
[https://httpbin.org/status/201] Status: 201 Created
Body length: 0

[2026-02-14 10:03:14] Result # 4 received:
[https://httpbin.org/delay/1] Status: 200 OK
Body length: 271

[2026-02-14 10:03:16] Result # 5 received:
[https://httpbin.org/delay/3] Status: 200 OK
Body length: 271

All tasks completed. Async demo finished.
```

## 🛠 Prerequisites

Ensure you have the following tools installed:
*   [Alire](https://alire.ada.dev) (Ada Library Manager)
*   [Rust & Cargo](https://rustup.rs) (Edition 2024 recommended)
*   MinGW-w64 (for Windows users)

> [!IMPORTANT]
> For more detailed information on environment setup and toolchain configuration, please refer to the **[vss-rust README](https://github.com/SergeyNM/vss-rust#requirements)**.

## 🏗 Build Instructions

This project uses a hybrid build system. Follow these steps to build all examples:

### 1. Synchronize Dependencies
Make sure you have the [vss-rust](https://github.com/SergeyNM/vss-rust) core library in the parent directory:
```bash
git clone https://github.com/SergeyNM/vss-rust ../vss-rust
```
**Required directory structure:**
```text
.
├── vss-rust/           # Core interop library
└── vss-rust-examples/  # This repository (examples)
```
You can verify it by running dir ..\vss* (Windows) or ls -d ../vss* (Linux):
```text
Mode                Name
----                ----
d-----              vss-rust
d-----              vss-rust-examples
```

### 2. Build Rust Components
Compile the core interop library and all examples:
```bash
# Build core interop library
alr exec -- cargo build --release --manifest-path ../vss-rust/Cargo.toml

# Build specific examples
alr exec -- cargo build --release
```

### 3. Build Ada Executables
Finally, use Alire to link everything together:
```bash
alr build --release
```
*The executables will be located in the ./bin/ directory.*

## 🔗 Related Projects
[vss-rust](https://github.com/SergeyNM/vss-rust) — Core interop library for seamless mapping between Ada VSS Virtual_String and Rust's native strings.

[VSS (Virtual String System)](https://github.com/AdaCore/vss-text) — A high-level, Unicode-aware string and utility library for Ada.

## 📜 License
This project is licensed under the same terms as the vss-rust project.
