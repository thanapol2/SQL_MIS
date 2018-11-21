BEGIN
  FOR r IN
  (SELECT month_year,
    region_no,
    off_id,
    SUM(cert_cnt) cert_all
  FROM temp_r2
  WHERE cert_cnt_status ='N'
  GROUP BY month_year,
    region_no,
    off_id
  )
  LOOP
    UPDATE temp_r2 t
    SET cert_pert         = cert_cnt * 100 / r.cert_all
    WHERE t.month_year    = r.month_year
    AND t.region_no         = r.region_no
    AND t.off_id          = r.off_id
    AND t.cert_cnt_status ='N';
  END LOOP;
END;