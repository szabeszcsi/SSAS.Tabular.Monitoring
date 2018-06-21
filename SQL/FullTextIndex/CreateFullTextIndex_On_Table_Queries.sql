CREATE FULLTEXT CATALOG QueryTextCat;  
GO

CREATE FULLTEXT INDEX ON  [dbo].[Queries]
(  
        [QueryText]                     --Full-text index column name   
        Language 1033                 --1033 is the LCID for English  
)  
KEY INDEX [PK__Queries__5967F7DBA0877554] ON QueryTextCat --Unique index  -- UPDATE PK NAME WITH REAL!
WITH CHANGE_TRACKING AUTO            --Population type;  
GO  

--ALTER FULLTEXT INDEX ON   [dbo].[Queries] START UPDATE POPULATION