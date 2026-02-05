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