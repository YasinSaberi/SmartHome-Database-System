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