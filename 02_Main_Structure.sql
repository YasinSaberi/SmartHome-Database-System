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