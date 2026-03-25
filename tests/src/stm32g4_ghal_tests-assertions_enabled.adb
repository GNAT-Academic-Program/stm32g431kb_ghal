procedure Stm32g4_Ghal_Tests.Assertions_Enabled is
begin
   begin
      pragma Assert (False, "Should raise");
   exception
      when others =>
         return; -- properly raised
   end;
   raise Program_Error with "Assertion did not raise";
end Stm32g4_Ghal_Tests.Assertions_Enabled;
