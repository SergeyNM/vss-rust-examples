pragma Ada_2022;

with Ada.Text_IO;
with Ada.Calendar;
with Ada.Calendar.Formatting;
with Ada.Containers.Synchronized_Queue_Interfaces;
with Ada.Containers.Unbounded_Synchronized_Queues;

with VSS.Strings;
with VSS.Text_Streams.Standards;

with VSS.Implementation.Rust; use VSS.Implementation.Rust;

procedure HTTP_Client_Async is

   --  1. Define a thread-safe queue to store String_Handles coming from Rust.

   --  1.1. Define the interface for the synchronized queue
   package String_Queue_Interfaces is new Ada.Containers.Synchronized_Queue_Interfaces
     (Element_Type => String_Handle);

   --  1.2. Create the unbounded synchronized queue implementation using the interface
   package Result_Queues is new Ada.Containers.Unbounded_Synchronized_Queues
     (Queue_Interfaces => String_Queue_Interfaces);

   Response_Queue : Result_Queues.Queue;

   --  2. Callback procedure that Rust will invoke from its worker threads.
   --  It must use 'Convention => C' to be compatible with Rust's FFI.
   procedure On_Result_Available (Handle : String_Handle)
     with Convention => C;

   procedure On_Result_Available (Handle : String_Handle) is
   begin
      --  Push the handle into the protected queue.
      --  This is safe to call from any Rust thread.
      Response_Queue.Enqueue (Handle);
   end On_Result_Available;

   --  3. Import the asynchronous fetch function from our Rust library.

   --  3.1. Define a named access-to-procedure type with C convention
   type Ada_Result_Callback is access procedure (Handle : String_Handle)
     with Convention => C;

   --  3.2. Use this named type in the function import
   procedure Rust_Fetch_Async
     (URL      : Slice_Str;
      Callback : Ada_Result_Callback)
     with Import, Convention => C, External_Name => "vss_rust_http_fetch_async";

   --  A collection of URLs to demonstrate parallel execution.
   type URL_Array is array (Positive range <>) of VSS.Strings.Virtual_String;

   Targets : constant URL_Array :=
     (VSS.Strings.To_Virtual_String ("https://httpbin.org/get"),
      VSS.Strings.To_Virtual_String ("https://httpbin.org/delay/3"), -- Slowest (3s)
      VSS.Strings.To_Virtual_String ("https://httpbin.org/delay/1"), -- Medium (1s)
      VSS.Strings.To_Virtual_String ("https://httpbin.org/status/404"),
      VSS.Strings.To_Virtual_String ("https://httpbin.org/status/201"));

   Current_Handle : String_Handle;
   Final_String   : VSS.Strings.Virtual_String;
   Now            : Ada.Calendar.Time;

   Std_Out : VSS.Text_Streams.Output_Text_Stream'Class :=
               VSS.Text_Streams.Standards.Standard_Output;
   Success : Boolean := True;
begin
   Ada.Text_IO.Put_Line ("--- VSS Rust Async HTTP Client ---");
   Ada.Text_IO.Put_Line ("Spawning" & Targets'Length'Image & " requests...");

   --  4. Rapidly fire all requests. Rust returns control immediately.
   for URL of Targets loop
      Rust_Fetch_Async (To_Slice_Str (URL), On_Result_Available'Access);
   end loop;

   Ada.Text_IO.Put_Line ("All requests spawned. Waiting for incoming data...");
   Ada.Text_IO.New_Line;

   --  5. Retrieve results as they arrive in the queue (out-of-order).
   for I in 1 .. Targets'Length loop
      --  Dequeue blocks the current Ada task until an element is available.
      Response_Queue.Dequeue (Current_Handle);

      Now          := Ada.Calendar.Clock;
      Final_String := To_Virtual_String (Current_Handle);

      Ada.Text_IO.Put ("[" & Ada.Calendar.Formatting.Image (Now) & "] ");
      Ada.Text_IO.Put_Line ("Result #" & I'Image & " received:");
      Std_Out.Put_Line (Final_String, Success);
      Ada.Text_IO.New_Line;
   end loop;

   Ada.Text_IO.Put_Line ("All tasks completed. Async demo finished.");
end HTTP_Client_Async;
