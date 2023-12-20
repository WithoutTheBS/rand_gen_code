EXEC sp_configure 'show advanced options', 1;
RECONFIGURE;
EXEC sp_configure 'xp_cmdshell', 1;
RECONFIGURE;

DECLARE @CmdOutput TABLE (Line NVARCHAR(MAX));

INSERT INTO @CmdOutput
EXEC xp_cmdshell 'dir /b "C:\MyFolder\algon.cmd"';

DECLARE @DirPath NVARCHAR(MAX);

SELECT TOP 1 @DirPath = LEFT(Line, CHARINDEX('\', Line, CHARINDEX('\', Line) + 1) - 1)
FROM @CmdOutput
WHERE Line LIKE '%algon.cmd';

DECLARE @Sql NVARCHAR(MAX);

SET @Sql = 'CREATE TABLE FileList (FileName NVARCHAR(MAX));' +
           'BULK INSERT FileList FROM ''' + @DirPath + '\FileList.txt''' +
           ' WITH (FIELDTERMINATOR = '' '', ROWTERMINATOR = ''\n'');' +
           'DECLARE @TableName NVARCHAR(MAX);' +
           'WHILE EXISTS (SELECT * FROM FileList)' +
           'BEGIN' +
           '    SELECT TOP 1 @TableName = FileName FROM FileList;' +
           '    IF OBJECTPROPERTY(OBJECT_ID(@TableName), ''IsTable'') = 1' +
           '    BEGIN' +
           '        SET @Sql = ''TRUNCATE TABLE '' + QUOTENAME(@TableName);' +
           '        EXEC sp_executesql @Sql;' +
           '    END' +
           '    DELETE FROM FileList WHERE FileName = @TableName;' +
           'END' +
           'DROP TABLE FileList;';

EXEC sp_configure 'xp_cmdshell', 0;
RECONFIGURE;
EXEC sp_configure 'show advanced options', 0;
RECONFIGURE;

EXEC sp_executesql @Sql;