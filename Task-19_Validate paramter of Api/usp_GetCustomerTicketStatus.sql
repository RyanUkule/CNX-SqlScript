/***************************************
AUTHOR: Ryan.Han
Create Date: 2017-10-23
***************************************/
CREATE PROCEDURE usp_GetCustomerTicketStatus
AS
BEGIN
	SELECT [CustomerTicketStatusId]
      ,[Name]
      ,[IsActive]
  FROM [cnx].[dbo].[CustomerTickerStatus_lkp]
END

