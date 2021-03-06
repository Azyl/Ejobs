CREATE OR REPLACE PACKAGE Jobad_Util IS

  -- Author  : ANDREITATARU
  -- Created : 28-03-2015 2124:3I3:28 9:03:28 PM
  -- Purpose : util functions

  -- Public type declarations

  PROCEDURE Gather_Schema_Stats;

END Jobad_Util;
/
CREATE OR REPLACE PACKAGE BODY Jobad_Util IS

  PROCEDURE Gather_Schema_Stats IS
  
    Tab        Dbms_Stats.Objecttab;
    Tabe       Dbms_Stats.Objecttab;
    Schemaname VARCHAR2(100);
  BEGIN
    SELECT Username INTO Schemaname FROM User_Users;
    Dbms_Stats.Gather_Schema_Stats(Ownname => Schemaname, Options => 'LIST STALE', Objlist => Tab);
    FOR i IN 1 .. Tab.Count
    LOOP
      Dbms_Output.Put_Line(Tab(i).Ownname || '.' || Tab(i).Objname || ' ' || Tab(i).Objtype || ' ' || Tab(i).Partname);
    END LOOP;
    Dbms_Output.Put_Line('--------- MISSING ---');
    Dbms_Stats.Gather_Schema_Stats(Ownname => Schemaname, Options => 'LIST EMPTY', Objlist => Tabe);
    FOR j IN 1 .. Tabe.Count
    LOOP
      Dbms_Output.Put_Line(Tabe(j).Ownname || '.' || Tabe(j).Objname || ' ' || Tabe(j).Objtype || ' ' || Tabe(j).Partname);
    END LOOP;
    Dbms_Output.Put_Line('Gathering stats for stale and missing tables');
    BEGIN
      Dbms_Stats.Gather_Schema_Stats(Ownname          => Schemaname,
                                     Options          => 'GATHER AUTO',
                                     Estimate_Percent => Dbms_Stats.Auto_Sample_Size,
                                     Method_Opt       => 'for all columns size auto',
                                     Degree           => Dbms_Stats.Auto_Degree);
      Dbms_Output.Put_Line('Stats gathered.');
    END;
    FOR i IN (SELECT Index_Name
                FROM User_Ind_Statistics
               WHERE Stale_Stats = 'YES'
                 AND Table_Owner = Schemaname)
    LOOP
      Dbms_Output.Put_Line('Found index with stale statistics ' || i.Index_Name);
      Dbms_Stats.Gather_Index_Stats(Ownname          => Schemaname,
                                    Indname          => i.Index_Name,
                                    Estimate_Percent => Dbms_Stats.Auto_Sample_Size);
      Dbms_Output.Put_Line('Index statistics gathered');
    END LOOP;
  
  END Gather_Schema_Stats;

END Jobad_Util;
/
