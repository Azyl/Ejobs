PL/SQL Developer Test script 3.0
423
-- Created on 28-03-2015 2124:53I53:33 by ANDREITATARU 
DECLARE
  -- Local variables here
  Scrapy_Item VARCHAR2(32767) := '{"Industry": ["Call-center / BPO"], "Oferta": ["nespecificat"], "JobAddLink": "http://www.ejobs.ro/user/locuri-de-munca/digital-writer-with-italian-galati/645372/sqi", "SourcePage": "http://wwww.ejobs.ro/user/searchjobs?q=&oras%5B%5D=&departament%5B%5D=&industrie%5B%5D=&searchType=simple&time_span=&page_no=&page_results=", "NivelCariera": ["Student", "Entry-Level/Primii 3 Ani Exp", "Mid-Level/Peste 3 Ani Exp"], "JobAdStartDate": "14 Mar 2015", "Departament": ["Relatii clienti / Call center"], "CompanyName": ["WEBHELP ROMANIA"], "JobAdDescription": ["<div class=\"job-content\">\r\n\r\n                            <div class=\"job-content-block\">\r\n                    <h2>Candidatul ideal:</h2>\r\n                    <p>IDEAL CANDIDATE:</p>\n<p>Webhelp Romania is a growing company searching for new enthusiastic and communicative colleagues, that like working in teams.<br>Knowing that you will be in a perpetual contact with our clients, you will learn how to answer to our needs and to rapidly adapt to changes while having a positive attitude.<br>We are going to work together in order to help you master the art of communication and that of client relations in order to deliver services of the highest quality.<br>Integrating our teams in order to enrich you personnel experience and learn to master in Italian the communication tools and great number of activities.</p>\r\n                </div>\r\n            \r\n                            <div class=\"job-content-block\" itemprop=\"description\">\r\n                    <h2>Descrierea jobului:</h2>\r\n                    <p>RESPONSABILITIES:</p>\n<p>Publishing the special offers in the field of tourism.<br>Targeting as best as possible the needs of our clients.<br>Collecting information in collaboration with our commercials.<br>Writing original offers and ensure the good publication of the deals.</p>\n<p>BENEFITS:</p>\n<p>In order to help you during your professional career, Webhelp Romania is proposing advanced trainings (paid) that prepare you for the missions that you are going to have inside the company.<br>With well placed sites (in the city centers), we propose to you flexible working hours adapted to your needs.<br>All the promotions are done inside the company and we do everything in our power to offer you a professional career inside our company.<br>Attractive revenue (salary, individual and monthly bonuses, subsidies, etc.)</p>\r\n                </div>\r\n            \r\n                            <div class=\"job-content-block\">\r\n                    <h2>Descrierea companiei:</h2>\r\n                    <p>COMPANY DESCRIPTION:</p>\n<p>N\u00b02 outsourcing company in France and N\u00b03 in Europe, Webhelp Group is an international operator specialized in Customer Relationship management with the fastest growth in its sector between 2002 and 2012.<br>The group has a turnover of more than 500 million euros thanks to its 165 global clients. Daily, 22 000 employees are in contact with customers on 45 production sites from 10 countries: France, Belgium, Romania, Morocco, Algeria, UK, South Africa, Madagascar, Netherlands and Surinam.,<br>Webhelp has more than 1600 employees in Romania on four sites in Bucharest, Ploiesti and Galati.</p>\r\n                </div>\r\n            \r\n        </div>"], "JobTitle": ["DIGITAL WRITER WITH ITALIAN - Galati "], "TipJob": ["Full time"], "JobAdType": 1, "ScrapeDate": "2015-03-28 20:02:14", "Orase": ["Galati"], "JobAdApplicantsNr": "\r\n                                                    89\r\n                                            ", "JobAdSelectionCriteria": [], "JobAdExpireDate": "14 Apr 2015", "NrJoburi": "\r\n                        5\r\n                    "}';

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
  Tdate               DATE;
  Temp_s              VARCHAR2(32767);
  Temp_S2             VARCHAR2(32767);

  Scrapeid_t NUMBER := 1;
BEGIN

  DELETE FROM t_Jobad;
  COMMIT;

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
    
      --< company >--
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
      --</ company />--   
    
      IF Companyid_t IS NOT NULL
      THEN
        --< jobAd initial insert >--
        Parse_Log_s := Parse_Log_s || Chr(13) || Chr(10) || 'Inserting initial jobAd';
        INSERT INTO t_Jobad (Jobadid, Companyid, Countryid) VALUES (Jobadid_Scr, Companyid_t, Countryid_t);
        COMMIT;
        --</ jobAd initial insert />--
      END IF;
    
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
          Tempdata       := Substr(Temp_s, 0, Instr(Temp_s, ';') - 1);
          Departmentid_t := Getjobadtypeid(Jobadtype_Name => Tempdata);
          IF (Departmentid_t IS NOT NULL)
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
          IF (Departmentid_t IS NOT NULL)
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
          IF (Departmentid_t IS NOT NULL)
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
          IF (Departmentid_t IS NOT NULL)
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
          IF (Departmentid_t IS NOT NULL)
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
            Cityid_t   := Substr(Temp_S2, 1, (Instr(Temp_S2, ';') - 1));
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
        Jobadstartdate_t := Substr(Temp_s, 0, Instr(Temp_s, ';') - 1);
        BEGIN
          Tdate := To_Date(Jobadstartdate_t, 'DD MON YYYY');
        EXCEPTION
          WHEN OTHERS THEN
            Jobadstartdate_t := To_Char(SYSDATE, 'DD MON YYYY');
        END;
        Tdate       := To_Date(Jobadstartdate_t, 'DD MON YYYYYY');
        Parse_Log_s := Parse_Log_s || Chr(13) || Chr(10) || 'JobAdStartDate: ' || Jobadstartdate_t;
      ELSE
        Parse_Log_s := Parse_Log_s || Chr(13) || Chr(10) || 'no JobAdStartDate key found';
      END IF;
      --</ jobAdStartDate />--
    
      --< jobAdEndDate >--
      Temp_s := Getjsonvalue(Jsonstring => Scrapy_Item, Sparam => 'JobAdExpireDate');
      IF (Temp_s IS NOT NULL)
      THEN
        Jobadenddate_t := Substr(Temp_s, 0, Instr(Temp_s, ';') - 1);
        BEGIN
          Tdate := To_Date(Jobadstartdate_t, 'DD MON YYYY');
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
        Jobadpositionsnr_t := Substr(Temp_s, 0, Instr(Temp_s, ';') - 1);
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
        Jobadapplicantsnr_t := Substr(Temp_s, 0, Instr(Temp_s, ';') - 1);
        Jobadapplicantsnr_t := TRIM(REPLACE(REPLACE(Jobadpositionsnr_t, Chr(10)), Chr(13)));
        Parse_Log_s         := Parse_Log_s || Chr(13) || Chr(10) || 'JobAdApplicantsNr: ' || Jobadapplicantsnr_t;
      ELSE
        Parse_Log_s := Parse_Log_s || Chr(13) || Chr(10) || 'no JobAdApplicantsNr key found';
      END IF;
      --</ Jobadapplicantsnr />--
    
      --updating T_jobAd
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
    
      Parse_Log_s := Parse_Log_s || Chr(13) || Chr(10) || 'updated tjobad jobadid: ' || Jobadid_Scr;
      --<</ update jobAd />>--
    
    ELSE
      Parse_Log_s := Parse_Log_s || Chr(13) || Chr(10) ||
                     'JobAdType not 1 No proceding to flag the jobAd for a diferent type of processing';
      Status      := 1;
    END IF;
  
  END IF;
  Dbms_Output.Put_Line(Parse_Log_s);

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

  /*  EXCEPTION
  WHEN OTHERS THEN
    DELETE FROM t_Jobad t
     WHERE t.Jobadid = Jobadid_Scr
       AND t.Companyid = Companyid_t
       AND t.Countryid = Countryid_t;
    UPDATE t_Scrappedads t SET t.Parselog = Parse_Log_s, t.Parsed = 'E' WHERE t.Scrapeid = Scrapeid_t;
    COMMIT;
    Status := 1;*/

  --Dbms_Output.Put_Line(Returnvalue);
END;
4
Temp_s
0
0
Tempdata
0
0
Departmentid_t
0
0
Parse_Log_s
0
0
7
Temp_s
Tempdata
Departmentid_t
Parse_Log_s
Cityid_t
Countyid_t
Temp_S2
