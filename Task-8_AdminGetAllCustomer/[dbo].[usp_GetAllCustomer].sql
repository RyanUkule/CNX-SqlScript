USE [cnx]
GO
/****** Object:  StoredProcedure [dbo].[usp_GetAllCustomer]    Script Date: 2017/06/16 17:24:36 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
ALTER PROCEDURE [dbo].[usp_GetAllCustomer]
	@BTCMarkPrice DECIMAL(18,8) = 0,
	@ETHMarkPrice DECIMAL(18,8) = 0,
	@skipcount INT  = 0, 
	@rowcount INT = 20,
	@totalCount INT = NULL,
	@customerid INT = NULL,
	@email NVARCHAR(150) = NULL,
	@username NVARCHAR(100) = NULL,
	@mobile VARCHAR(20) = NULL,
	@status INT = NULL,
	@languageCode VARCHAR(50) = NULL,
	@packageId NVARCHAR(200) = NULL,
	@joinDateStart DATETIME = '2015-02-12',
	@joinDateEnd DATETIME = '2015-02-15',
	@lastActiveStart DATETIME = NULL,
	@lastActiveEnd DATETIME = NULL,
	@complex NVARCHAR(150) = NULL,
	@isAccountApprove INT= -1
AS
BEGIN    
	IF(@isAccountApprove IS NULL)
	BEGIN
		SET @isAccountApprove=-1
	END
    SELECT TOP (@rowcount) * FROM (
		SELECT 
		COUNT(*)OVER() AS totalnum,	
		ROW_NUMBER() OVER(  ORDER BY  InsertDate ASC) AS num,
		C.CustomerId,
		vd.RealName Name,
		C.UserName,
		C.Email,
		CP.Value as CountryCode,
		C.Mobile,
		C.TradingPackageId,
		t.Name AS PackageName,
		C.LanguageCode,
		C.AccountIsFrozen,
		w.IsConfirmed,
		C.UpdateDate,
		C.InsertDate AS JoinDateStart,
		C.SaveDate ,
		C.ChatUpdateTime,
		P.LastActiveEnd,
        C.IsHighRisk,
		C.IsTestAccount,
		ab.Assets
		FROM Customer C WITH (NOLOCK)
		LEFT JOIN
		(SELECT CustomerId,MAX(Pf.InsertDate) AS LastActiveEnd 
		FROM  PersonalInformationHistory pf 
		WHERE pf.UpdatedFiels = 'Login' 
			AND (pf.CustomerId = @CustomerId OR @CustomerId IS NULL OR @CustomerId = '' )
			AND (pf.InsertDate >= @lastActiveStart OR @lastActiveStart IS NULL OR @lastActiveStart ='')
			AND (pf.InsertDate >= @lastActiveEnd OR @lastActiveEnd IS NULL OR @lastActiveEnd ='')
		GROUP BY pf.CustomerId
		) P on C.CustomerId = P.CustomerId 
		LEFT JOIN (SELECT [PackageUID],[Name] FROM [TradingPackages]  GROUP BY [PackageUID],[Name]) t ON C.TradingPackageId= t.PackageUID 
		LEFT JOIN [webpages_Membership] w ON c.CustomerId=w.UserId
		LEFT JOIN (SELECT [CustomerId],SUM(([Balance]-[FrozenBalance])*(CASE [AssetTypeId] WHEN 2 THEN @BTCMarkPrice WHEN 5 THEN @ETHMarkPrice ELSE 1 END  )) AS Assets
				   FROM [AssetBalance] 
				   WHERE CustomerId = @CustomerId OR @CustomerId IS NULL  OR @CustomerId =''						 
				   GROUP BY [CustomerId]
				   ) ab ON c.CustomerId=ab.CustomerId 
		LEFT JOIN VerificationDocument vd ON c.CustomerId = vd.CustomerId
		left join (SELECT [CustomerId],[value] FROM [CustomerPreference] where Preferenceid = 39 ) cp on cp.CustomerId = C.CustomerId
		WHERE 
		(CAST(c.CustomerId as nvarchar(20)) = @complex OR C.UserName = @complex OR C.Email = @complex OR C.Mobile = @complex OR @complex IS NULL OR @complex = '')
		AND (C.CustomerId = @CustomerId or @CustomerId is null  or @CustomerId ='')		
		AND (C.IsAccountApproved = @isAccountApprove OR @isAccountApprove=-1 OR (@isAccountApprove=2 AND C.IsAccountApproved IS NULL) )
		AND (C.Email = @email or @email IS NULL OR @email = '')
		AND (C.UserName = @username OR vd.RealName = @username  or @username is null or @username = '')
		AND (C.Mobile = @mobile or @mobile is null or @mobile = '')
		AND (C.AccountIsFrozen = CASE @status WHEN 2 THEN 0 ELSE @status END OR @status IS NULL OR @status ='')
		AND (w.IsConfirmed=CASE @status WHEN 2 THEN 0 ELSE 1 END  OR @status IS NULL OR @status ='')
		AND (C.LanguageCode = @languageCode OR @languageCode IS NULL OR @languageCode = '')
		--AND (C.TradingPackageId = @packageId  or @packageId is null)
		AND (CAST(C.TradingPackageId as nvarchar(200))=@packageId OR @packageId IS NULL OR @packageId='')
		AND (C.InsertDate >= @joinDateStart OR @joinDateStart IS NULL OR @joinDateStart ='')
		AND (C.InsertDate <= @joinDateEnd OR @joinDateEnd IS NULL OR @joinDateEnd ='')
	) a
	WHERE a.num> @skipcount
	--and (P.InsertDate >= @lastActiveStart or @lastActiveStart is null or @lastActiveStart ='')
	--and (P.InsertDate >= @lastActiveEnd or @lastActiveEnd is null or @lastActiveEnd ='')
	--group by C.CustomerId,C.Name,C.UserName,C.Email,C.Mobile,C.TradingPackageId,C.LanguageCode,C.AccountIsFrozen,
	--C.UpdateDate,C.InsertDate,C.SaveDate,C.ChatUpdateTime,t.Name,w.IsConfirmed
	
END


