USE [cnx]
GO
/****** Object:  StoredProcedure [dbo].[usp_GetBankTransactionInfo]    Script Date: 2018/06/01 17:00:25 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
ALTER PROCEDURE [dbo].[usp_GetBankTransactionInfo]
AS
BEGIN
	select [BankTransactionTypeId],[Name]
	from [cnx].[dbo].[BankTransactionType_lkp] with (nolock)
	where IsActive = 1

	select  b.BankAccountInfoId, b.BankName, b.BankAccountNumber
	from BankAccountInfo b with (nolock) 
	inner join webpages_UsersInRoles u with (nolock) on b.CreateBy = u.UserId
	--inner join webpages_Roles r with (nolock) on u.RoleId = r.RoleId
	where u.UserId = 2
	and IsActive = 1

	--select 'Customer Deposit' union all
	--select 'Customer Withdrawal' union all
	--select 'Business Deposit' union all
	--select 'Business Withdrawal' union all
	--select 'Bank fee' union all
	--select 'Bank interest' 

	select [CustomerTicketStatusId],[Name]
	from [cnx].[dbo].[CustomerTickerStatus_lkp] with (nolock)
	where IsActive = 1
END




