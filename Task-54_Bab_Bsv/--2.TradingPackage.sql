use CNX
GO
--TradingPackage
--1.USDT_PAX
insert into tradingpackages(
	AssetTypeId,
	BtcTransferConfirmations,
	DepositCommission,
	DepositCommissionChargeLimit,
	IsActive,
	MarginInterest,
	MarginRatio,
	MinWithdrawalCommission,
	Name,
	PackageUID,
	StopLossCommision,
	StopLossWarning,
	Symbol,
	TakeProfitCommission,
	TakeProfitReminder,
	TextResourceId,
	TradingMakerCommission,
	TradingTakerCommission,
	TriggerCommission,
	TriggerOrder,
	WithdrawalCommission
)
select 
	39,
	BtcTransferConfirmations,
	0,
	DepositCommissionChargeLimit,
	IsActive,
	MarginInterest,
	MarginRatio,
	0,
	Name,
	PackageUID,
	0,
	StopLossWarning,
	'USDT_PAX',
	0,
	TakeProfitReminder,
	TextResourceId,
	0,
	0.001,
	0,
	TriggerOrder,
	0
from tradingpackages where symbol = 'USDT_SKY'

