-- Truncate tables based on filenames
DECLARE @TableName NVARCHAR(MAX);
DECLARE @Sql NVARCHAR(MAX);

DECLARE cur CURSOR FOR
SELECT FileName FROM FileList;

OPEN cur;
FETCH NEXT FROM cur INTO @TableName;

WHILE @@FETCH_STATUS = 0
BEGIN
    IF OBJECTPROPERTY(OBJECT_ID(@TableName), 'IsTable') = 1
    BEGIN
        SET @Sql = 'TRUNCATE TABLE ' + QUOTENAME(@TableName);
        EXEC sp_executesql @Sql;
    END
    FETCH NEXT FROM cur INTO @TableName;
END

CLOSE cur;
DEALLOCATE cur;