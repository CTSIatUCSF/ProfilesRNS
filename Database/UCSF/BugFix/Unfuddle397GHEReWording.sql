  select  * from [Profile.Module].[GenericRDF.Data] where [Data] like '%IGHS - Affiliate Program%' and [Name] = 'GlobalHealthEquity' --303
  --{"interests":["Nutrition & food security","Maternal health","Nutrition & food security","Newborn & infant health","Oral health"],"locations": ["Guinea-Bissau","Indonesia","Nepal","Pakistan","Uganda"],"centers": ["IGHS - Affiliate Program"]}
  --Global Health Equity Nutrition & food security, Maternal health, Nutrition & food security, Newborn & infant health, Oral health, Guinea-Bissau, Indonesia, Nepal, Pakistan, Uganda, IGHS - Affiliate Program

  update [Profile.Module].[GenericRDF.Data] set [Data] = REPLACE([Data], 'IGHS - Affiliate Program', 'Institute for Global Health Sciences') ,
			[SearchableData] = REPLACE([SearchableData], 'IGHS - Affiliate Program', 'Institute for Global Health Sciences')
			where [Data] like '%IGHS - Affiliate Program%' and [Name] = 'GlobalHealthEquity';
