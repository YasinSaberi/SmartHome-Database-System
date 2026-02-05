CREATE DATABASE SmartHomeDB;
GO

USE SmartHomeDB;
GO

CREATE TABLE Users (
    UserID INT PRIMARY KEY IDENTITY(1,1),
    Username VARCHAR(50) NOT NULL UNIQUE,
    PasswordHash VARCHAR(256) NOT NULL,
    FullName VARCHAR(100) NOT NULL,
    Role VARCHAR(20) NOT NULL CHECK (Role IN ('Admin', 'Member')),
    CreatedAt DATETIME DEFAULT GETDATE()
);
GO

CREATE TABLE Rooms (
    RoomID INT PRIMARY KEY IDENTITY(1,1),
    RoomName VARCHAR(50) NOT NULL,
    FloorNumber INT NOT NULL DEFAULT 1
);
GO

CREATE TABLE DeviceTypes (
    TypeID INT PRIMARY KEY IDENTITY(1,1),
    TypeName VARCHAR(50) NOT NULL UNIQUE,
    Description VARCHAR(200) NULL
);
GO

USE SmartHomeDB;
GO

CREATE TABLE Devices (
    DeviceID INT PRIMARY KEY IDENTITY(1,1),
    DeviceName VARCHAR(100) NOT NULL,
    TypeID INT NOT NULL,
    RoomID INT NOT NULL,
    CurrentStatus VARCHAR(50) DEFAULT 'OFF',
    IsActive BIT DEFAULT 1,
    FOREIGN KEY (TypeID) REFERENCES DeviceTypes(TypeID),
    FOREIGN KEY (RoomID) REFERENCES Rooms(RoomID)
);
GO

CREATE TABLE SensorReadings (
    ReadingID BIGINT PRIMARY KEY IDENTITY(1,1),
    DeviceID INT NOT NULL,
    ReadingValue FLOAT NOT NULL,
    Unit VARCHAR(20) NOT NULL,
    RecordedAt DATETIME DEFAULT GETDATE(),
    FOREIGN KEY (DeviceID) REFERENCES Devices(DeviceID)
);
GO

CREATE TABLE Scenes (
    SceneID INT PRIMARY KEY IDENTITY(1,1),
    SceneName VARCHAR(50) NOT NULL,
    CreatedBy INT NOT NULL,
    CreatedAt DATETIME DEFAULT GETDATE(),
    FOREIGN KEY (CreatedBy) REFERENCES Users(UserID)
);
GO

CREATE TABLE SceneActions (
    ActionID INT PRIMARY KEY IDENTITY(1,1),
    SceneID INT NOT NULL,
    DeviceID INT NOT NULL,
    TargetStatus VARCHAR(50) NULL,
    TargetValue FLOAT NULL,
    FOREIGN KEY (SceneID) REFERENCES Scenes(SceneID),
    FOREIGN KEY (DeviceID) REFERENCES Devices(DeviceID)
);
GO

CREATE TABLE AutomationRules (
    RuleID INT PRIMARY KEY IDENTITY(1,1),
    RuleName VARCHAR(100) NOT NULL,
    TriggerDeviceID INT NOT NULL,
    ConditionOperator VARCHAR(5) NOT NULL,
    ThresholdValue FLOAT NOT NULL,
    ActionSceneID INT NOT NULL,
    FOREIGN KEY (TriggerDeviceID) REFERENCES Devices(DeviceID),
    FOREIGN KEY (ActionSceneID) REFERENCES Scenes(SceneID)
);
GO

USE SmartHomeDB;
GO

-- 1. Insert Users
INSERT INTO Users (Username, PasswordHash, FullName, Role) VALUES
('admin', 'hash123', 'System Administrator', 'Admin'),
('john_doe', 'pass456', 'John Doe', 'Member'),
('jane_doe', 'pass789', 'Jane Doe', 'Member'),
('guest_user', 'guest000', 'Guest', 'Member'),
('kid_user', 'kid111', 'Kid Account', 'Member');
GO

-- 2. Insert Rooms
INSERT INTO Rooms (RoomName, FloorNumber) VALUES
('Living Room', 1),
('Kitchen', 1),
('Master Bedroom', 2),
('Kids Bedroom', 2),
('Garage', 0);
GO

-- 3. Insert DeviceTypes
INSERT INTO DeviceTypes (TypeName, Description) VALUES
('Smart Light', 'Adjustable LED Light'),
('Thermostat', 'Temperature Control Unit'),
('Motion Sensor', 'Detects movement'),
('Smart Lock', 'Electronic Door Lock'),
('Security Camera', 'HD IP Camera');
GO

-- 4. Insert Devices
-- Assumes IDs 1-5 generated above correspond to the order of insertion
INSERT INTO Devices (DeviceName, TypeID, RoomID, CurrentStatus, IsActive) VALUES
('Living Room Main Light', 1, 1, 'ON', 1),
('Kitchen Thermostat', 2, 2, '22.5', 1),
('Front Door Lock', 4, 1, 'LOCKED', 1),
('Garage Motion Sensor', 3, 5, 'NO_MOTION', 1),
('Master Bedroom Light', 1, 3, 'OFF', 1),
('Backyard Camera', 5, 5, 'RECORDING', 1),
('Kids Room Light', 1, 4, 'ON', 1);
GO

-- 5. Insert Sensor Readings
INSERT INTO SensorReadings (DeviceID, ReadingValue, Unit) VALUES
(2, 22.5, 'Celsius'),
(2, 22.8, 'Celsius'),
(2, 23.0, 'Celsius'),
(2, 21.5, 'Celsius'),
(4, 1.0, 'Boolean'); -- 1 for Motion Detected
GO

-- 6. Insert Scenes
INSERT INTO Scenes (SceneName, CreatedBy) VALUES
('Good Night', 1),
('Away Mode', 1),
('Movie Time', 2),
('Morning Routine', 3),
('Party Mode', 1);
GO

-- 7. Insert Scene Actions
-- Defines what happens when "Good Night" (SceneID 1) runs
INSERT INTO SceneActions (SceneID, DeviceID, TargetStatus, TargetValue) VALUES
(1, 1, 'OFF', NULL), -- Turn off Living Room Light
(1, 3, 'LOCKED', NULL), -- Lock Front Door
(1, 5, 'OFF', NULL), -- Turn off Master Bedroom Light
(3, 1, 'DIM', 20.0), -- Dim lights for Movie Time
(2, 2, 'ECO', 18.0); -- Set Thermostat to 18 for Away Mode
GO

-- 8. Insert Automation Rules
INSERT INTO AutomationRules (RuleName, TriggerDeviceID, ConditionOperator, ThresholdValue, ActionSceneID) VALUES
('Auto Cool Down', 2, '>', 28.0, 2), -- If Temp > 28, trigger Away/Cool scene
('Intruder Alert', 4, '=', 1.0, 2), -- If Motion=1, trigger Away Mode (as example)
('Night Lock', 3, '=', 0.0, 1),
('Morning Warmup', 2, '<', 18.0, 4),
('Camera Rec on Motion', 4, '=', 1.0, 2);
GO

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

USE SmartHomeDB;
GO

CREATE TABLE SystemLogs (
    LogID INT PRIMARY KEY IDENTITY(1,1),
    LogMessage NVARCHAR(255),
    LogDate DATETIME DEFAULT GETDATE()
);
GO

-- SECTION A: STORED PROCEDURES

-- 1. SP_ActivateScene
CREATE PROCEDURE SP_ActivateScene
    @SceneID INT
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE d
    SET 
        d.CurrentStatus = sa.TargetStatus,
        d.IsActive = 1
    FROM Devices d
    INNER JOIN SceneActions sa ON d.DeviceID = sa.DeviceID
    WHERE sa.SceneID = @SceneID AND sa.TargetStatus IS NOT NULL;

    INSERT INTO SystemLogs (LogMessage)
    VALUES ('Scene Activated: ' + CAST(@SceneID AS VARCHAR(10)));
    
    PRINT 'Scene executed successfully.';
END;
GO

-- 2. SP_RegisterNewDevice
CREATE PROCEDURE SP_RegisterNewDevice
    @DeviceName VARCHAR(100),
    @TypeID INT,
    @RoomID INT
AS
BEGIN
    IF NOT EXISTS (SELECT 1 FROM DeviceTypes WHERE TypeID = @TypeID)
    BEGIN
        PRINT 'Error: Invalid Device Type ID.';
        RETURN;
    END

    INSERT INTO Devices (DeviceName, TypeID, RoomID, CurrentStatus)
    VALUES (@DeviceName, @TypeID, @RoomID, 'OFF');
    
    PRINT 'Device registered successfully.';
END;
GO

-- 3. SP_RecordSensorReading
CREATE PROCEDURE SP_RecordSensorReading
    @DeviceID INT,
    @Value FLOAT,
    @Unit VARCHAR(20)
AS
BEGIN
    INSERT INTO SensorReadings (DeviceID, ReadingValue, Unit)
    VALUES (@DeviceID, @Value, @Unit);

    IF (@Unit = 'Celsius' AND @Value > 30.0)
    BEGIN
        PRINT 'WARNING: High temperature detected!';
    END
END;
GO

-- SECTION B: TRIGGERS (3 Items)

-- 1. TRG_AuditDeviceStatus
CREATE TRIGGER TRG_AuditDeviceStatus
ON Devices
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    
    IF UPDATE(CurrentStatus)
    BEGIN
        INSERT INTO SystemLogs (LogMessage)
        SELECT 
            'Device ' + CAST(i.DeviceID AS VARCHAR(10)) + 
            ' changed from ' + d.CurrentStatus + 
            ' to ' + i.CurrentStatus
        FROM inserted i
        JOIN deleted d ON i.DeviceID = d.DeviceID;
    END
END;
GO

-- 2. TRG_PreventCriticalDelete
CREATE TRIGGER TRG_PreventCriticalDelete
ON Devices
INSTEAD OF DELETE
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS (SELECT 1 FROM deleted WHERE CurrentStatus IN ('LOCKED', 'ON', 'RECORDING'))
    BEGIN
        RAISERROR ('Cannot delete active or locked devices. Turn them OFF first.', 16, 1);
    END
    ELSE
    BEGIN
        DELETE FROM Devices WHERE DeviceID IN (SELECT DeviceID FROM deleted);
        PRINT 'Device deleted successfully.';
    END
END;
GO

-- 3. TRG_AutoSecurityAlert
CREATE TRIGGER TRG_AutoSecurityAlert
ON SensorReadings
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS (SELECT 1 FROM inserted WHERE Unit = 'Boolean' AND ReadingValue = 1.0)
    BEGIN
        INSERT INTO SystemLogs (LogMessage)
        SELECT 'SECURITY ALERT: Motion detected on device ' + CAST(DeviceID AS VARCHAR(10))
        FROM inserted
        WHERE Unit = 'Boolean' AND ReadingValue = 1.0;
    END
END;
GO

USE SmartHomeDB;
GO

PRINT '--- STARTING SYSTEM TESTS ---';

EXEC SP_RegisterNewDevice 'New Smart TV', 1, 1;
PRINT 'Test 1: Device Registered.';


EXEC SP_ActivateScene 1;
PRINT 'Test 2: Scene Activated.';

SELECT * FROM SystemLogs;


BEGIN TRY
    DELETE FROM Devices WHERE DeviceName = 'Front Door Lock';
END TRY
BEGIN CATCH
    PRINT 'Test 4 Success: Prevented deletion of locked device. Error: ' + ERROR_MESSAGE();
END CATCH;


INSERT INTO SensorReadings (DeviceID, ReadingValue, Unit) 
VALUES (4, 1.0, 'Boolean');

SELECT * FROM SystemLogs ORDER BY LogDate DESC;

PRINT '--- TESTS COMPLETED ---';

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

