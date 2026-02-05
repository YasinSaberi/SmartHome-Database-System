USE SmartHomeDB;
GO

-- =============================================
-- SECTION A: VIEWS (3 Items)
-- =============================================

-- 1. View_FullDeviceDetails
CREATE VIEW View_FullDeviceDetails AS
SELECT 
    d.DeviceID,
    d.DeviceName,
    dt.TypeName,
    r.RoomName,
    r.FloorNumber,
    d.CurrentStatus,
    d.IsActive
FROM Devices d
INNER JOIN Rooms r ON d.RoomID = r.RoomID
INNER JOIN DeviceTypes dt ON d.TypeID = dt.TypeID;
GO

-- 2. View_CriticalSensors
CREATE VIEW View_CriticalSensors AS
SELECT 
    sr.ReadingID,
    d.DeviceName,
    r.RoomName,
    sr.ReadingValue,
    sr.Unit,
    sr.RecordedAt
FROM SensorReadings sr
INNER JOIN Devices d ON sr.DeviceID = d.DeviceID
INNER JOIN Rooms r ON d.RoomID = r.RoomID
WHERE 
    (sr.Unit = 'Celsius' AND sr.ReadingValue > 28.0) OR 
    (sr.Unit = 'Boolean' AND sr.ReadingValue = 1.0);   
GO

-- 3. View_RoomSummary
CREATE VIEW View_RoomSummary AS
SELECT 
    r.RoomName,
    COUNT(d.DeviceID) AS TotalDevices,
    SUM(CASE WHEN d.CurrentStatus != 'OFF' THEN 1 ELSE 0 END) AS ActiveDevices
FROM Rooms r
LEFT JOIN Devices d ON r.RoomID = d.RoomID
GROUP BY r.RoomName;
GO

-- =============================================
-- SECTION B: FUNCTIONS (3 Items)
-- =============================================

-- 1. Fn_GetRoomAverageTemp (Scalar Function)
CREATE FUNCTION Fn_GetRoomAverageTemp (@RoomID INT)
RETURNS FLOAT
AS
BEGIN
    DECLARE @AvgTemp FLOAT;
    
    SELECT @AvgTemp = AVG(sr.ReadingValue)
    FROM SensorReadings sr
    INNER JOIN Devices d ON sr.DeviceID = d.DeviceID
    WHERE d.RoomID = @RoomID AND sr.Unit = 'Celsius';

    RETURN ISNULL(@AvgTemp, 0);
END;
GO

-- 2. Fn_GetDevicesByType (Table-Valued Function)
CREATE FUNCTION Fn_GetDevicesByType (@TypeName VARCHAR(50))
RETURNS TABLE
AS
RETURN (
    SELECT d.DeviceID, d.DeviceName, r.RoomName, d.CurrentStatus
    FROM Devices d
    INNER JOIN DeviceTypes dt ON d.TypeID = dt.TypeID
    INNER JOIN Rooms r ON d.RoomID = r.RoomID
    WHERE dt.TypeName = @TypeName
);
GO

-- 3. Fn_IsDeviceActive (Scalar Function - Boolean Logic)
CREATE FUNCTION Fn_IsDeviceActive (@DeviceID INT)
RETURNS BIT
AS
BEGIN
    DECLARE @Status VARCHAR(50);
    DECLARE @IsActive BIT;

    SELECT @Status = CurrentStatus FROM Devices WHERE DeviceID = @DeviceID;

    IF @Status IN ('OFF', '0', 'NO_MOTION', 'LOCKED')
        SET @IsActive = 0;
    ELSE
        SET @IsActive = 1;

    RETURN @IsActive;
END;
GO