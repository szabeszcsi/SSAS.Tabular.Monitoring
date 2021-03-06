  UPDATE Q
  SET DatabaseId = D.DatabaseId
  FROM [dbo].[Queries] Q   
  INNER JOIN [dbo].[SSAS_Monitoring] M
	ON CONVERT(VARCHAR(40),HASHBYTES('MD5',M.[QueryText]),2) = Q.QueryHash
  INNER JOIN [dbo].[Databases] D
	ON M.DatabaseName = D.DatabaseName