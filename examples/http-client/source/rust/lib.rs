use vss_rust_interop::handles::{SliceStr, StringHandle};
use reqwest::blocking::get;

/// Performs a synchronous HTTP GET request and returns the response body or an error message.
///
/// # Safety
/// The caller must ensure that `url` is a valid `SliceStr`.
/// The host is responsible for managing the memory of the returned `StringHandle`.
#[unsafe(no_mangle)]
pub unsafe extern "C" fn vss_rust_http_get_body(url: SliceStr) -> *const StringHandle {
    // Convert the input SliceStr to a Rust string slice
    let url_str = unsafe { url.as_str() };
    println!("Rust: reqwest : Fetching URL: {}", url_str);

    // Execute the blocking GET request
    let result = match get(url_str) {
        Ok(response) => {
            let status = response.status();
            println!("Rust: reqwest : Received status: {}", status);
            
            // Read the response body as text.
            // If the body is empty (e.g., HTTP 204), it returns an empty string.
            response.text().unwrap_or_else(|e| {
                format!("Failed to read response body: {}", e)
            })
        }
        Err(e) => {
            let err_msg = format!("HTTP Request failed: {}", e);
            println!("Rust: reqwest : {}", err_msg);
            err_msg
        }
    };

    // Convert the resulting string into a StringHandle for Ada interop
    StringHandle::from_string(result)
}
