SELECT COUNT(*),parsed FROM t_scrappedads GROUP BY parsed;
SELECT COUNT(*) FROM t_jobad;
SELECT COUNT(*) FROM t_jobad WHERE jobtitle IS NULL;
SELECT * FROM t_errorjobad;
--SELECT scrapeid,SUBSTR(parselog,1,4000),SUBSTR(parselog,4001,4000) FROM t_scrappedads WHERE scrapeid=7919;
