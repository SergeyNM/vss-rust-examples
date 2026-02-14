with Ada.Text_IO;
with VSS.Strings;
with VSS.Text_Streams.Standards;
with VSS.Implementation.Rust;

procedure IP_Inspector is

   --  Import the Rust function
   function Rust_Inspect_IP (Input : VSS.Implementation.Rust.Slice_Str)
      return VSS.Implementation.Rust.String_Handle
      with Import, Convention => C, External_Name => "vss_rust_inspect_ip";

   --  Helper function to wrap Rust call
   function Inspect_IP (Addr : VSS.Strings.Virtual_String)
      return VSS.Strings.Virtual_String is
   begin
      return VSS.Implementation.Rust.To_Virtual_String
        (Rust_Inspect_IP (VSS.Implementation.Rust.To_Slice_Str (Addr)));
   end Inspect_IP;

   type IP_Array is array (Positive range <>) of VSS.Strings.Virtual_String;

   --  Test cases: IPv4 (public/private), IPv6 (loopback/global), Invalid
   Test_Addresses : constant IP_Array :=
     (VSS.Strings.To_Virtual_String ("127.0.0.1"),          -- IPv4 Loopback
      VSS.Strings.To_Virtual_String ("192.168.1.10"),       -- IPv4 Private
      VSS.Strings.To_Virtual_String ("8.8.8.8"),            -- IPv4 Public
      VSS.Strings.To_Virtual_String ("::1"),                -- IPv6 Loopback
      VSS.Strings.To_Virtual_String ("2001:db8::1"),        -- IPv6 Global
      VSS.Strings.To_Virtual_String ("224.0.0.1"),          -- IPv4 Multicast
      VSS.Strings.To_Virtual_String ("invalid.ip.address"), -- Error case
      VSS.Strings.To_Virtual_String ("256.256.256.256"));   -- Out of range

   Std_Out : VSS.Text_Streams.Output_Text_Stream'Class :=
               VSS.Text_Streams.Standards.Standard_Output;
   Success : Boolean := True;
   Result  : VSS.Strings.Virtual_String;

begin
   Ada.Text_IO.Put_Line ("--- VSS Rust IP Inspector ---");
   Ada.Text_IO.New_Line;

   for Addr of Test_Addresses loop
      Result := Inspect_IP (Addr);

      Ada.Text_IO.Put ("Input : ");
      Std_Out.Put_Line (Addr, Success);

      Ada.Text_IO.Put ("Result: ");
      Std_Out.Put_Line (Result, Success);

      Ada.Text_IO.New_Line;
   end loop;
end IP_Inspector;
