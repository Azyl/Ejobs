PL/SQL Developer Test script 3.0
121
-- Created on 07-03-2015 2124:2I2:12 by ANDREITATARU 
DECLARE
  Test_Json    VARCHAR2(32767) := '{"Departament": ["IT Software"], "CompanyName": ["SOFT GALAXY ROMANIA"], "JobAdDescription": ["<div class=\"job-content\">\r\n\r\n                            <div class=\"job-content-block\">\r\n                    <h2>Candidatul ideal:</h2>\r\n                    <p>Excellent knowledge of the Android SDK<br>    Knowledge of XML and JSON a requirement<br>    Knowledge of SqlLite and a working experience in SQL databases<br>    Knowledge of HTML and Javascript a plus<br>    Coding standards, organizational programming skills and good commenting practices is important</p>\r\n                </div>\r\n            \r\n                            <div class=\"job-content-block\" itemprop=\"description\">\r\n                    <h2>Descrierea jobului:</h2>\r\n                    <p>-     Development of mobile Android based apps.<br>-     Deal with clients data, feeds and designs.<br>-     Co-operation with other development team members (e.g. Project manager, Web programmers, graphic designers, and authors, quality assurance) in the production of a finished product.<br> -   Ability to work on project without detailed instructions; taking the initiative with this job is important.<br>-    On-going maintenance of existing projects.</p>\r\n                </div>\r\n            \r\n                            <div class=\"job-content-block\">\r\n                    <h2>Descrierea companiei:</h2>\r\n                    <p>Soft Galaxy is a privately held company based in Bucharest and Tel Aviv. We bring ideas to life by providing industry standard solutions to businesses, from start-up companies to multinational corporations.</p>\n<p>We are a technology solutions company with a mission to provide high-quality technology and outsourcing services that provide a substantial competitive advantage to our clients.</p>\n<p>We provide the ongoing skill development to ensure that professionals working on your projects are trained in leading technologies to support your information technology hardware, software or network infrastructure.</p>\n<p>Our office in Bucharest is located in the French Quarter (near Herastrau Park) with easy access from the tram, metro and busses. Our rapidly growing Bucharest team is made up of Development, Engineering, Quality Assurance, and Support and Operations professionals who are responsible for engineering our company\u2019s cutting edge product offerings and supporting our international clients.\u00a0</p>\n<p>At this time, Soft Galaxy is looking for smart, motivated people to join the Bucharest team and grow our capabilities in each department. \u00a0Working at Soft Galaxy means having the opportunity to work on distributed, multinational teams.\u00a0 Soft Galaxy opens the door for employees to receive technical training and significant growth in their field, as well as the potential opportunity to travel throughout Europe, North America and Eurasian Sector.\u00a0 To find out more about who we are and what we do, visit www.softgalaxy.ro</p>\r\n                </div>\r\n            \r\n        </div>"], "JobTitle": ["Android Developer - Excellent Salary Package "], "TipJob": ["Full time"], "JobAdType": 1, "Oferta": ["> 1500 EURO / month"], "ScrapeDate": "2015-03-06 22:22:49", "JobAddLink": "http://www.ejobs.ro/user/locuri-de-munca/android-developer-excellent-salary-package/659061/sqi", "JobAdStartDate": "06 Mar 2015", "Orase": ["Bucuresti"], "JobAdApplicantsNr": "\r\n                                                    1\r\n                                            ", "JobAdSelectionCriteria": [], "JobAdExpireDate": "06 Apr 2015", "NrJoburi": "\r\n                        4\r\n                    ", "SourcePage": "http://wwww.ejobs.ro/user/searchjobs?q=&oras%5B%5D=&departament%5B%5D=&industrie%5B%5D=&searchType=simple&time_span=&page_no=&page_results=", "NivelCariera": ["Entry-Level/Primii 3 Ani Exp", "Mid-Level/Peste 3 Ani Exp", "Manager/Executive Position"]}';
  Printme      NUMBER := NULL;
  Obj          Json;
  Tempobj      Json;
  Tempdata     Json_Value;
  Templist     Json_List;
  Jobadid      INTEGER;
  Companyid    INTEGER;
  Countryid    INTEGER;
  Departmentid INTEGER;
BEGIN

  Dbms_Output.Put_Line('Processing JSON input:');
  Obj := Json(Test_Json);
  Obj.Print();
  IF (Obj.Exist('JobAdType'))
  THEN
    Dbms_Output.Put_Line('jobAdType json found');
    Tempdata := Obj.Get('JobAdType');
    IF (Tempdata.Is_Number)
    THEN
      Printme := Tempdata.Get_Number;
      IF (Printme IS NOT NULL AND Printme = 1)
      THEN
        Dbms_Output.Put_Line('JobAdType 1 Yes proceding to insert the jobAd');
        Jobadid := Sq_Jobadid.Nextval;
        Dbms_Output.Put_Line('jobAdId = ' || Jobadid);
      
        --< country >--
        Countryid := 642;
        --toate anunturile sunt ale unor firme din romania
        --</ country />--   
      
        --< company >--
        IF (Obj.Exist('CompanyName'))
        THEN
          Tempdata := Obj.Get('CompanyName');
          Tempdata := Obj.Get('CompanyName');
          IF (Tempdata.Is_Array)
          THEN
            Templist := Json_List(Tempdata);
            FOR Iter IN 1 .. Templist.Count
            LOOP
              Tempdata := Templist.Get(Iter);
              Dbms_Output.Put_Line(Tempdata.Get_String);
              -- get companyId
              BEGIN
                SELECT Companyid INTO Companyid FROM t_Company t WHERE t.Companyname = Tempdata.Get_String;
                Dbms_Output.Put_Line('companyId = ' || Companyid || ' ' || Tempdata.Get_String);
              EXCEPTION
                WHEN No_Data_Found THEN
                  Dbms_Output.Put_Line('no company: ' || Tempdata.Get_String || ' in database, inserting new company');
                  --insert into T_company
                  INSERT INTO t_Company (Companyname, Countryid) VALUES (Tempdata.Get_String, Countryid);
                  COMMIT;
                  Dbms_Output.Put_Line('company inserted');
              END;
              --insert into T_activeJobAdsDepartments
            END LOOP;
          ELSE
            Dbms_Output.Put_Line('CompanyName should be a list');
          END IF;
        ELSE
          Dbms_Output.Put_Line('no CompanyName key found');
        END IF;
        --</ company />--   
      
        --< jobAd initial insert >--
        Dbms_Output.Put_Line('Inserting initial jobAd');
        INSERT INTO t_Jobad (Jobadid, Companyid, Countryid) VALUES (Jobadid, Companyid, Countryid);
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
            FOR Iter IN 1 .. Templist.Count
            LOOP
              Tempdata := Templist.Get(Iter);
              Dbms_Output.Put_Line('jobAd department: ' || Tempdata.Get_String);
              BEGIN
                SELECT Departmentid INTO Departmentid FROM t_Departments t WHERE TRIM(t.Departmentname) = Tempdata.Get_String;
                --insert into T_activeJobAdsDepartments
                --dbms_output.put_line('inserting: '||Jobadid||' '||Companyid||' '||Countryid||' '||Departmentid);
                INSERT INTO t_Activejobadsdepartments
                  (Jobadid, Companyid, Countryid, Departmentid)
                VALUES
                  (Jobadid, Companyid, Countryid, Departmentid);
                COMMIT;
                Dbms_Output.Put_Line('inserted into T_activeJobAdsDepartments');
              EXCEPTION
                WHEN No_Data_Found THEN
                  Dbms_Output.Put_Line('department does not exist check the master data');
              END;
            END LOOP;
          ELSE
            Dbms_Output.Put_Line('Department should be a list');
          END IF;
        ELSE
          Dbms_Output.Put_Line('no Departament key found');
        END IF;
        --</ department />--      
      
      ELSE
        Dbms_Output.Put_Line('JobAdType not 1 No proceding to flag the jobAd for a diferent type of processing');
      END IF;
    END IF;
  ELSE
    Dbms_Output.Put_Line('jobAdType json not found, malformed jobAd, flagging as with no jobAdType err=1');
  END IF;

  --Pair_Value := Jobj.Get('"Departament"');
  --dbms_output.put_line(json_ext.get_string(Pair_Value));
END;
0
0