CREATE OR REPLACE FUNCTION Getdepartmentid(Department_Name VARCHAR2) RETURN VARCHAR2 Result_Cache IS
  Department_Id VARCHAR2(4000);
BEGIN
  SELECT Departmentid
    INTO Department_Id
    FROM t_Departments t
   WHERE TRIM(t.Departmentname) = TRIM(Department_Name)
      OR TRIM(t.Departmentnamealt) = TRIM(Department_Name);
  RETURN(Department_Id);
EXCEPTION
  WHEN No_Data_Found THEN
    RETURN(Department_Id);
END Getdepartmentid;
/
