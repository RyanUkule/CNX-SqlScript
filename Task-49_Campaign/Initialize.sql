USE CNX
GO
--CampaignType_lkp
	CREATE TABLE CampaignType_lkp
	(
		CampaignTypeId INT PRIMARY KEY IDENTITY(1,1),
		Name VARCHAR(200),
		IsActive BIT
	)
GO	
	CREATE TABLE CustomerType_lkp
	(
		CustomerTypeId INT PRIMARY KEY IDENTITY(0, 1),
		Name VARCHAR(200),
		[Description] varchar(max)
	)
GO
	INSERT INTO CustomerType_lkp VALUES('All', 'All customers.')
	INSERT INTO CustomerType_lkp VALUES('New', 'Only new customers.')
GO
	INSERT INTO CampaignType_lkp VALUES('Basic', 1)	 --普通活动
	INSERT INTO CampaignType_lkp VALUES('Daily', 1)	 --每日活动
	INSERT INTO CampaignType_lkp VALUES('Weekly', 1) --每周活动
	INSERT INTO CampaignType_lkp VALUES('Monthly', 1)--每月活动
GO
--Campaign
	ALTER TABLE Campaign
	ADD DependCampaignId INT NOT NULL DEFAULT 0
GO
	ALTER TABLE Campaign
	DROP CONSTRAINT FK_Campaign_CampaignTypeId_Campaign_lkp_CampaignTypeId
GO
	ALTER TABLE Campaign
	DROP CONSTRAINT DF__Campaign__Campai__394E6323
GO
	ALTER TABLE Campaign
	drop column CampaignTypeId
GO
	ALTER TABLE Campaign
	ADD CampaignTypeId INT NOT NULL DEFAULT 1 CONSTRAINT FK_Campaign_CampaignTypeId_Campaign_lkp_CampaignTypeId Foreign Key references CampaignType_lkp (CampaignTypeId)
GO
	ALTER TABLE Campaign
	Add CustomerTypeId INT NOT NULL DEFAULT 0
	
GO	
--CampaignCustomerActivity
	CREATE TABLE CampaignCustomerActivity
	(
		CampaignCustomerActivityId INT PRIMARY KEY IDENTITY(1 ,1),
		CustomerId INT NOT NULL CONSTRAINT FK_CustomerId_Customer_CustomerId REFERENCES Customer (CustomerId),
		CampaignId INT NOT NULL CONSTRAINT FK_CampaignId_Campaign_CampaignId REFERENCES Campaign (CampaignId),
		InsertDate DATETIME NOT NULL
	)
GO
--Insert Campaign
	SET IDENTITY_INSERT Campaign on
	
	insert into Campaign(CampaignId, CampaignName, StartDate, EndDate, [Description],RewardAssetTypeId, RewardAmount, Active, DependCampaignId, CampaignTypeId, CustomerTypeId) values(19, 22156, '2018-10-19', null, N'完成邮件激活', 21, 100, 1, 0, 1, 0)
	insert into Campaign(CampaignId, CampaignName, StartDate, EndDate, [Description],RewardAssetTypeId, RewardAmount, Active, DependCampaignId, CampaignTypeId, CustomerTypeId) values(20, 22157, '2018-10-19', null, N'完成L3认证', 21, 300, 1, 0, 1, 0)
	insert into Campaign(CampaignId, CampaignName, StartDate, EndDate, [Description],RewardAssetTypeId, RewardAmount, Active, DependCampaignId, CampaignTypeId, CustomerTypeId) values(21, 22158, '2018-10-19', null, N'绑定谷歌验证提高安全性', 21, 200, 1, 0, 1, 0)
	insert into Campaign(CampaignId, CampaignName, StartDate, EndDate, [Description],RewardAssetTypeId, RewardAmount, Active, DependCampaignId, CampaignTypeId, CustomerTypeId) values(22, 22159, '2018-10-19', null, N'完成第一笔交易', 11, 0.1, 1, 0, 1, 1)
	insert into Campaign(CampaignId, CampaignName, StartDate, EndDate, [Description],RewardAssetTypeId, RewardAmount, Active, DependCampaignId, CampaignTypeId, CustomerTypeId) values(23, 22160, '2018-10-19', null, N'第一次充币到C2CX', 7, 0.5, 1, 0, 1, 1)
	insert into Campaign(CampaignId, CampaignName, StartDate, EndDate, [Description],RewardAssetTypeId, RewardAmount, Active, DependCampaignId, CampaignTypeId, CustomerTypeId) values(24, 22161, '2018-10-19', null, N'完成Long平台授权', 11, 0.1, 1, 0, 1, 0)
	insert into Campaign(CampaignId, CampaignName, StartDate, EndDate, [Description],RewardAssetTypeId, RewardAmount, Active, DependCampaignId, CampaignTypeId, CustomerTypeId) values(25, 22162, '2018-10-19', null, N'完成第一次邀请,并且被邀请者成功完成L3认证', 7, 1, 1, 0, 1, 0)
	insert into Campaign(CampaignId, CampaignName, StartDate, EndDate, [Description],RewardAssetTypeId, RewardAmount, Active, DependCampaignId, CampaignTypeId, CustomerTypeId) values(26, 22163, '2018-10-19', null, N'兑换一次SYN1', 11, 1, 1, 0, 1, 0)

	SET IDENTITY_INSERT Campaign off
GO
	update Campaign set Active = 0 where CampaignId < 19