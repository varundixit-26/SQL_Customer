-- Oracle customer with no transaction query
SELECT hp.party_name as "Organization Name"
 ,HP.PARTY_NUMBER as "Registry ID"
,NVL2(hl.address1,hl.address1||', ','')||NVL2(hl.address2,hl.address2||', ','')||NVL2(hl.address3,hl.address3||', ','')||NVL2(hl.address4,hl.address4||', ','')||NVL2(hl.city,hl.city||', ','')||NVL2(hl.state,hl.state||', ','')||hl.country Address  
       ,hca.account_number as "Account Number"
			 ,HCA.ACCOUNT_NAME as "Account Name"
       ,hps.party_site_number as "Site Number"
       ,hps.PARTY_SITE_NAME as "Site Name"
FROM   hz_cust_accounts hca
       ,hz_cust_acct_sites_all hcasa
       ,hz_cust_site_uses_all hcsua
       ,hz_party_sites hps
       ,hz_locations hl
       ,hz_parties hp
	   ,FND_SETID_SETS_VL fss
WHERE  hca.cust_account_id = hcasa.cust_account_id
       AND hca.party_id = hp.party_id
       AND hcasa.cust_acct_site_id = hcsua.cust_acct_site_id
       AND Nvl(hca.status, 'A') = 'A'
       AND Nvl(hcsua.status, 'A') = 'A'
       AND hcasa.party_site_id = hps.party_site_id
       AND hps.location_id = hl.location_id 
AND site_use_code = 'BILL_TO'
AND hps.creation_date > :P_CUTOFF_DATE
	   --AND hca.cust_account_id = ps.customer_id
	   --AND ps.customer_site_use_id =hcsua.site_use_id
	   AND hcasa.set_id = fss.set_id
       AND fss.set_code = NVL(:P_ACCADD_SET,fss.set_code)
       AND NOT EXISTS (
		SELECT 1
		FROM ar_payment_schedules_all aps
		WHERE 1 = 1
			AND aps.customer_id = hca.cust_account_id 
			AND aps.creation_date <= :P_CUTOFF_DATE
		)
		AND
NOT EXISTS (
   SELECT 1
   FROM
     ar_cash_receipts_all arca
   WHERE
     arca.PAY_FROM_CUSTOMER = hp.party_id
     AND arca.creation_date <= :P_CUTOFF_DATE
)
