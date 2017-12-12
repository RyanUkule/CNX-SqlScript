USE cnx
GO
INSERT INTO Configuration
SELECT 'ICOMaintenance', value, Description, SortOrder, GETDATE(),GETDATE(),GETDATE() 
FROM Configuration 
WHERE Name = 'maintenance' 
	AND NOT EXISTS (SELECT NAME FROM Configuration WHERE NAME = 'ICOMaintenance')