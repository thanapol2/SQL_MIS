BEGIN
  FOR r IN
  (SELECT off_id,
    region_no,
    caldr_year,
    month_id,
    CERT_CNT_STATUS,
    nullif(SUM(cert_cnt),0) cert_all
  FROM REPT_MANAGE_CERT_STATUS
  WHERE caldr_year = TO_CHAR(SYSDATE, 'yyyy') + 543
  and month_id != 13
  GROUP BY off_id,
    region_no,
    caldr_year,
    month_id,
    CERT_CNT_STATUS
  )
  LOOP
    UPDATE rept_manage_cert_status t
    SET cert_pert         = ROUND(NVL(cert_cnt * 100 / r.cert_all, 0), 2)
    WHERE t.caldr_year    = r.caldr_year
    AND t.month_id        = r.month_id
    AND t.region_no       = r.region_no
    AND t.off_id          = r.off_id
    AND t.CERT_CNT_STATUS = r.CERT_CNT_STATUS;
  END LOOP;
END;