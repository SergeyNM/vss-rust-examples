use std::sync::OnceLock;
use tokio::runtime::Runtime;
use vss_rust_interop::handles::{SliceStr, StringHandle};

/// Global Tokio runtime initialized once on first use.
/// Using multi_thread scheduler to allow parallel execution of tasks.
static RUNTIME: OnceLock<Runtime> = OnceLock::new();

/// FFI Callback type definition.
/// Ada provides this procedure to receive results as they become available.
type AdaCallback = extern "C" fn(*const StringHandle);

/// Starts an asynchronous HTTP GET request in a background Tokio task.
/// This function returns almost immediately to the Ada caller.
///
/// # Safety
/// The caller must ensure `url` is a valid SliceStr. 
/// `callback` must be a thread-safe Ada procedure with C convention.
#[unsafe(no_mangle)]
pub unsafe extern "C" fn vss_rust_http_fetch_async(
    url: SliceStr, 
    callback: AdaCallback
) {
    // Initialize or get the existing global runtime
    let rt = RUNTIME.get_or_init(|| {
        Runtime::new().expect("Failed to create Tokio runtime")
    });

    // Create an owned string for the async move block
    let url_str = unsafe { url.as_str() }.to_string();

    // Spawn a lightweight task onto the runtime
    rt.spawn(async move {
        let client = reqwest::Client::new();
        
        let result = match client.get(&url_str).send().await {
            Ok(resp) => {
                let status = resp.status();
                // We await the body text as well
                match resp.text().await {
                    Ok(body) => format!("[{}] Status: {}\nBody length: {}", url_str, status, body.len()),
                    Err(e) => format!("[{}] Status: {} (Error reading body: {})", url_str, status, e),
                }
            }
            Err(e) => format!("[{}] Network error: {}", url_str, e),
        };

        // Create StringHandle from result and notify Ada via callback.
        // This call happens from a Rust worker thread.
        let handle = StringHandle::from_string(result);
        callback(handle);
    });
}
