USE [cnx]
GO
/****** Object:  StoredProcedure [dbo].[usp_UpdateBankAccountInfo]    Script Date: 2017/10/20 11:33:42 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
ALTER PROCEDURE [dbo].[usp_UpdateBankAccountInfo]
@CustomerId int,
@BankAccountInfoId int,
@IsDefault bit,
@IsActive bit
AS
BEGIN
	Update BankAccountInfo set IsDefault = @IsDefault, IsActive = @IsActive where 
	CreateBy = @CustomerId and BankAccountInfoId = @BankAccountInfoId

	if(@IsDefault = 1)
	begin
		Update BankAccountInfo set IsDefault = 0 
		where CreateBy = @CustomerId and BankAccountInfoId <> @BankAccountInfoId
	end
	
	select count(*) from BankAccountInfo 
	where CreateBy = @CustomerId and BankAccountInfoId = @BankAccountInfoId
END

