CREATE OR REPLACE PACKAGE Jobad_Load IS

  -- Author  : ANDREITATARU
  -- Created : 07-03-2015 2024:29I29:29 8:29:29 PM
  -- Purpose : load job ads

  FUNCTION Insertjobad(Scrapy_Item Varchar2) RETURN INTEGER;

END Jobad_Load;
/
CREATE OR REPLACE PACKAGE BODY Jobad_Load IS

  FUNCTION Insertjobad(Scrapy_Item Varchar2) RETURN INTEGER IS
    Printme  NUMBER := NULL;
    Obj      Json;
    Tempdata Json_Value;
  BEGIN
  
    Obj := Json(Scrapy_Item);
    Obj.Print();
    IF (Obj.Exist('JobAdType'))
    THEN
      Dbms_Output.Put_Line('JobAdType Yes');
      Tempdata := Obj.Get('JobAdType');
      IF (Tempdata.Is_Number)
      THEN
        Printme := Tempdata.Get_Number;
      END IF;
    END IF;
  
    IF (Printme IS NOT NULL)
    THEN
      Dbms_Output.Put_Line(Printme);
    END IF;
  
    RETURN 0;
  END;

BEGIN
  -- Initialization
  -- <Statement>;

  NULL;
END Jobad_Load;
/
