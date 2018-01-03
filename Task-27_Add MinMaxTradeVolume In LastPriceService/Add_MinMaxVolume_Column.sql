use CNX
GO
ALTER TABLE ExchangeSetting
ADD MinOnTradeVolume int not null default 20,
    MaxOnTradeVolume int not null default 30
