USE [cnx]
GO
/****** Object:  StoredProcedure [dbo].[usp_GetBitcoinAddress]    Script Date: 2018/06/07 15:29:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
ALTER PROCEDURE [dbo].[usp_GetBitcoinAddress]
@customerId int = null,
@assetTypeId int = null,
@name nvarchar(40) = null,
@addressId nvarchar(max) = null,
@tag nvarchar(30) = null
AS
BEGIN
	if(@addressId is null)
	begin
		select 
			BitcoinAddressId, AddressId, Name, InsertDate, IsDefault, Tag
		from BitcoinAddress with (nolock)
		where IsActive = 1 and IsDeposit = 0 
		and (CustomerId = @customerId or @customerId is null)
		and (AssetTypeId = @assetTypeId or @assetTypeId is null)
		and (Name = case when @name is null then Name else @name end)
		and (Tag = @tag or @tag is null)
	end
	else
	begin
		select 
			BitcoinAddressId, AddressId, Name, InsertDate, IsDefault, Tag
		from BitcoinAddress with (nolock)
		where IsActive = 1 and IsDeposit = 0 
		and (AddressId = @addressId or @addressId is null)
		and (CustomerId = @customerId or @customerId is null)
		and (Tag = @tag or @tag is null)
	end
END




