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

  FUNCTION Display_Call_Stack RETURN VARCHAR2 AS
    Temp_String VARCHAR2(32767);
    l_Depth     PLS_INTEGER;
  BEGIN
    l_Depth := Utl_Call_Stack.Dynamic_Depth;
  
    Dbms_Output.Put_Line('***** Call Stack Start *****');
  
    Temp_String := Temp_String || Chr(13) || Chr(10) || 'Depth     Lexical   Line      Owner     Edition   Name';
    Temp_String := Temp_String || Chr(13) || Chr(10) || '.         Depth     Number';
    Temp_String := Temp_String || Chr(13) || Chr(10) || '--------- --------- --------- --------- --------- --------------------';
  
    FOR i IN REVERSE 1 .. l_Depth
    LOOP
      Temp_String := Temp_String || Chr(13) || Chr(10) || Rpad(i, 10) || Rpad(Utl_Call_Stack.Lexical_Depth(i), 10) ||
                     Rpad(To_Char(Utl_Call_Stack.Unit_Line(i), '99'), 10) || Rpad(Nvl(Utl_Call_Stack.Owner(i), ' '), 10) ||
                     Rpad(Nvl(Utl_Call_Stack.Current_Edition(i), ' '), 10) ||
                     Utl_Call_Stack.Concatenate_Subprogram(Utl_Call_Stack.Subprogram(i));
    END LOOP;
  
    Temp_String := Temp_String || Chr(13) || Chr(10) || '***** Call Stack End *****';
  
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
    Loop_Cnt            NUMBER;
    Tempdata            VARCHAR2(32767);
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
    Jobaddescription_t  VARCHAR2(32767);
    Tdate               DATE;
    Temp_s              VARCHAR2(32767);
    Temp_S2             VARCHAR2(32767);
  BEGIN
  
    Parse_Log_s := Parse_Log_s || 'Processing JSON input:';
    Parse_Log_s := Parse_Log_s || Chr(13) || Chr(10) || Scrapy_Item;
  
    Temp_s := Getjsonvalue(Jsonstring => Scrapy_Item, Sparam => 'JobAdType');
  
    IF (Temp_s IS NOT NULL)
    THEN
      Parse_Log_s := Parse_Log_s || Chr(13) || Chr(10) || 'jobAdType json found';
      IF (To_Number(Temp_s) = 1)
      THEN
        Jobadtypeid_t := Temp_s;
        Parse_Log_s   := Parse_Log_s || Chr(13) || Chr(10) || 'JobAdType 1 Yes proceding to insert the jobAd';
        Jobadid_Scr   := Scrapeid_t;
        Parse_Log_s   := Parse_Log_s || Chr(13) || Chr(10) || 'jobadid = ' || Scrapeid_t;
        --< country >--
        Countryid_t := 642;
        --toate anunturile sunt ale unor firme din Romania
        --</ country />--
      END IF;
    ELSE
      Parse_Log_s := Parse_Log_s || Chr(13) || Chr(10) || 'JobAdType key not found = ';
      Status      := 1;
    END IF;
    --< company >--
  
    IF (Status = 0)
    THEN
      Temp_s := Getjsonvalue(Jsonstring => Scrapy_Item, Sparam => 'CompanyName');
      Temp_s := REPLACE(Temp_s, ';');
      IF (Temp_s IS NOT NULL)
      THEN
        Companyid_t := Getcompanyid(Company_Name => Temp_s);
        IF (Companyid_t IS NULL)
        THEN
          Parse_Log_s := Parse_Log_s || Chr(13) || Chr(10) || 'no company: ' || Temp_s || ' in database, inserting new company';
          --insert into T_company
          INSERT INTO t_Company (Companyname, Countryid) VALUES (Temp_s, Countryid_t);
          COMMIT;
          SELECT Companyid INTO Companyid_t FROM t_Company t WHERE t.Companyname = Temp_s;
          Parse_Log_s := Parse_Log_s || Chr(13) || Chr(10) || 'new company: ' || 'company inserted: ' || Companyid_t;
        END IF;
      ELSE
        Parse_Log_s := Parse_Log_s || Chr(13) || Chr(10) || 'no CompanyName key found';
        Status      := 1;
      END IF;
    END IF;
    --</ company />--   
  
    IF Companyid_t IS NOT NULL
    THEN
      --< jobAd initial insert >--
      Parse_Log_s := Parse_Log_s || Chr(13) || Chr(10) || 'Inserting initial jobAd';
      INSERT INTO t_Jobad (Jobadid, Companyid, Countryid) VALUES (Jobadid_Scr, Companyid_t, Countryid_t);
      COMMIT;
      --</ jobAd initial insert />--
    
      --< department >--
      Temp_s := Getjsonvalue(Jsonstring => Scrapy_Item, Sparam => 'Departament');
      IF (Temp_s IS NOT NULL)
      THEN
        Loop_Cnt := Regexp_Count(Temp_s, ';');
        FOR Iter IN 1 .. Loop_Cnt
        LOOP
          Tempdata       := Substr(Temp_s, 0, Instr(Temp_s, ';') - 1);
          Departmentid_t := Getdepartmentid(Department_Name => Tempdata);
          IF (Departmentid_t IS NOT NULL)
          THEN
            INSERT INTO t_Activejobadsdepartments
              (Jobadid, Companyid, Countryid, Departmentid)
            VALUES
              (Jobadid_Scr, Companyid_t, Countryid_t, Departmentid_t);
            COMMIT;
            Parse_Log_s := Parse_Log_s || Chr(13) || Chr(10) || 'inserted into T_activeJobAdsDepartments';
          ELSE
            Parse_Log_s := Parse_Log_s || Chr(13) || Chr(10) || 'department does not exist check the master data';
            Status      := 1;
          END IF;
          IF Iter < Loop_Cnt
          THEN
            Temp_s := REPLACE(Temp_s, Tempdata || ';');
          END IF;
        END LOOP;
      ELSE
        Parse_Log_s := Parse_Log_s || Chr(13) || Chr(10) || 'no Departament key found';
      END IF;
      --</ department />--      
    
      --< jobType >--
      Temp_s := Getjsonvalue(Jsonstring => Scrapy_Item, Sparam => 'TipJob');
      IF (Temp_s IS NOT NULL)
      THEN
        Loop_Cnt := Regexp_Count(Temp_s, ';');
        FOR Iter IN 1 .. Loop_Cnt
        LOOP
          Tempdata      := Substr(Temp_s, 0, Instr(Temp_s, ';') - 1);
          Jobadtypeid_t := Getjobadtypeid(Jobadtype_Name => Tempdata);
          IF (Jobadtypeid_t IS NOT NULL)
          THEN
            INSERT INTO t_Jobadjobtype
              (Jobadtypeid, Jobadid, Companyid, Countryid)
            VALUES
              (Jobadtypeid_t, Jobadid_Scr, Companyid_t, Countryid_t);
            COMMIT;
            Parse_Log_s := Parse_Log_s || Chr(13) || Chr(10) || 'inserted into T_jobAdJobType';
          ELSE
            Parse_Log_s := Parse_Log_s || Chr(13) || Chr(10) || 'TipJob does not exist check the master data';
            Status      := 1;
          END IF;
          IF Iter < Loop_Cnt
          THEN
            Temp_s := REPLACE(Temp_s, Tempdata || ';');
          END IF;
        END LOOP;
      ELSE
        Parse_Log_s := Parse_Log_s || Chr(13) || Chr(10) || 'no TipJob key found';
      END IF;
      --</ jobType />-- 
    
      --< careerLevel >--
      Temp_s := Getjsonvalue(Jsonstring => Scrapy_Item, Sparam => 'NivelCariera');
      IF (Temp_s IS NOT NULL)
      THEN
        Loop_Cnt := Regexp_Count(Temp_s, ';');
        FOR Iter IN 1 .. Loop_Cnt
        LOOP
          Tempdata        := Substr(Temp_s, 0, Instr(Temp_s, ';') - 1);
          Careerlevelid_t := Getcareerlevelid(Careerlevel_Name => Tempdata);
          IF (Careerlevelid_t IS NOT NULL)
          THEN
            INSERT INTO t_Jobadcareerlevel
              (Careerlevelid, Jobadid, Companyid, Countryid)
            VALUES
              (Careerlevelid_t, Jobadid_Scr, Companyid_t, Countryid_t);
            COMMIT;
            Parse_Log_s := Parse_Log_s || Chr(13) || Chr(10) || 'inserted into T_jobAdCareerLevel';
          ELSE
            Parse_Log_s := Parse_Log_s || Chr(13) || Chr(10) || 'NivelCariera does not exist check the master data';
            Status      := 1;
          END IF;
          IF Iter < Loop_Cnt
          THEN
            Temp_s := REPLACE(Temp_s, Tempdata || ';');
          END IF;
        END LOOP;
      ELSE
        Parse_Log_s := Parse_Log_s || Chr(13) || Chr(10) || 'no NivelCariera key found';
      END IF;
      --</ careerlevel />--
    
      --< driverLicence >--
      Temp_s := Getjsonvalue(Jsonstring => Scrapy_Item, Sparam => 'JobAdDriverLicence');
      IF (Temp_s IS NOT NULL)
      THEN
        Loop_Cnt := Regexp_Count(Temp_s, ';');
        FOR Iter IN 1 .. Loop_Cnt
        LOOP
          Tempdata          := Substr(Temp_s, 0, Instr(Temp_s, ';') - 1);
          Driverlicenceid_t := Getdriverlicenceid(Driverlicence_Name => Tempdata);
          IF (Driverlicenceid_t IS NOT NULL)
          THEN
            INSERT INTO t_Jobaddriverlicence
              (Driverlicenceid, Jobadid, Companyid, Countryid)
            VALUES
              (Driverlicenceid_t, Jobadid_Scr, Companyid_t, Countryid_t);
            COMMIT;
            Parse_Log_s := Parse_Log_s || Chr(13) || Chr(10) || 'inserted into T_jobAdDriverLicence';
          ELSE
            Parse_Log_s := Parse_Log_s || Chr(13) || Chr(10) || 'driverLicence does not exist check the master data';
            Status      := 1;
          END IF;
          IF Iter < Loop_Cnt
          THEN
            Temp_s := REPLACE(Temp_s, Tempdata || ';');
          END IF;
        END LOOP;
      ELSE
        Parse_Log_s := Parse_Log_s || Chr(13) || Chr(10) || 'no driverLicence key found';
      END IF;
      --</ driverLicence />--      
    
      --< language >--
      Temp_s := Getjsonvalue(Jsonstring => Scrapy_Item, Sparam => 'LimbiStraine');
      IF (Temp_s IS NOT NULL)
      THEN
        Loop_Cnt := Regexp_Count(Temp_s, ';');
        FOR Iter IN 1 .. Loop_Cnt
        LOOP
          Tempdata     := Substr(Temp_s, 0, Instr(Temp_s, ';') - 1);
          Languageid_t := Getlanguageid(Language_Name => Tempdata);
          IF (Languageid_t IS NOT NULL)
          THEN
            INSERT INTO t_Jobadlanguage
              (Languageid, Jobadid, Companyid, Countryid)
            VALUES
              (Languageid_t, Jobadid_Scr, Companyid_t, Countryid_t);
            COMMIT;
            Parse_Log_s := Parse_Log_s || Chr(13) || Chr(10) || 'inserted into T_jobAdLanguage';
          ELSE
            Parse_Log_s := Parse_Log_s || Chr(13) || Chr(10) || 'LimbiStraine does not exist check the master data';
            Status      := 1;
          END IF;
          IF Iter < Loop_Cnt
          THEN
            Temp_s := REPLACE(Temp_s, Tempdata || ';');
          END IF;
        END LOOP;
      ELSE
        Parse_Log_s := Parse_Log_s || Chr(13) || Chr(10) || 'no LimbiStraine key found';
      END IF;
      --</ language />--      
    
      --< industry >--
      Temp_s := Getjsonvalue(Jsonstring => Scrapy_Item, Sparam => 'Industry');
      IF (Temp_s IS NOT NULL)
      THEN
        Loop_Cnt := Regexp_Count(Temp_s, ';');
        FOR Iter IN 1 .. Loop_Cnt
        LOOP
          Tempdata     := Substr(Temp_s, 0, Instr(Temp_s, ';') - 1);
          Industryid_t := Getindustryid(Industry_Name => Tempdata);
          IF (Industryid_t IS NOT NULL)
          THEN
            INSERT INTO t_Jobadindustry
              (Industryid, Jobadid, Companyid, Countryid)
            VALUES
              (Industryid_t, Jobadid_Scr, Companyid_t, Countryid_t);
            COMMIT;
            Parse_Log_s := Parse_Log_s || Chr(13) || Chr(10) || 'inserted into T_jobAdLanguage';
          ELSE
            Parse_Log_s := Parse_Log_s || Chr(13) || Chr(10) || 'Industry does not exist check the master data';
            Status      := 1;
          END IF;
          IF Iter < Loop_Cnt
          THEN
            Temp_s := REPLACE(Temp_s, Tempdata || ';');
          END IF;
        END LOOP;
      ELSE
        Parse_Log_s := Parse_Log_s || Chr(13) || Chr(10) || 'no Industry key found';
      END IF;
      --</ industry />--
    
      --< city >--
      Temp_s := Getjsonvalue(Jsonstring => Scrapy_Item, Sparam => 'Orase');
      IF (Temp_s IS NOT NULL)
      THEN
        Loop_Cnt := Regexp_Count(Temp_s, ';');
        FOR Iter IN 1 .. Loop_Cnt
        LOOP
          Tempdata := Substr(Temp_s, 0, Instr(Temp_s, ';') - 1);
          Temp_S2  := Getcityid(City_Name => Tempdata);
          IF (Temp_S2 IS NOT NULL)
          THEN
            Cityid_t   := Substr(Temp_S2, 1, Instr(Temp_S2, ';') - 1);
            Countyid_t := Substr(Temp_S2, Instr(Temp_S2, ';') + 1);
            INSERT INTO t_Jobadcity
              (Jobadid, Companyid, Countryid, Cityid, Countyid)
            VALUES
              (Jobadid_Scr, Companyid_t, Countryid_t, Cityid_t, Countyid_t);
            COMMIT;
            Parse_Log_s := Parse_Log_s || Chr(13) || Chr(10) || 'inserted into T_jobAdcity';
          ELSE
            Parse_Log_s := Parse_Log_s || Chr(13) || Chr(10) || 'Orase does not exist check the master data';
            Status      := 1;
          END IF;
          IF Iter < Loop_Cnt
          THEN
            Temp_s := REPLACE(Temp_s, Tempdata || ';');
          END IF;
        END LOOP;
      ELSE
        Parse_Log_s := Parse_Log_s || Chr(13) || Chr(10) || 'no Orase key found';
      END IF;
      --</ city />--  
    
      --<< update JobAd >>--
    
      --< jobAdTitle >--
      Temp_s := Getjsonvalue(Jsonstring => Scrapy_Item, Sparam => 'JobTitle');
      IF (Temp_s IS NOT NULL)
      THEN
        Jobtitle_t  := Substr(Temp_s, 0, Instr(Temp_s, ';') - 1);
        Parse_Log_s := Parse_Log_s || Chr(13) || Chr(10) || 'JobTitle: ' || Jobtitle_t;
      ELSE
        Parse_Log_s := Parse_Log_s || Chr(13) || Chr(10) || 'no JobTitle key found';
      END IF;
      --</ jobAdTitle />--
    
      --< jobAdStartDate >--
      Temp_s := Getjsonvalue(Jsonstring => Scrapy_Item, Sparam => 'JobAdStartDate');
      IF (Temp_s IS NOT NULL)
      THEN
        Jobadstartdate_t := Temp_s;
        BEGIN
          Tdate := To_Date(Jobadstartdate_t, 'DD MON YYYY');
        EXCEPTION
          WHEN OTHERS THEN
            Jobadstartdate_t := To_Char(SYSDATE, 'DD MON YYYY');
        END;
        Parse_Log_s := Parse_Log_s || Chr(13) || Chr(10) || 'JobAdStartDate: ' || Jobadstartdate_t;
      ELSE
        Parse_Log_s := Parse_Log_s || Chr(13) || Chr(10) || 'no JobAdStartDate key found';
      END IF;
      --</ jobAdStartDate />--
    
      --< jobAdEndDate >--
      Temp_s := Getjsonvalue(Jsonstring => Scrapy_Item, Sparam => 'JobAdExpireDate');
      IF (Temp_s IS NOT NULL)
      THEN
        Jobadenddate_t := Temp_s;
        BEGIN
          Tdate := To_Date(Jobadenddate_t, 'DD MON YYYY');
        EXCEPTION
          WHEN OTHERS THEN
            Jobadenddate_t := To_Char(SYSDATE + 7, 'DD MON YYYY');
        END;
        Parse_Log_s := Parse_Log_s || Chr(13) || Chr(10) || 'JobAdExpireDate: ' || Jobadenddate_t;
      ELSE
        Parse_Log_s := Parse_Log_s || Chr(13) || Chr(10) || 'no JobAdExpireDate key found';
      END IF;
      --</ jobAdEndDate />--
    
      --< jobadpositionsnr >--
      Temp_s := Getjsonvalue(Jsonstring => Scrapy_Item, Sparam => 'NrJoburi');
      IF (Temp_s IS NOT NULL)
      THEN
        Jobadpositionsnr_t := Temp_s;
        Jobadpositionsnr_t := TRIM(REPLACE(REPLACE(Jobadpositionsnr_t, Chr(10)), Chr(13)));
        Parse_Log_s        := Parse_Log_s || Chr(13) || Chr(10) || 'NrJoburi: ' || Jobadpositionsnr_t;
      ELSE
        Parse_Log_s := Parse_Log_s || Chr(13) || Chr(10) || 'no NrJoburi key found';
      END IF;
      --</ jobadpositionsnr />--
    
      --< Jobadapplicantsnr >--
      Temp_s := Getjsonvalue(Jsonstring => Scrapy_Item, Sparam => 'JobAdApplicantsNr');
      IF (Temp_s IS NOT NULL)
      THEN
        Jobadapplicantsnr_t := Temp_s;
        Jobadapplicantsnr_t := TRIM(REPLACE(REPLACE(Jobadapplicantsnr_t, Chr(10)), Chr(13)));
        Parse_Log_s         := Parse_Log_s || Chr(13) || Chr(10) || 'JobAdApplicantsNr: ' || Jobadapplicantsnr_t;
      ELSE
        Parse_Log_s := Parse_Log_s || Chr(13) || Chr(10) || 'no JobAdApplicantsNr key found';
      END IF;
      --</ Jobadapplicantsnr />--
    
      --< JobAdDescription >--
      Temp_s := Getjsonvalue(Jsonstring => Scrapy_Item, Sparam => 'JobAdDescription');
      IF (Temp_s IS NOT NULL)
      THEN
        Jobaddescription_t := Temp_s;
        Parse_Log_s        := Parse_Log_s || Chr(13) || Chr(10) || 'JobAdDescription: ' || Jobaddescription_t;
      ELSE
        Parse_Log_s := Parse_Log_s || Chr(13) || Chr(10) || 'no JobAdDescription key found';
      END IF;
      --</ JobAdDescription />--
    
      --updating T_jobAd
      Parse_Log_s := Parse_Log_s || Chr(13) || Chr(10) || 'updating JOB AD: ' || Jobadid_Scr || ' ' || Companyid_t || ' ' ||
                     Countryid_t;
    
      UPDATE t_Jobad t
         SET t.Jobtitle          = Jobtitle_t,
             t.Jobaddescription  = Jobaddescription_t,
             t.Jobadstartdate    = To_Date(Jobadstartdate_t, 'DD MON YYYY'),
             t.Jobadenddate      = To_Date(Jobadenddate_t, 'DD MON YYYY'),
             t.Jobadpositionsnr  = Jobadpositionsnr_t,
             t.Jobadapplicantsnr = Jobadapplicantsnr_t,
             t.Jobadjsonhash     = Generatesha1fromjson(Injsonvar => Scrapy_Item)
      
       WHERE t.Jobadid = Jobadid_Scr
         AND t.Companyid = Companyid_t
         AND t.Countryid = Countryid_t;
      COMMIT;
    
      Parse_Log_s := Parse_Log_s || Chr(13) || Chr(10) || 'updated tjobad jobadid: ' || Jobadid_Scr;
      --<</ update jobAd />>--
    
    ELSE
      Parse_Log_s := Parse_Log_s || Chr(13) || Chr(10) ||
                     'JobAdType not 1 No proceding to flag the jobAd for a diferent type of processing';
      Status      := 2;
    END IF;
  
    -- END IF;
  
    IF Status = 0
    THEN
      UPDATE t_Scrappedads t SET t.Parselog = Parse_Log_s, t.Parsed = 'Y' WHERE t.Scrapeid = Scrapeid_t;
    
    ELSIF Status = 2
    THEN
      UPDATE t_Scrappedads t SET t.Parselog = Parse_Log_s, t.Parsed = 'Z' WHERE t.Scrapeid = Scrapeid_t;
      DELETE FROM t_Jobad t
       WHERE t.Jobadid = Jobadid_Scr
         AND t.Companyid = Companyid_t
         AND t.Countryid = Countryid_t;
    
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
      Parse_Log_s := Parse_Log_s || Chr(13) || Chr(10) || SQLCODE || ' ' || SQLERRM || ' ' || Display_Error_Stack || Chr(13) ||
                     Chr(10) || Display_Call_Stack;
      UPDATE t_Scrappedads t SET t.Parselog = Parse_Log_s, t.Parsed = 'X' WHERE t.Scrapeid = Scrapeid_t;
      COMMIT;
      Status := 1;
    
  END Insertjobad;

  PROCEDURE Processnewjobads IS
    l_Starttime     BINARY_INTEGER;
    l_Startdate     DATE;
    Parse_Log_t     VARCHAR2(32767) := '';
    Parsestate      NUMBER;
    Insertstate     NUMBER := 0;
    Newjobadsnr     NUMBER;
    Jobadjsonhash_t VARCHAR2(180);
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
          --<  check sha1 hash of the jobAd  >--
          BEGIN
          
            SELECT Coalesce(t.Jobadjsonhash, 'No Hash') INTO Jobadjsonhash_t FROM t_Jobad t WHERE t.Jobadid = i.Scrapeid;
            IF (Generatesha1fromjson(Injsonvar => i.Jobadjson) <> Jobadjsonhash_t)
            THEN
              DELETE FROM t_Jobad t WHERE t.Jobadid = i.Scrapeid;
              COMMIT;
              Insertjobad(Scrapy_Item => i.Jobadjson, Scrapeid_t => i.Scrapeid);
            ELSE
              UPDATE t_Scrappedads t
                 SET t.Parsed    = 'S',
                     t.Parsetime = SYSDATE,
                     t.Parselog  = t.Parselog || Chr(13) || Chr(10) || 'hash matches no need to parse'
               WHERE t.Scrapeid = i.Scrapeid;
              COMMIT;
            END IF;
          EXCEPTION
            WHEN No_Data_Found THEN
              Insertjobad(Scrapy_Item => i.Jobadjson, Scrapeid_t => i.Scrapeid);
          END;
        
          --    Generatesha1fromjson(Injsonvar => ' test')
          --</ check sha1 hash of the jobAd />--
        
        ELSE
          Dbms_Output.Put_Line('Parsing of the Specified JSON Type Source is not supported skipping');
          UPDATE t_Scrappedads SET Parsed = 'S' WHERE Scrapeid = i.Scrapeid;
          COMMIT;
        END IF;
      END LOOP;
    
      Jobad_Util.Gather_Schema_Stats;
    
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
                               Display_Error_Stack || Chr(13) || Chr(10) || Display_Call_Stack,
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
