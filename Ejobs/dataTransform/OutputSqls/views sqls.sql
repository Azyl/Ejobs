/*SELECT COUNT(*) AS Lastweeknewads
  FROM t_Jobad
 WHERE Jobadstartdate >= Next_Day(Trunc(SYSDATE) - INTERVAL '14' DAY, 'SUN')
   AND Jobadstartdate < Next_Day(Trunc(SYSDATE) - INTERVAL '7' DAY, 'SUN')
   AND Jobadenddate >= SYSDATE;

SELECT COUNT(*) AS Avaialabejobadsindb FROM t_Jobad;

SELECT To_Char(Jobadstartdate, 'iw'), To_Char(Jobadstartdate, 'YYYY'), COUNT(*)
  FROM t_Jobad
 GROUP BY To_Char(Jobadstartdate, 'iw'), To_Char(Jobadstartdate, 'YYYY')
 ORDER BY To_Char(Jobadstartdate, 'iw'), To_Char(Jobadstartdate, 'YYYY') DESC;*/
/*SELECT JobAdNr, Companyname
  FROM (SELECT COUNT(*) AS JobAdNr, c.Companyname,j.jobtitle
          FROM t_Jobad j, t_Company c
         WHERE j.Companyid = c.Companyid
        
        -- AND Lower(c.Companyname) LIKE '%arvato%'
        --     AND ROWNUM<11
        
         GROUP BY c.Companyname
         ORDER BY COUNT(*) DESC)
 WHERE Rownum < 11;
*/
--jobadstardate INTO jobadstartdate
--jodtitle INTO jobtitle

-- top 
SELECT DISTINCT c.Companyname, COUNT(*) Over(PARTITION BY c.Companyname) AS Jobadnr
  FROM t_Jobad j, t_Company c
 WHERE j.Companyid = c.Companyid

-- AND Lower(c.Companyname) LIKE '%arvato%'
--     AND ROWNUM<11

 ORDER BY Jobadnr DESC;

SELECT DISTINCT c.Companyname, j.Jobtitle, COUNT(*) Over(PARTITION BY c.Companyname, j.Jobtitle) AS Jobadnr
  FROM t_Jobad j, t_Company c
 WHERE j.Companyid = c.Companyid
   AND j.Jobtitle IS NOT NULL

-- AND Lower(c.Companyname) LIKE '%arvato%'
--     AND ROWNUM<11

 ORDER BY Jobadnr DESC;
--l_hash := dbms_crypto.hash( l_src, dbms_crypto.HASH_MD5 );

SELECT COUNT(*) FROM t_jobad WHERE jobtitle IS NULL;
