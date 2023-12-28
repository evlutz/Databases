CREATE DATABASE HospitalDBMS;

CREATE TABLE Employee(
    empID Integer PRIMARY KEY,
    FNAME VARCHAR(255),
    LNAME VARCHAR(255),
    Salary Float,
    jobTitle VARCHAR(255),
    OfficeNum Integer,
    empRank Integer,
    supervisorID Integer,
    AddressStreet VARCHAR(255),
    AddressCity VARCHAR(255),
    AddressZip VARCHAR(255),
    FOREIGN KEY (supervisorID) REFERENCES Employee(empID)
);

CREATE TABLE Doctor(
    EmployeeID Integer PRIMARY KEY,
    gender VARCHAR(255),
    specialty VARCHAR(255),
    GraduatedFrom VARCHAR(255),
    FOREIGN KEY (EmployeeID) REFERENCES Employee(empID)
);

CREATE TABLE EquipmentTechnician(
    EmployeeID Integer PRIMARY KEY,
    FOREIGN KEY (EmployeeID) REFERENCES Employee(empID)
);

CREATE TABLE EquipmentType(
    equipID VARCHAR(255) PRIMARY KEY,
    equipDesc VarCHAR(255),
    equipModel VARCHAR(255),
    instructions VARCHAR(255),
    NumberOfUnits Integer
);

CREATE TABLE CanRepairEquipment(
    EmployeeID Integer,
    EquipmentType VARCHAR(255),
    PRIMARY KEY (EmployeeID, EquipmentType),
    FOREIGN KEY (EmployeeID) REFERENCES Employee(empID),
    FOREIGN KEY (EquipmentType) REFERENCES EquipmentType(equipID)
);

CREATE TABLE Room(
    rNum Integer PRIMARY KEY,
    occupied CHAR(1)
);

CREATE TABLE RoomService(
    roomNum Integer,
    roomService VARCHAR(255),
    FOREIGN KEY (roomNum) REFERENCES Room(rNum),
    PRIMARY KEY (roomNum, roomService)
);

CREATE TABLE RoomAccess(
    roomNum Integer,
    EmpID Integer,
    FOREIGN KEY (roomNum) REFERENCES Room(rNum),
    FOREIGN KEY (EmpID) REFERENCES Employee(empID),
    PRIMARY KEY (roomNum, EmpID)
);

CREATE TABLE Equipment(
    SerialNumb VARCHAR(255),
    TypeID VARCHAR(255),
    PurchaseYear Integer,
    LastInspection DATE,
    roomNum Integer,
    PRIMARY KEY (SerialNumb),
    FOREIGN KEY (TypeID) REFERENCES EquipmentType(equipID),
    FOREIGN KEY (roomNum) REFERENCES Room(rNum)
);

CREATE TABLE Patient(
    SSN INTEGER PRIMARY KEY,
    FirstName VARCHAR(255),
    LastName VARCHAR(255),
    Address VARCHAR(255),
    TelNum Integer
);

CREATE TABLE Admission(
    admissionNum Integer PRIMARY KEY,
    AdmissionDate DATE,
    LeaveDate DATE,
    TotalPayment Float,
    InsurancePayment Float,
    Patient_SSN Integer,
    FutureVisit DATE,       -- A patient may make a future appointment when they are admitted
    FOREIGN KEY (Patient_SSN) REFERENCES Patient(SSN)
);

CREATE TABLE Examine(
    DoctorID Integer,
    AdmissionNum Integer,
    ExamineComment VARCHAR(255),
    FOREIGN KEY (DoctorID) REFERENCES Doctor(EmployeeID),
    FOREIGN KEY (AdmissionNum) REFERENCES Admission(admissionNum),
    PRIMARY KEY (DoctorID, AdmissionNum)
);

CREATE TABLE StayIn(
    AdmissionNum Integer,
    RoomNum Integer,
    startDate Date,
    endDate Date,
    FOREIGN KEY (AdmissionNum) REFERENCES Admission(admissionNum),
    FOREIGN KEY (RoomNum) REFERENCES Room(rNum),
    PRIMARY KEY (AdmissionNum, RoomNum, startDate)
);
