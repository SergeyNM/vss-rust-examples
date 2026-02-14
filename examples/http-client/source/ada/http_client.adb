with Ada.Text_IO;

with VSS.Strings;
with VSS.Text_Streams.Standards;

with VSS.Implementation.Rust;

procedure HTTP_Client is

   --  Import the Rust function
   function Rust_HTTP_Get (URL : VSS.Implementation.Rust.Slice_Str)
      return VSS.Implementation.Rust.String_Handle
      with Import, Convention => C, External_Name => "vss_rust_http_get_body";

   --  Helper function to wrap Rust call
   function HTTP_Get (URL : VSS.Strings.Virtual_String)
     return VSS.Strings.Virtual_String is
   begin
      return VSS.Implementation.Rust.To_Virtual_String
        (Rust_HTTP_Get (VSS.Implementation.Rust.To_Slice_Str (URL)));
   end HTTP_Get;

   Std_Out : VSS.Text_Streams.Output_Text_Stream'Class :=
               VSS.Text_Streams.Standards.Standard_Output;
   Success : Boolean := True;

   URL    : constant VSS.Strings.Virtual_String := "https://httpbin.org";
   Result : VSS.Strings.Virtual_String;
begin
   Result := HTTP_Get (URL);
   Ada.Text_IO.Put ("Ada : Response: ");
   Std_Out.Put_Line (Result, Success);
end HTTP_Client;
