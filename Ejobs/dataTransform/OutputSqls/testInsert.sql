DECLARE
  SCRAPY_ITEM VARCHAR2(32767);
  SCRAPEID_T NUMBER;
  v_Return NUMBER;
BEGIN

--SCRAPY_ITEM := NULL;
  SCRAPEID_T := 2026;

select Jobadjson into scrapy_item FROM t_Scrappedads WHERE   Scrapeid=SCRAPEID_T;

  

  v_Return := JOBAD_LOAD.INSERTJOBAD(
    SCRAPY_ITEM => SCRAPY_ITEM,
    SCRAPEID_T => SCRAPEID_T
  );
  /* Legacy output: 
DBMS_OUTPUT.PUT_LINE('v_Return = ' || v_Return);
*/ 
  :v_Return := v_Return;
--rollback; 
END;
