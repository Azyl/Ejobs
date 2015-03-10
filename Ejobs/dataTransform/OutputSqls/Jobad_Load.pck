CREATE OR REPLACE PACKAGE Jobad_Load IS

  -- Author  : ANDREITATARU
  -- Created : 07-03-2015 2024:29I29:29 8:29:29 PM
  -- Purpose : load job ads

  TYPE t_Array IS TABLE OF VARCHAR2(255) INDEX BY BINARY_INTEGER;

  TYPE Typ_Rec_Err_Tab IS TABLE OF Typ_Rec_Err;

  FUNCTION Err_Details(Errval INTEGER) RETURN VARCHAR2;

  FUNCTION List_Error(v_Binstr IN VARCHAR2) RETURN Typ_Rec_Err_Tab
    PIPELINED;

  FUNCTION Insertjobad(Scrapy_Item VARCHAR2) RETURN INTEGER;

  PROCEDURE Insertjobad(NAME IN OUT TYPE, NAME IN OUT TYPE, .. .);

END Jobad_Load;
/
CREATE OR REPLACE PACKAGE BODY Jobad_Load IS

  FUNCTION Err_Details(Errval INTEGER) RETURN VARCHAR2 IS
    Err_Array t_Array;
  BEGIN
    Err_Array(1) := 'Table 1: Resource usage';
    Err_Array(2) := 'Table 2: TOP 10 programs by cpu time';
    Err_Array(3) := 'Table 3: TOP 10 long operations';
    Err_Array(4) := 'Table 4: TOP 10 IDLE Sesions';
    Err_Array(5) := 'Table 5: DeadLocks';
    Err_Array(6) := 'Table 6: Invalid Objects';
    Err_Array(7) := 'Table 7: Tablespace utilization';
    Err_Array(8) := 'Table 8: Temporary Tablespaces';
    Err_Array(9) := 'Table 9: DB Data files';
    Err_Array(10) := 'Table 10: Unextendable Objects';
    Err_Array(11) := 'Table 11: Statistics job Status';
    Err_Array(12) := 'Table 12: RMAN BackUP job Status';
    Err_Array(13) := 'Table 13: RMAN BackUP job Status Date' Space Err_Array(14) := 'Table 14 : Disk Usage';
    IF Errval BETWEEN 1 AND Err_Array.Count
    THEN
      RETURN Err_Array(Errval);
    ELSE
      Raise_Application_Error(-20000, 'There are only ' || Err_Array.Count || ' error codes');
    END IF;
  END Err_Details;

  FUNCTION To_Base(p_Dec IN NUMBER, p_Base IN NUMBER) RETURN VARCHAR2 IS
    l_Str VARCHAR2(255) DEFAULT NULL;
    l_Num NUMBER DEFAULT p_Dec;
    l_Hex VARCHAR2(16) DEFAULT '0123456789ABCDEF';
  BEGIN
    IF (p_Dec IS NULL OR p_Base IS NULL)
    THEN
      RETURN NULL;
    END IF;
    IF (Trunc(p_Dec) <> p_Dec OR p_Dec < 0)
    THEN
      RAISE Program_Error;
    END IF;
    LOOP
      l_Str := Substr(l_Hex, MOD(l_Num, p_Base) + 1, 1) || l_Str;
      l_Num := Trunc(l_Num / p_Base);
      EXIT WHEN(l_Num = 0);
    END LOOP;
    RETURN l_Str;
  END To_Base;

  FUNCTION To_Dec(p_Str IN VARCHAR2, p_From_Base IN NUMBER DEFAULT 16) RETURN NUMBER IS
    l_Num NUMBER DEFAULT 0;
    l_Hex VARCHAR2(16) DEFAULT '0123456789ABCDEF';
  BEGIN
    IF (p_Str IS NULL OR p_From_Base IS NULL)
    THEN
      RETURN NULL;
    END IF;
    FOR i IN 1 .. Length(p_Str)
    LOOP
      l_Num := l_Num * p_From_Base + Instr(l_Hex, Upper(Substr(p_Str, i, 1))) - 1;
    END LOOP;
    RETURN l_Num;
  END To_Dec;

  FUNCTION To_Bin(p_Dec IN NUMBER) RETURN VARCHAR2 IS
  BEGIN
    RETURN To_Base(p_Dec, 2);
  END To_Bin;

  FUNCTION List_Error(v_Binstr IN VARCHAR2) RETURN Typ_Rec_Err_Tab
    PIPELINED IS
    Tab Typ_Rec_Err DEFAULT Typ_Rec_Err(NULL, NULL);
    i   INTEGER;
    j   VARCHAR2(1);
    k   NUMBER(4) DEFAULT 0;
    -- SELECT * FROM TABLE(Crisoftadm.List_Error(To_Bin(9)));
  BEGIN
    FOR i IN 1 .. Length(v_Binstr)
    LOOP
      j := Substr(v_Binstr, i, 1);
      IF i != Length(v_Binstr)
      THEN
        IF j = '1'
        THEN
          k           := 1;
          Tab.Errtype := 'Warning';
          Tab.Errval  := Length(v_Binstr) - i;
          PIPE ROW(Tab);
        END IF;
      ELSE
        Tab.Errtype := 'Error';
        Tab.Errval  := k + j;
        PIPE ROW(Tab);
      END IF;
    END LOOP;
  END List_Error;

  FUNCTION Insertjobad(Scrapy_Item VARCHAR2) RETURN INTEGER IS
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
