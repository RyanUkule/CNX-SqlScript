USE [cnx]
GO
/****** Object:  StoredProcedure [dbo].[usp_CreateBitcoinAddress]    Script Date: 2018/05/22 16:57:19 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
ALTER PROCEDURE [dbo].[usp_CreateBitcoinAddress]
@CustomerId INT,
@AddressId VARCHAR(MAX),
@Tag NVARCHAR(80),
@AssetTypeId INT,
@Name NVARCHAR(40),
@isDeposit BIT,
@isDefault BIT,
@isActive BIT
AS
BEGIN
	DECLARE @CustomerId_tmp INT
	DECLARE @BitcoinAddressId INT
	SELECT @CustomerId_tmp = CustomerId FROM BitcoinAddress WHERE CustomerId = @CustomerId and AddressId = @AddressId and Tag = @Tag and IsDeposit = 0 AND AssetTypeId=@AssetTypeId
	IF(@CustomerId_tmp IS NOT NULL)
	BEGIN
		UPDATE BitcoinAddress SET isActive = 1,Name=@Name, isDefault = @isDefault 
		WHERE CustomerId = @CustomerId and AddressId = @AddressId AND AssetTypeId=@AssetTypeId --and IsDeposit = 0	

		select @BitcoinAddressId = BitcoinAddressId from BitcoinAddress 
		where CustomerId = @CustomerId and AddressId = @AddressId AND AssetTypeId=@AssetTypeId --and IsDeposit = 0
	END
	ELSE
	BEGIN
		INSERT INTO BitcoinAddress(CustomerId, AddressId, AssetTypeId, Name, isDeposit, isDefault, isActive, UpdateDate, InsertDate, SaveDate, Tag)
		VALUES(@CustomerId, @AddressId, @AssetTypeId, @Name, @isDeposit, @isDefault, @isActive, GETDATE(), GETDATE(), GETDATE(), @Tag);
		
		SELECT @BitcoinAddressId = SCOPE_IDENTITY()		
	END

	IF(@isDefault = 1)
	BEGIN
		UPDATE BitcoinAddress SET isDefault = 0 WHERE CustomerId = @CustomerId and BitcoinAddressId <> @BitcoinAddressId and isDefault = 1 AND AssetTypeId=@AssetTypeId
	END
	SELECT * FROM BitcoinAddress WHERE BitcoinAddressId = @BitcoinAddressId AND AssetTypeId=@AssetTypeId
END










