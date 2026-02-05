USE SmartHomeDB;
GO

-- =============================================
-- 1. CTE (Common Table Expression)
-- =============================================
WITH RoomActivityCounts AS (
    SELECT 
        r.RoomName,
        COUNT(sr.ReadingID) AS TotalReadings
    FROM Rooms r
    JOIN Devices d ON r.RoomID = d.RoomID
    JOIN SensorReadings sr ON d.DeviceID = sr.DeviceID
    GROUP BY r.RoomName
)
SELECT * FROM RoomActivityCounts
WHERE TotalReadings > 0
ORDER BY TotalReadings DESC;
GO

-- =============================================
-- 2. Window Function (ROW_NUMBER)
-- =============================================
SELECT DeviceName, ReadingValue, Unit, RecordedAt
FROM (
    SELECT 
        d.DeviceName, 
        sr.ReadingValue, 
        sr.Unit, 
        sr.RecordedAt,
        ROW_NUMBER() OVER (PARTITION BY d.DeviceID ORDER BY sr.RecordedAt DESC) AS RowNum
    FROM Devices d
    JOIN SensorReadings sr ON d.DeviceID = sr.DeviceID
) AS RankedReadings
WHERE RowNum = 1;
GO

-- =============================================
-- 3.Subquery, EXISTS
-- =============================================
SELECT DeviceName, RoomName
FROM Devices d
JOIN Rooms r ON d.RoomID = r.RoomID
WHERE NOT EXISTS (
    SELECT 1 
    FROM SensorReadings sr 
    WHERE sr.DeviceID = d.DeviceID
);
GO

-- =============================================
-- 4. Group By, HAVING
-- =============================================
SELECT 
    d.DeviceName, 
    AVG(sr.ReadingValue) AS AvgTemp,
    MAX(sr.ReadingValue) AS MaxTemp
FROM SensorReadings sr
JOIN Devices d ON sr.DeviceID = d.DeviceID
WHERE sr.Unit = 'Celsius'
GROUP BY d.DeviceName
HAVING AVG(sr.ReadingValue) > 25.0;
GO