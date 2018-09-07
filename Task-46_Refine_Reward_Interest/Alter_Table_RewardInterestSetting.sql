
USE CNX
GO
ALTER TABLE RewardInterestSetting
ALTER COLUMN Rate decimal(38,18)
GO
ALTER TABLE RewardInterestSetting
ADD RewardAssetTypeId int NOT NULL DEFAULT 15