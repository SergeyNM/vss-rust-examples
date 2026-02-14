use std::net::IpAddr;
use vss_rust_interop::handles::{SliceStr, StringHandle};

#[unsafe(no_mangle)]
pub unsafe extern "C" fn vss_rust_inspect_ip(input: SliceStr) -> *const StringHandle {
    let s = unsafe { input.as_str() }.trim();
    
    let report = match s.parse::<IpAddr>() {
        Ok(ip) => {
            let kind = if ip.is_ipv4() { "IPv4" } else { "IPv6" };
            let loopback = if ip.is_loopback() { "Yes" } else { "No" };
            let multicast = if ip.is_multicast() { "Yes" } else { "No" };
            
            // For IPv4 we can check if it's a private network address
            let extra = if let IpAddr::V4(v4) = ip {
                format!(", Private: {}", if v4.is_private() { "Yes" } else { "No" })
            } else {
                String::new()
            };

            format!("[{}] Loopback: {}, Multicast: {}{}", kind, loopback, multicast, extra)
        }
        Err(_) => "Error: Invalid IP address format".to_string(),
    };

    StringHandle::from_string(report)
}
