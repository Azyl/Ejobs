CREATE OR REPLACE PACKAGE Jobad_Load IS

  -- Author  : ANDREITATARU
  -- Created : 07-03-2015 2024:29I29:29 8:29:29 PM
  -- Purpose : load job ads

  FUNCTION Display_Error_Stack RETURN VARCHAR2;

  PROCEDURE Insertjobad(Scrapy_Item VARCHAR2, Scrapeid_t NUMBER);

  PROCEDURE Processnewjobads;

  PROCEDURE Pr_Log_Job_Message_Error(Sqlcode_In   IN INTEGER,
                                     Sqlerrm_In   IN VARCHAR2,
                                     Insert_In    IN INTEGER,
                                     Update_In    IN INTEGER,
                                     Delete_In    IN INTEGER,
                                     Job_Name     IN VARCHAR2,
                                     Message_In   IN VARCHAR2,
                                     Starttime_In IN BINARY_INTEGER,
                                     Startdate_In IN DATE);

  PROCEDURE Pr_Log_Job_Message_Success(Insert_In    IN INTEGER,
                                       Update_In    IN INTEGER,
                                       Delete_In    IN INTEGER,
                                       Job_Name     IN VARCHAR2,
                                       Message_In   IN VARCHAR2,
                                       Starttime_In IN BINARY_INTEGER,
                                       Startdate_In IN DATE);

END Jobad_Load;
/
CREATE OR REPLACE PACKAGE BODY Jobad_Load IS

  FUNCTION Display_Error_Stack RETURN VARCHAR2 IS
    Temp_String VARCHAR2(32767);
    l_Depth     PLS_INTEGER;
  BEGIN
    l_Depth     := Utl_Call_Stack.Error_Depth;
    Temp_String := '***** Error Stack Start *****';
    Temp_String := Temp_String || Chr(13) || Chr(10) || 'Depth Error Error';
    Temp_String := Temp_String || Chr(13) || Chr(10) || '. Code Message';
    Temp_String := Temp_String || Chr(13) || Chr(10) || '--------- --------- --------------------';
    FOR i IN 1 .. l_Depth
    LOOP
      Temp_String := Temp_String || Chr(13) || Chr(10) ||
                     (Rpad(i, 10) || Rpad('ORA-' || Lpad(Utl_Call_Stack.Error_Number(i), 5, '0'), 10) ||
                     Utl_Call_Stack.Error_Msg(i));
    END LOOP;
    Temp_String := Temp_String || Chr(13) || Chr(10) || '***** Error Stack End *****';
  
    RETURN Temp_String;
  END;

  PROCEDURE Pr_Log_Job_Message_Error(Sqlcode_In   IN INTEGER,
                                     Sqlerrm_In   IN VARCHAR2,
                                     Insert_In    IN INTEGER,
                                     Update_In    IN INTEGER,
                                     Delete_In    IN INTEGER,
                                     Job_Name     IN VARCHAR2,
                                     Message_In   IN VARCHAR2,
                                     Starttime_In IN BINARY_INTEGER,
                                     Startdate_In IN DATE) IS
    l_Endtime BINARY_INTEGER;
    l_Message VARCHAR2(4000);
  BEGIN
    l_Message := 'JOBRUN WITH ERROR: ' || Sqlcode_In || ' ERRORMSG: ' || Sqlerrm_In || ' INSERT: ' || Insert_In || ' DELETE: ' ||
                 Delete_In || ' UPDATE : ' || Update_In || ' USER : ' || USER;
    IF NOT Message_In IS NULL
    THEN
      l_Message := l_Message || ' MESSAGE: ' || Message_In;
    END IF;
    INSERT INTO t_Errorjobad
      (Jobname, Starttime, Endtime, Duration, Message)
    VALUES
      (Job_Name, Startdate_In, SYSDATE, ((l_Endtime - Starttime_In) * 10), l_Message);
    COMMIT;
  
  END Pr_Log_Job_Message_Error;

  PROCEDURE Pr_Log_Job_Message_Success(Insert_In    IN INTEGER,
                                       Update_In    IN INTEGER,
                                       Delete_In    IN INTEGER,
                                       Job_Name     IN VARCHAR2,
                                       Message_In   IN VARCHAR2,
                                       Starttime_In IN BINARY_INTEGER,
                                       Startdate_In IN DATE) IS
  
    l_Message VARCHAR2(4000);
  BEGIN
    l_Message := 'JOB SUCCESFULLY! ' || ' INSERT: ' || Insert_In || ' DELETE: ' || Delete_In || ' UPDATE : ' || Update_In ||
                 ' USER : ' || USER;
  
    IF NOT Message_In IS NULL
    THEN
      l_Message := l_Message || ' MESSAGE: ' || Message_In;
    END IF;
  
    INSERT INTO t_Errorjobad
      (Jobname, Starttime, Endtime, Duration, Message)
    VALUES
      (Job_Name, Startdate_In, SYSDATE, ((Dbms_Utility.Get_Time - Starttime_In) * 10), l_Message);
    COMMIT;
  
  END Pr_Log_Job_Message_Success;

  PROCEDURE Insertjobad(Scrapy_Item VARCHAR2, Scrapeid_t NUMBER) IS
  
    Status              INTEGER := 0;
    Parse_Log_s         VARCHAR2(32767) := '';
    Printme             NUMBER := NULL;
    Obj                 Json;
    Tempobj             Json;
    Tempdata            Json_Value;
    Templist            Json_List;
    Jobadid_Scr         INTEGER;
    Companyid_t         INTEGER;
    Countryid_t         INTEGER;
    Departmentid_t      INTEGER;
    Jobadtypeid_t       INTEGER;
    Careerlevelid_t     INTEGER;
    Driverlicenceid_t   INTEGER;
    Languageid_t        INTEGER;
    Industryid_t        INTEGER;
    Cityid_t            INTEGER;
    Countyid_t          VARCHAR2(3);
    Jobtitle_t          VARCHAR2(4000);
    Jobadstartdate_t    VARCHAR2(100);
    Jobadenddate_t      VARCHAR2(100);
    Jobadpositionsnr_t  VARCHAR2(100);
    Jobadapplicantsnr_t VARCHAR2(200);
    Tdate               DATE;
  
  BEGIN
  
    Dbms_Output.Put_Line('Processing JSON input:');
    Parse_Log_s := Parse_Log_s || 'Processing JSON input:';
    Obj         := Json(Scrapy_Item);
    Obj.Print();
    Parse_Log_s := Parse_Log_s || Chr(13) || Chr(10) || Obj.To_Char;
    IF (Obj.Exist('JobAdType'))
    THEN
      Dbms_Output.Put_Line('jobAdType json found');
      Parse_Log_s := Parse_Log_s || Chr(13) || Chr(10) || 'jobAdType json found';
      Tempdata    := Obj.Get('JobAdType');
      IF (Tempdata.Is_Number)
      THEN
        Printme := Tempdata.Get_Number;
        IF (Printme IS NOT NULL AND Printme = 1)
        THEN
          Dbms_Output.Put_Line('JobAdType 1 Yes proceding to insert the jobAd');
          Parse_Log_s := Parse_Log_s || Chr(13) || Chr(10) || 'JobAdType 1 Yes proceding to insert the jobAd';
          --Jobadid_Scr := Sq_Jobadid.Nextval;
          --Dbms_Output.Put_Line('jobadid = ' || Jobadid_Scr);
          Jobadid_Scr := Scrapeid_t;
          Dbms_Output.Put_Line('jobadid = ' || Scrapeid_t);
          Parse_Log_s := Parse_Log_s || Chr(13) || Chr(10) || 'jobadid = ' || Scrapeid_t;
          --< country >--
          Countryid_t := 642;
          --toate anunturile sunt ale unor firme din Romania
          --</ country />--   
        
          --< company >--
          IF (Obj.Exist('CompanyName'))
          THEN
            Tempdata := Obj.Get('CompanyName');
            Tempdata := Obj.Get('CompanyName');
            IF (Tempdata.Is_Array)
            THEN
              Templist := Json_List(Tempdata);
              IF Templist.Count > 0
              THEN
              
                FOR Iter IN 1 .. Templist.Count
                LOOP
                  Tempdata := Templist.Get(Iter);
                  Dbms_Output.Put_Line(Tempdata.Get_String);
                  -- get companyId
                  BEGIN
                    SELECT Companyid INTO Companyid_t FROM t_Company t WHERE t.Companyname = Tempdata.Get_String;
                    Dbms_Output.Put_Line('companyId = ' || Companyid_t || ' ' || Tempdata.Get_String);
                  EXCEPTION
                    WHEN No_Data_Found THEN
                      Dbms_Output.Put_Line('no company: ' || Tempdata.Get_String || ' in database, inserting new company');
                      Parse_Log_s := Parse_Log_s || Chr(13) || Chr(10) || 'no company: ' || Tempdata.Get_String ||
                                     ' in database, inserting new company';
                      --insert into T_company
                      INSERT INTO t_Company (Companyname, Countryid) VALUES (Tempdata.Get_String, Countryid_t);
                      COMMIT;
                      SELECT Companyid INTO Companyid_t FROM t_Company t WHERE t.Companyname = Tempdata.Get_String;
                      Dbms_Output.Put_Line('company inserted: ' || Companyid_t);
                      Parse_Log_s := Parse_Log_s || Chr(13) || Chr(10) || 'no company: ' || 'company inserted: ' || Companyid_t;
                  END;
                END LOOP;
              ELSE
                Dbms_Output.Put_Line('CompanyName list is empty');
                Parse_Log_s := Parse_Log_s || Chr(13) || Chr(10) || 'CompanyName list is empty';
                Status      := 1;
              END IF;
            ELSE
              Dbms_Output.Put_Line('CompanyName should be a list');
              Parse_Log_s := Parse_Log_s || Chr(13) || Chr(10) || 'CompanyName should be a list';
              Status      := 1;
            END IF;
          ELSE
            Dbms_Output.Put_Line('no CompanyName key found');
            Parse_Log_s := Parse_Log_s || Chr(13) || Chr(10) || 'no CompanyName key found';
            Status      := 1;
          END IF;
          --</ company />--   
        
          IF Companyid_t IS NOT NULL
          THEN
            --< jobAd initial insert >--
            Dbms_Output.Put_Line('Inserting initial jobAd');
            Parse_Log_s := Parse_Log_s || Chr(13) || Chr(10) || 'Inserting initial jobAd';
            INSERT INTO t_Jobad (Jobadid, Companyid, Countryid) VALUES (Jobadid_Scr, Companyid_t, Countryid_t);
            COMMIT;
            --</ jobAd initial insert />--
          
            --< department >--
            IF (Obj.Exist('Departament'))
            THEN
              Tempdata := Obj.Get('Departament');
              Tempdata := Obj.Get('Departament');
              IF (Tempdata.Is_Array)
              THEN
                Templist := Json_List(Tempdata);
                IF Templist.Count > 0
                THEN
                  FOR Iter IN 1 .. Templist.Count
                  LOOP
                    Tempdata := Templist.Get(Iter);
                    Dbms_Output.Put_Line('jobAd department: ' || Tempdata.Get_String);
                    Parse_Log_s := Parse_Log_s || Chr(13) || Chr(10) || 'jobAd department: ' || Tempdata.Get_String;
                    BEGIN
                      SELECT Departmentid
                        INTO Departmentid_t
                        FROM t_Departments t
                       WHERE TRIM(t.Departmentname) = TRIM(Tempdata.Get_String)
                          OR TRIM(t.Departmentnamealt) = TRIM(Tempdata.Get_String);
                      --insert into T_activeJobAdsDepartments
                      --dbms_output.put_line('inserting: '||jobadid_scr||' '||Companyid_t||' '||Countryid_t||' '||Departmentid_t);
                      INSERT INTO t_Activejobadsdepartments
                        (Jobadid, Companyid, Countryid, Departmentid)
                      VALUES
                        (Jobadid_Scr, Companyid_t, Countryid_t, Departmentid_t);
                      COMMIT;
                      Dbms_Output.Put_Line('inserted into T_activeJobAdsDepartments');
                      Parse_Log_s := Parse_Log_s || Chr(13) || Chr(10) || 'inserted into T_activeJobAdsDepartments';
                    EXCEPTION
                      WHEN No_Data_Found THEN
                        Dbms_Output.Put_Line('department does not exist check the master data');
                        Parse_Log_s := Parse_Log_s || Chr(13) || Chr(10) || 'department does not exist check the master data';
                    END;
                  END LOOP;
                ELSE
                  Dbms_Output.Put_Line('Department list is empty');
                  Parse_Log_s := Parse_Log_s || Chr(13) || Chr(10) || 'Department list is empty';
                END IF;
              ELSE
                Dbms_Output.Put_Line('Department should be a list');
                Parse_Log_s := Parse_Log_s || Chr(13) || Chr(10) || 'Department should be a list';
              END IF;
            ELSE
              Dbms_Output.Put_Line('no Departament key found');
              Parse_Log_s := Parse_Log_s || Chr(13) || Chr(10) || 'no Departament key found';
            END IF;
            --</ department />--      
          
            --< jobType >--
            IF (Obj.Exist('TipJob'))
            THEN
              Tempdata := Obj.Get('TipJob');
              Tempdata := Obj.Get('TipJob');
              IF (Tempdata.Is_Array)
              THEN
                Templist := Json_List(Tempdata);
                IF Templist.Count > 0
                THEN
                  FOR Iter IN 1 .. Templist.Count
                  LOOP
                    Tempdata := Templist.Get(Iter);
                    Dbms_Output.Put_Line('jobAd tipjob: ' || Tempdata.Get_String);
                    Parse_Log_s := Parse_Log_s || Chr(13) || Chr(10) || 'jobAd tipjob: ' || Tempdata.Get_String;
                    BEGIN
                      SELECT Jobadtypeid
                        INTO Jobadtypeid_t
                        FROM t_Jobtype t
                       WHERE TRIM(t.Jobadtypename) = TRIM(Tempdata.Get_String);
                      --insert into T_jobAdJobType
                      --dbms_output.put_line('inserting: '||jobadid_scr||' '||Companyid_t||' '||Countryid_t||' '||jobadtypeid_t);
                      INSERT INTO t_Jobadjobtype
                        (Jobadtypeid, Jobadid, Companyid, Countryid)
                      VALUES
                        (Jobadtypeid_t, Jobadid_Scr, Companyid_t, Countryid_t);
                      COMMIT;
                      Dbms_Output.Put_Line('inserted into T_jobAdJobType');
                      Parse_Log_s := Parse_Log_s || Chr(13) || Chr(10) || 'inserted into T_jobAdJobType';
                    EXCEPTION
                      WHEN No_Data_Found THEN
                        Dbms_Output.Put_Line('jobType does not exist check the master data');
                        Parse_Log_s := Parse_Log_s || Chr(13) || Chr(10) || 'jobType does not exist check the master data';
                    END;
                  END LOOP;
                ELSE
                  Dbms_Output.Put_Line('jobType list is empty');
                  Parse_Log_s := Parse_Log_s || Chr(13) || Chr(10) || 'jobType list is empty';
                END IF;
              ELSE
                Dbms_Output.Put_Line('jobType should be a list');
                Parse_Log_s := Parse_Log_s || Chr(13) || Chr(10) || 'jobType should be a list';
              END IF;
            ELSE
              Dbms_Output.Put_Line('no jobType key found');
              Parse_Log_s := Parse_Log_s || Chr(13) || Chr(10) || 'no jobType key found';
            END IF;
            --</ jobType />-- 
          
            --< careerLevel >--
            IF (Obj.Exist('NivelCariera'))
            THEN
              Tempdata := Obj.Get('NivelCariera');
              Tempdata := Obj.Get('NivelCariera');
              IF (Tempdata.Is_Array)
              THEN
                Templist := Json_List(Tempdata);
                IF Templist.Count > 0
                THEN
                  FOR Iter IN 1 .. Templist.Count
                  LOOP
                    Tempdata := Templist.Get(Iter);
                    Dbms_Output.Put_Line('jobAd careerLevel: ' || Tempdata.Get_String);
                    Parse_Log_s := Parse_Log_s || Chr(13) || Chr(10) || 'jobAd careerLevel: ' || Tempdata.Get_String;
                    BEGIN
                      SELECT Careerlevelid
                        INTO Careerlevelid_t
                        FROM t_Careerlevel t
                       WHERE TRIM(t.Careerlevelnamealt) = TRIM(Tempdata.Get_String)
                          OR TRIM(t.Careerlevelname) = TRIM(Tempdata.Get_String);
                      --insert into T_jobAdCareerLevel
                      --dbms_output.put_line('inserting: '||jobadid_scr||' '||Companyid_t||' '||Countryid_t||' '||careerLevelId_t);
                      INSERT INTO t_Jobadcareerlevel
                        (Careerlevelid, Jobadid, Companyid, Countryid)
                      VALUES
                        (Careerlevelid_t, Jobadid_Scr, Companyid_t, Countryid_t);
                      COMMIT;
                      Dbms_Output.Put_Line('inserted into T_jobAdCareerLevel');
                      Parse_Log_s := Parse_Log_s || Chr(13) || Chr(10) || 'inserted into T_jobAdCareerLevel';
                    EXCEPTION
                      WHEN No_Data_Found THEN
                        Dbms_Output.Put_Line('careerLevel does not exist check the master data');
                        Parse_Log_s := Parse_Log_s || Chr(13) || Chr(10) || 'careerLevel does not exist check the master data';
                    END;
                  END LOOP;
                ELSE
                  Dbms_Output.Put_Line('careerLevel list is empty');
                  Parse_Log_s := Parse_Log_s || Chr(13) || Chr(10) || 'careerLevel list is empty';
                END IF;
              ELSE
                Dbms_Output.Put_Line('careerLevel should be a list');
                Parse_Log_s := Parse_Log_s || Chr(13) || Chr(10) || 'careerLevel should be a list';
              END IF;
            ELSE
              Dbms_Output.Put_Line('no careerLevel key found');
              Parse_Log_s := Parse_Log_s || Chr(13) || Chr(10) || 'no careerLevel key found';
            END IF;
            --</ careerlevel />--
          
            --< driverLicence >--
            IF (Obj.Exist('JobAdDriverLicence'))
            THEN
              Tempdata := Obj.Get('JobAdDriverLicence');
              Tempdata := Obj.Get('JobAdDriverLicence');
              IF (Tempdata.Is_Array)
              THEN
                Templist := Json_List(Tempdata);
                IF Templist.Count > 0
                THEN
                  FOR Iter IN 1 .. Templist.Count
                  LOOP
                    Tempdata := Templist.Get(Iter);
                    Dbms_Output.Put_Line('jobAd driver licence: ' || Tempdata.Get_String);
                    Parse_Log_s := Parse_Log_s || Chr(13) || Chr(10) || 'jobAd driver licence: ' || Tempdata.Get_String;
                    BEGIN
                      SELECT Driverlicenceid
                        INTO Driverlicenceid_t
                        FROM t_Driverlicence t
                       WHERE TRIM(t.Driverlicenceid) = TRIM(Tempdata.Get_String);
                      --insert into T_jobAdDriverLicence
                      --dbms_output.put_line('inserting: '||jobadid_scr||' '||Companyid_t||' '||Countryid_t||' '||driverLicenceId_t);
                      INSERT INTO t_Jobaddriverlicence
                        (Driverlicenceid, Jobadid, Companyid, Countryid)
                      VALUES
                        (Driverlicenceid_t, Jobadid_Scr, Companyid_t, Countryid_t);
                      COMMIT;
                      Dbms_Output.Put_Line('inserted into T_jobAdDriverLicence');
                      Parse_Log_s := Parse_Log_s || Chr(13) || Chr(10) || 'inserted into T_jobAdDriverLicence';
                    EXCEPTION
                      WHEN No_Data_Found THEN
                        Dbms_Output.Put_Line('driverLicence does not exist check the master data');
                        Parse_Log_s := Parse_Log_s || Chr(13) || Chr(10) || 'driverLicence does not exist check the master data';
                    END;
                  END LOOP;
                ELSE
                  Dbms_Output.Put_Line('driverLicence list is empty');
                  Parse_Log_s := Parse_Log_s || Chr(13) || Chr(10) || 'driverLicence list is empty';
                END IF;
              ELSE
                Dbms_Output.Put_Line('driverLicence should be a list');
                Parse_Log_s := Parse_Log_s || Chr(13) || Chr(10) || 'driverLicence should be a list';
              END IF;
            ELSE
              Dbms_Output.Put_Line('no driverLicence key found');
              Parse_Log_s := Parse_Log_s || Chr(13) || Chr(10) || 'no driverLicence key found';
            END IF;
            --</ driverLicence />--      
          
            --< language >--
            IF (Obj.Exist('LimbiStraine'))
            THEN
              Tempdata := Obj.Get('LimbiStraine');
              Tempdata := Obj.Get('LimbiStraine');
              IF (Tempdata.Is_Array)
              THEN
                Templist := Json_List(Tempdata);
                IF Templist.Count > 0
                THEN
                  FOR Iter IN 1 .. Templist.Count
                  LOOP
                    Tempdata := Templist.Get(Iter);
                    Dbms_Output.Put_Line('jobAd foreign languages: ' || Tempdata.Get_String);
                    Parse_Log_s := Parse_Log_s || Chr(13) || Chr(10) || 'jobAd foreign languages: ' || Tempdata.Get_String;
                    BEGIN
                      SELECT Languageid
                        INTO Languageid_t
                        FROM t_Language t
                       WHERE TRIM(t.Languagename) = TRIM(Tempdata.Get_String);
                      --insert into T_jobAdLanguage
                      --dbms_output.put_line('inserting: '||jobadid_scr||' '||Companyid_t||' '||Countryid_t||' '||languageid_t);
                      INSERT INTO t_Jobadlanguage
                        (Languageid, Jobadid, Companyid, Countryid)
                      VALUES
                        (Languageid_t, Jobadid_Scr, Companyid_t, Countryid_t);
                      COMMIT;
                      Dbms_Output.Put_Line('inserted into T_jobAdLanguage');
                      Parse_Log_s := Parse_Log_s || Chr(13) || Chr(10) || 'inserted into T_jobAdLanguage';
                    EXCEPTION
                      WHEN No_Data_Found THEN
                        Dbms_Output.Put_Line('language does not exist check the master data');
                        Parse_Log_s := Parse_Log_s || Chr(13) || Chr(10) || 'language does not exist check the master data';
                    END;
                  END LOOP;
                ELSE
                  Dbms_Output.Put_Line('language list is empty');
                  Parse_Log_s := Parse_Log_s || Chr(13) || Chr(10) || 'language list is empty';
                END IF;
              ELSE
                Dbms_Output.Put_Line('language should be a list');
                Parse_Log_s := Parse_Log_s || Chr(13) || Chr(10) || 'language should be a list';
              END IF;
            ELSE
              Dbms_Output.Put_Line('no language key found');
              Parse_Log_s := Parse_Log_s || Chr(13) || Chr(10) || 'no language key found';
            END IF;
            --</ language />--      
          
            --< industry >--
            IF (Obj.Exist('Industry'))
            THEN
              Tempdata := Obj.Get('Industry');
              Tempdata := Obj.Get('Industry');
              IF (Tempdata.Is_Array)
              THEN
                Templist := Json_List(Tempdata);
                IF Templist.Count > 0
                THEN
                  FOR Iter IN 1 .. Templist.Count
                  LOOP
                    Tempdata := Templist.Get(Iter);
                    Dbms_Output.Put_Line('jobAd industry: ' || Tempdata.Get_String);
                    Parse_Log_s := Parse_Log_s || Chr(13) || Chr(10) || 'jobAd industry: ' || Tempdata.Get_String;
                    BEGIN
                      SELECT Industryid
                        INTO Industryid_t
                        FROM t_Industry t
                       WHERE TRIM(t.Industryname) = TRIM(Tempdata.Get_String)
                          OR TRIM(t.Industrynamealt) = TRIM(Tempdata.Get_String);
                      --insert into T_jobAdIndustry
                      --dbms_output.put_line('inserting: '||jobadid_scr||' '||Companyid_t||' '||Countryid_t||' '||industryid_t);
                      INSERT INTO t_Jobadindustry
                        (Industryid, Jobadid, Companyid, Countryid)
                      VALUES
                        (Industryid_t, Jobadid_Scr, Companyid_t, Countryid_t);
                      COMMIT;
                      Dbms_Output.Put_Line('inserted into T_jobAdIndustry');
                      Parse_Log_s := Parse_Log_s || Chr(13) || Chr(10) || 'inserted into T_jobAdIndustry';
                    EXCEPTION
                      WHEN No_Data_Found THEN
                        Dbms_Output.Put_Line('industry does not exist check the master data');
                        Parse_Log_s := Parse_Log_s || Chr(13) || Chr(10) || 'industry does not exist check the master data';
                    END;
                  END LOOP;
                ELSE
                  Dbms_Output.Put_Line('industry list is empty');
                  Parse_Log_s := Parse_Log_s || Chr(13) || Chr(10) || 'industry list is empty';
                END IF;
              ELSE
                Dbms_Output.Put_Line('industry should be a list');
                Parse_Log_s := Parse_Log_s || Chr(13) || Chr(10) || 'industry should be a list';
              END IF;
            ELSE
              Dbms_Output.Put_Line('no industry key found');
              Parse_Log_s := Parse_Log_s || Chr(13) || Chr(10) || 'no industry key found';
            END IF;
            --</ industry />--
          
            --< city >--
            IF (Obj.Exist('Orase'))
            THEN
              Tempdata := Obj.Get('Orase');
              Tempdata := Obj.Get('Orase');
              IF (Tempdata.Is_Array)
              THEN
                Templist := Json_List(Tempdata);
                IF Templist.Count > 0
                THEN
                  FOR Iter IN 1 .. Templist.Count
                  LOOP
                    Tempdata := Templist.Get(Iter);
                    Dbms_Output.Put_Line('jobAd city: ' || Tempdata.Get_String);
                    Parse_Log_s := Parse_Log_s || Chr(13) || Chr(10) || 'jobAd city: ' || Tempdata.Get_String;
                    BEGIN
                      SELECT Cityid, Countyid
                        INTO Cityid_t, Countyid_t
                        FROM t_City t
                       WHERE TRIM(t.Cityname) = Upper(TRIM(Tempdata.Get_String));
                      --insert into T_jobAdcity
                      --dbms_output.put_line('inserting: '||jobadid_scr||' '||Companyid_t||' '||Countryid_t||' '||cityid_t||' '||Countyid_t);
                      INSERT INTO t_Jobadcity
                        (Jobadid, Companyid, Countryid, Cityid, Countyid)
                      VALUES
                        (Jobadid_Scr, Companyid_t, Countryid_t, Cityid_t, Countyid_t);
                      COMMIT;
                      Dbms_Output.Put_Line('inserted into T_jobAdcity');
                      Parse_Log_s := Parse_Log_s || Chr(13) || Chr(10) || 'inserted into T_jobAdcity';
                    EXCEPTION
                      WHEN No_Data_Found THEN
                        Dbms_Output.Put_Line('city does not exist check the master data');
                        Parse_Log_s := Parse_Log_s || Chr(13) || Chr(10) || 'city does not exist check the master data';
                      WHEN Too_Many_Rows THEN
                        SELECT Cityid, Countyid
                          INTO Cityid_t, Countyid_t
                          FROM t_City t
                         WHERE TRIM(t.Cityname) = Upper(TRIM(Tempdata.Get_String))
                           AND t.Citytype = 'U'
                           AND Rownum = 1;
                        --insert into T_jobAdcity
                        --dbms_output.put_line('inserting: '||jobadid_scr||' '||Companyid_t||' '||Countryid_t||' '||cityid_t||' '||Countyid_t);
                        INSERT INTO t_Jobadcity
                          (Jobadid, Companyid, Countryid, Cityid, Countyid)
                        VALUES
                          (Jobadid_Scr, Companyid_t, Countryid_t, Cityid_t, Countyid_t);
                        COMMIT;
                        Dbms_Output.Put_Line('inserted into T_jobAdcity');
                        Parse_Log_s := Parse_Log_s || Chr(13) || Chr(10) || 'inserted into T_jobAdcity';
                      
                    END;
                  END LOOP;
                ELSE
                  Dbms_Output.Put_Line('Orase list is empty');
                  Parse_Log_s := Parse_Log_s || Chr(13) || Chr(10) || 'Orase list is empty';
                END IF;
              ELSE
                Dbms_Output.Put_Line('Orase should be a list');
                Parse_Log_s := Parse_Log_s || Chr(13) || Chr(10) || 'Orase should be a list';
              END IF;
            ELSE
              Dbms_Output.Put_Line('no Orase key found');
              Parse_Log_s := Parse_Log_s || Chr(13) || Chr(10) || 'no Orase key found';
            END IF;
            --</ city />--  
          
            --<< update JobAd >>--
          
            --< jobAdTitle >--
            IF (Obj.Exist('JobTitle'))
            THEN
              Tempdata := Obj.Get('JobTitle');
              Tempdata := Obj.Get('JobTitle');
              IF (Tempdata.Is_Array)
              THEN
                Templist := Json_List(Tempdata);
                IF Templist.Count > 0
                THEN
                  Tempdata := Templist.Get(1);
                  Dbms_Output.Put_Line('jobAd JobTitle: ' || Tempdata.Get_String);
                  Parse_Log_s := Parse_Log_s || Chr(13) || Chr(10) || 'jobAd JobTitle: ' || Tempdata.Get_String;
                  Jobtitle_t  := Tempdata.Get_String;
                ELSE
                  Dbms_Output.Put_Line('JobTitle list is empty');
                  Parse_Log_s := Parse_Log_s || Chr(13) || Chr(10) || 'JobTitle list is empty';
                END IF;
              ELSE
                Dbms_Output.Put_Line('JobTitle should be a list');
                Parse_Log_s := Parse_Log_s || Chr(13) || Chr(10) || 'JobTitle should be a list';
              END IF;
            ELSE
              Dbms_Output.Put_Line('no jobtitle key found');
              Parse_Log_s := Parse_Log_s || Chr(13) || Chr(10) || 'no jobtitle key found';
            END IF;
            --</ jobAdTitle />--
          
            --< jobAdStartDate >--
            IF (Obj.Exist('JobAdStartDate'))
            THEN
              Tempdata := Obj.Get('JobAdStartDate');
              Tempdata := Obj.Get('JobAdStartDate');
              IF (Tempdata.Is_Array)
              THEN
                Dbms_Output.Put_Line('JobAdStartDate should not be a list');
                Parse_Log_s := Parse_Log_s || Chr(13) || Chr(10) || 'JobAdStartDate should not be a list';
              ELSE
                Dbms_Output.Put_Line('jobAd JobAdStartDate: ' || Tempdata.Get_String);
                Jobadstartdate_t := Tempdata.Get_String;
                BEGIN
                  Tdate := To_Date(Jobadstartdate_t, 'DD MON YYYY');
                EXCEPTION
                  WHEN OTHERS THEN
                    Jobadstartdate_t := To_Char(SYSDATE, 'DD MON YYYY');
                END;
              END IF;
            ELSE
              Dbms_Output.Put_Line('no JobAdStartDate key found');
              Parse_Log_s := Parse_Log_s || Chr(13) || Chr(10) || 'no JobAdStartDate key found';
            END IF;
            --</ jobAdStartDate />--
          
            --< jobAdEndDate >--
            IF (Obj.Exist('JobAdExpireDate'))
            THEN
              Tempdata := Obj.Get('JobAdExpireDate');
              Tempdata := Obj.Get('JobAdExpireDate');
              IF (Tempdata.Is_Array)
              THEN
                Dbms_Output.Put_Line('JobAdExpireDate should not be a list');
                Parse_Log_s := Parse_Log_s || Chr(13) || Chr(10) || 'JobAdExpireDate should not be a list';
              ELSE
                Dbms_Output.Put_Line('jobAd jobAdEndDate: ' || Tempdata.Get_String);
                Parse_Log_s    := Parse_Log_s || Chr(13) || Chr(10) || 'jobAd jobAdEndDate: ' || Tempdata.Get_String;
                Jobadenddate_t := Tempdata.Get_String;
                BEGIN
                
                  Tdate := To_Date(Jobadenddate_t, 'DD MON YYYY');
                EXCEPTION
                  WHEN OTHERS THEN
                    Jobadenddate_t := To_Date(SYSDATE + 7, 'DD MON YYYY');
                END;
              END IF;
            ELSE
              Dbms_Output.Put_Line('no JobAdExpireDate key found');
              Parse_Log_s := Parse_Log_s || Chr(13) || Chr(10) || 'no JobAdExpireDate key found';
            END IF;
            --</ jobAdEndDate />--
          
            --< jobadpositionsnr >--
            IF (Obj.Exist('NrJoburi'))
            THEN
              Tempdata := Obj.Get('NrJoburi');
              Tempdata := Obj.Get('NrJoburi');
              IF (Tempdata.Is_Array)
              THEN
                Dbms_Output.Put_Line('NrJoburi should not be a list');
                Parse_Log_s := Parse_Log_s || Chr(13) || Chr(10) || 'NrJoburi should not be a list';
              ELSE
                -- REPLACE(REPLACE( col_name, CHR(10) ), CHR(13) ) to get rid of blank lines
                Dbms_Output.Put_Line('jobAd jobadpositionsnr: ' || TRIM(REPLACE(REPLACE(Tempdata.Get_String, Chr(10)), Chr(13))));
                Parse_Log_s        := Parse_Log_s || Chr(13) || Chr(10) || 'jobAd jobadpositionsnr: ' ||
                                      TRIM(REPLACE(REPLACE(Tempdata.Get_String, Chr(10)), Chr(13)));
                Jobadpositionsnr_t := TRIM(REPLACE(REPLACE(Tempdata.Get_String, Chr(10)), Chr(13)));
              END IF;
            ELSE
              Dbms_Output.Put_Line('no NrJoburi key found');
              Parse_Log_s := Parse_Log_s || Chr(13) || Chr(10) || 'no NrJoburi key found';
            END IF;
            --</ jobadpositionsnr />--
          
            --< Jobadapplicantsnr >--
            IF (Obj.Exist('JobAdApplicantsNr'))
            THEN
              Tempdata := Obj.Get('JobAdApplicantsNr');
              Tempdata := Obj.Get('JobAdApplicantsNr');
              IF (Tempdata.Is_Array)
              THEN
                Dbms_Output.Put_Line('JobAdApplicantsNr should not be a list');
                Parse_Log_s := Parse_Log_s || Chr(13) || Chr(10) || 'JobAdApplicantsNr should not be a list';
              ELSE
                -- REPLACE(REPLACE( col_name, CHR(10) ), CHR(13) ) to get rid of blank lines
                Dbms_Output.Put_Line('jobAd Jobadapplicantsnr: ' ||
                                     TRIM(REPLACE(REPLACE(Tempdata.Get_String, Chr(10)), Chr(13))));
                Parse_Log_s         := Parse_Log_s || Chr(13) || Chr(10) || 'jobAd Jobadapplicantsnr: ' ||
                                       TRIM(REPLACE(REPLACE(Tempdata.Get_String, Chr(10)), Chr(13)));
                Jobadapplicantsnr_t := TRIM(REPLACE(REPLACE(Tempdata.Get_String, Chr(10)), Chr(13)));
              END IF;
            ELSE
              Dbms_Output.Put_Line('no JobAdApplicantsNr key found');
              Parse_Log_s := Parse_Log_s || Chr(13) || Chr(10) || 'no JobAdApplicantsNr key found';
            END IF;
            --</ Jobadapplicantsnr />--
          
            --updating T_jobAd
            Dbms_Output.Put_Line('updating JOB AD: ' || Jobadid_Scr || ' ' || Companyid_t || ' ' || Countryid_t);
            Parse_Log_s := Parse_Log_s || Chr(13) || Chr(10) || 'updating JOB AD: ' || Jobadid_Scr || ' ' || Companyid_t || ' ' ||
                           Countryid_t;
          
            UPDATE t_Jobad t
               SET t.Jobtitle          = Jobtitle_t,
                   t.Jobadstartdate    = To_Date(Jobadstartdate_t, 'DD MON YYYY'),
                   t.Jobadenddate      = To_Date(Jobadenddate_t, 'DD MON YYYY'),
                   t.Jobadpositionsnr  = Jobadpositionsnr_t,
                   t.Jobadapplicantsnr = Jobadapplicantsnr_t
             WHERE t.Jobadid = Jobadid_Scr
               AND t.Companyid = Companyid_t
               AND t.Countryid = Countryid_t;
            COMMIT;
          
            Dbms_Output.Put_Line('updated tjobad jobadid: ' || Jobadid_Scr);
            Parse_Log_s := Parse_Log_s || Chr(13) || Chr(10) || 'updated tjobad jobadid: ' || Jobadid_Scr;
            --<</ update jobAd />>--
          
          ELSE
            Dbms_Output.Put_Line('JobAdType not 1 No proceding to flag the jobAd for a diferent type of processing');
            Parse_Log_s := Parse_Log_s || Chr(13) || Chr(10) ||
                           'JobAdType not 1 No proceding to flag the jobAd for a diferent type of processing';
            Status      := 1;
          END IF;
        END IF;
      ELSE
        Dbms_Output.Put_Line('jobAdType json not found, malformed jobAd, flagging as with no jobAdType err=1');
        Parse_Log_s := Parse_Log_s || Chr(13) || Chr(10) ||
                       'jobAdType json not found, malformed jobAd, flagging as with no jobAdType err=1';
        Status      := 1;
      END IF;
    
    ELSE
      Dbms_Output.Put_Line('CompanyName list is empty');
      Parse_Log_s := Parse_Log_s || Chr(13) || Chr(10) || 'CompanyName list is empty';
      Status      := 1;
    END IF;
  
    IF Status = 0
    THEN
      UPDATE t_Scrappedads t SET t.Parselog = Parse_Log_s, t.Parsed = 'Y' WHERE t.Scrapeid = Scrapeid_t;
    ELSE
      UPDATE t_Scrappedads t SET t.Parselog = Parse_Log_s, t.Parsed = 'E' WHERE t.Scrapeid = Scrapeid_t;
      DELETE FROM t_Jobad t
       WHERE t.Jobadid = Jobadid_Scr
         AND t.Companyid = Companyid_t
         AND t.Countryid = Countryid_t;
    END IF;
  
    COMMIT;
  
  EXCEPTION
    WHEN OTHERS THEN
      DELETE FROM t_Jobad t
       WHERE t.Jobadid = Jobadid_Scr
         AND t.Companyid = Companyid_t
         AND t.Countryid = Countryid_t;
      UPDATE t_Scrappedads t SET t.Parselog = Parse_Log_s, t.Parsed = 'E' WHERE t.Scrapeid = Scrapeid_t;
      COMMIT;
      Status := 1;
    
  END Insertjobad;

  PROCEDURE Processnewjobads IS
    l_Starttime BINARY_INTEGER;
    l_Startdate DATE;
    Parse_Log_t VARCHAR2(32767) := '';
    Parsestate  NUMBER;
    Insertstate NUMBER := 0;
    Newjobadsnr NUMBER;
  BEGIN
  
    l_Starttime := Dbms_Utility.Get_Time;
    l_Startdate := SYSDATE;
  
    SELECT COUNT(*) INTO Newjobadsnr FROM t_Scrappedads WHERE Parsed = 'N';
    IF Newjobadsnr = 0
    THEN
      Dbms_Output.Put_Line('No new JobAds jsons to parse. Job finished');
      Pr_Log_Job_Message_Success(0,
                                 0,
                                 0,
                                 'processNewJobAds',
                                 To_Char(Newjobadsnr) || ' No new JobAds jsons to parse. Job finished',
                                 l_Starttime,
                                 l_Startdate);
    ELSE
    
      FOR i IN (SELECT Scrapeid, Jobadjson, Jsontypeid FROM t_Scrappedads WHERE Parsed = 'N')
      LOOP
        IF i.Jsontypeid = 1
        THEN
          Insertjobad(Scrapy_Item => i.Jobadjson, Scrapeid_t => i.Scrapeid);
        
        ELSE
          Dbms_Output.Put_Line('Parsing of the Specified JSON Type Source is not supported skipping');
          UPDATE t_Scrappedads SET Parsed = 'S' WHERE Scrapeid = i.Scrapeid;
          COMMIT;
        END IF;
      END LOOP;
    
      Pr_Log_Job_Message_Success(0,
                                 0,
                                 0,
                                 'processNewJobAds',
                                 'Total jobAds parsed: ' || ' Job Ad parse complete ',
                                 l_Starttime,
                                 l_Startdate);
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      Pr_Log_Job_Message_Error(SQLCODE,
                               SQLERRM,
                               0,
                               0,
                               0,
                               'processNewJobAds',
                               'Exception cauth ' || To_Char(Newjobadsnr) || 'Not all job Ads parsed due to logged exception. ' ||
                               Display_Error_Stack,
                               l_Starttime,
                               l_Startdate);
      ROLLBACK;
  END Processnewjobads;

BEGIN
  -- Initialization
  -- <Statement>;

  NULL;
END Jobad_Load;
/
