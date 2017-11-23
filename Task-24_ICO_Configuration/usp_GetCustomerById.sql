USE [cnx]
GO
/****** Object:  StoredProcedure [dbo].[usp_GetCustomerById]    Script Date: 2017/11/23 16:39:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
ALTER PROCEDURE [dbo].[usp_GetCustomerById]
@customerid int
AS
BEGIN
	SELECT 
	CustomerId,
	Name,
	UpdateDate,
	InsertDate,
	SaveDate,
	UserName,
	Email,
	Mobile,
	AllowMarginTrades,
	MaximumMarginRatio,
	TradingPackageId,
	LanguageCode,
	AccountIsFrozen,
	ChatUpdateTime,
	IsAccountApproved,
	IsAdvanceApprove
	from Customer with (nolock)
	where CustomerId = @customerid
END








