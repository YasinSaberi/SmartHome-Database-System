USE SmartHomeDB;
GO

ALTER TABLE Devices
ADD DeviceCode AS (UPPER(SUBSTRING(DeviceName, 1, 3)) + '-' + CAST(RoomID AS VARCHAR) + '-' + CAST(DeviceID AS VARCHAR));
GO

CREATE NONCLUSTERED INDEX IX_SensorReadings_DeviceID
ON SensorReadings(DeviceID);
GO

CREATE NONCLUSTERED INDEX IX_Devices_RoomID
ON Devices(RoomID);
GO

DECLARE @i INT = 1;
DECLARE @RandDeviceID INT;
DECLARE @RandValue FLOAT;
DECLARE @RandTemp FLOAT;

WHILE @i <= 100
BEGIN
    SET @RandDeviceID = FLOOR(RAND() * 5) + 1; 
    
    SET @RandTemp = CAST(18 + (RAND() * 15) AS DECIMAL(4,1)); 

    IF @RandDeviceID = 2 
    BEGIN
        INSERT INTO SensorReadings (DeviceID, ReadingValue, Unit, RecordedAt)
        VALUES (@RandDeviceID, @RandTemp, 'Celsius', DATEADD(MINUTE, -@i, GETDATE()));
    END
    ELSE IF @RandDeviceID = 4 
    BEGIN
        INSERT INTO SensorReadings (DeviceID, ReadingValue, Unit, RecordedAt)
        VALUES (@RandDeviceID, FLOOR(RAND() * 2), 'Boolean', DATEADD(MINUTE, -@i, GETDATE()));
    END
    ELSE
    BEGIN
         INSERT INTO SensorReadings (DeviceID, ReadingValue, Unit, RecordedAt)
         VALUES (@RandDeviceID, 0, 'Generic', DATEADD(MINUTE, -@i, GETDATE()));
    END

    SET @i = @i + 1;
END;
GO