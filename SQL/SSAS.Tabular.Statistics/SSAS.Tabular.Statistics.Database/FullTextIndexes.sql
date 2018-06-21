GO

EXEC sp_fulltext_database @action = 'enable'

GO

CREATE FULLTEXT INDEX ON [dbo].[Queries]
    ([QueryText] LANGUAGE 1033)
    KEY INDEX [PK__Queries__5967F7DBA0877554]
    ON [QueryTextCat2];







