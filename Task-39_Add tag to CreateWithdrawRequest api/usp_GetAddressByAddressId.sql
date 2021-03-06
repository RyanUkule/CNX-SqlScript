USE [cnx]
GO
/****** Object:  StoredProcedure [dbo].[usp_GetAddressByAddressId]    Script Date: 2018/06/01 14:04:48 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		Steven
-- Create date: 2018-1-19
-- Description: 根据adressid查询充值地址
-- =============================================
ALTER PROCEDURE [dbo].[usp_GetAddressByAddressId]
@addressId nvarchar(200),
@isDeposit bit = null
AS
BEGIN
  select [BitcoinAddressId]
      ,[CustomerId]
      ,[AddressId]
      ,[Name]
      ,[UpdateDate]
      ,[InsertDate]
      ,[SaveDate]
      ,[AssetTypeId]
      ,[IsDeposit]
      ,[IsDefault]
      ,[IsActive]
	  ,[Tag]
  from BitcoinAddress with(nolock)
  where AddressId = @addressId
	and (IsDeposit = @isDeposit or @isDeposit is null)
END

