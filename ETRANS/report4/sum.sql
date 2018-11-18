BEGIN
  FOR r IN
  (SELECT month_year,
    region_no,
    SUM(IMP_DOC_CUR_YEAR_CNT) sum_doc,
    SUM(IMP_DOC_PRIOR_YEAR_CNT) sum_pdoc
  FROM temp_select
  GROUP BY month_year,
    region_no
  )
  LOOP
    UPDATE temp_select t
    SET IMP_DOC_CUR_YEAR_PERT = IMP_DOC_CUR_YEAR_CNT   *100/r.sum_doc,
      IMP_DOC_PRIOR_YEAR_PERT = IMP_DOC_PRIOR_YEAR_PERT*100/r.sum_doc
    WHERE t.month_year        = r.month_year
    AND t.region_no           = r.region_no;
  END LOOP;
END;