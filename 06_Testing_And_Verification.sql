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