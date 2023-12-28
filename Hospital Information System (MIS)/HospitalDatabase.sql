DROP TABLE StayIn;

DROP TABLE Examine;

DROP TABLE Admission;

DROP TABLE Patient;

DROP TABLE Equipment;

DROP TABLE RoomAccess;

DROP TABLE RoomService;

DROP TABLE Room;

DROP TABLE CanRepairEquipment;

DROP TABLE EquipmentType;

DROP TABLE EquipmentTechnician;

DROP TABLE Doctor;

DROP TABLE Employee;


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


-- QUERYS --------------------------------------------------------


-- Doctors graduated from WPI

 

SELECT EmployeeID, GraduatedFrom, specialty, gender

FROM Doctor

WHERE GraduatedFrom = 'WPI';

 

-- Report employees managed by given manager

SELECT e.empID, e.FNAME, e.LNAME, e.Salary

FROM Employee e

WHERE e.supervisorID = 5;


 

-- Sum the total amount paid by insurance companies for each patient
 

SELECT SSN, SUM(InsurancePayment) AS totalInsurance

FROM Patient, Admission

WHERE Patient.SSN = Admission.Patient_SSN

GROUP BY Patient.SSN;

 

-- Report tge total admissions for each patient
 

SELECT SSN, FirstName, LastName, COUNT(admissionNum) AS NumbVisits

FROM Patient, Admission

WHERE Patient.SSN = Admission.Patient_SSN

GROUP BY Patient.SSN, Patient.FirstName, Patient.LastName;


 


-- Report the Employee who has access to the most amount of rooms

SELECT EmpID, COUNT(roomNum) AS RoomCount
FROM RoomAccess
GROUP BY EmpID
HAVING COUNT(roomNum) = (SELECT MAX(RoomCount) FROM (SELECT COUNT(roomNum) AS RoomCount FROM RoomAccess GROUP BY EmpID));


 

-- Report the number of regular employees, division managers, and general managers in the hospital


SELECT 'Regular Employee' AS empRank, COUNT(empID) AS Count
FROM Employee
WHERE empRank=0 
GROUP BY empRank
UNION
SELECT 'Division Manager' AS empRank, COUNT(empID) AS Count
FROM Employee
WHERE empRank=1
GROUP BY empRank
UNION
SELECT 'General Manager' AS empRank, COUNT(empID) AS Count
FROM Employee
WHERE empRank=2
GROUP BY empRank;


-- Reports patients who have a current future visit

 

SELECT p.SSN, p.FirstName, p.LastName, a.FutureVisit AS VisitDate
FROM Patient p, Admission a
WHERE p.SSN = a.Patient_SSN AND a.FutureVisit IS NOT NULL 
    AND a.FutureVisit = (
        SELECT MAX(a.FutureVisit)
        FROM Admission a
        WHERE a.Patient_SSN = p.SSN
    );

 

-- Reports all equipment types that have less than two technicians that can maintain them.

 
SELECT ET.equipID, ET.equipDesc, ET.equipmodel, COUNT(CR.EmployeeID) AS NumbTecs
FROM EquipmentType ET, CanRepairEquipment CR
WHERE CR.EquipmentType = ET.equipID
GROUP BY ET.equipID, ET.equipDesc, ET.equipModel
HAVING COUNT(CR.EmployeeID) < 2;




-- Report the next future visit for a given patient

SELECT a.FutureVisit AS VisitDate
FROM Patient p, Admission a
WHERE p.SSN = a.Patient_SSN AND a.FutureVisit IS NOT NULL AND p.SSN = 111223333
    AND a.FutureVisit = (
        SELECT MAX(a.FutureVisit)
        FROM Admission a
        WHERE a.Patient_SSN = p.SSN
    );
 
 

-- Report all doctors who have examined a given patient

SELECT DoctorID

FROM Admission, Examine

WHERE Examine.AdmissionNum = Admission.admissionNum AND Admission.Patient_SSN = 111223333

GROUP BY Examine.DoctorID

HAVING COUNT(Admission.AdmissionNum) > 2;

 

-- Report equipment which was purchased in a given year
 

SELECT DISTINCT equipID

FROM EquipmentType, Equipment

WHERE Equipment.TypeID = EquipmentType.equipID AND Equipment.PurchaseYear >= 2010 AND Equipment.PurchaseYear <= 2011

GROUP BY Equipment.TypeID

HAVING COUNT(PurchaseYear) >= 2;




-- VIEWS --------------------------------------------------------------------------------------------

-- Drop the views
DROP VIEW IF EXISTS CriticalCases;
DROP VIEW IF EXISTS DoctorsLoad;
DROP VIEW IF EXISTS Critical_Case_Patients;
DROP VIEW IF EXISTS OverloadedWPIDoctors;
DROP VIEW IF EXISTS UnderloadedDoctorsComments;

-- Create a view CriticalCases to identify patients with multiple ICU admissions
CREATE VIEW CriticalCases AS
SELECT p.SSN AS Patient_SSN, p.firstName, p.lastName, count(a.admissionNum) AS numberOfAdmissionsToICU
FROM Admission a, Patient p,(
    SELECT si.AdmissionNum
    FROM StayIn si, RoomService rs
    WHERE rs.roomNum = si.roomNum
    AND rs.roomService = 'ICU'
) si
WHERE si.admissionNum = a.AdmissionNum
AND a.Patient_SSN = p.SSN
GROUP BY p.SSN, p.FirstName, p.LastName
HAVING COUNT(*) > 1;

-- Create a view DoctorsLoad to assess doctor workload based on examinations
CREATE VIEW DoctorsLoad AS
SELECT
    D.EmployeeID AS DoctorID,
    D.GraduatedFrom,
    CASE
        WHEN COUNT(DISTINCT E.AdmissionNum) > 10 THEN 'Overload'
        ELSE 'Underload'
    END AS Load
FROM
    Doctor D
LEFT JOIN
    Examine E ON D.EmployeeID = E.DoctorID
GROUP BY
    D.EmployeeID, D.GraduatedFrom;

-- Create a view Critical_Case_Patients to display patients with critical cases
CREATE VIEW Critical_Case_Patients AS
SELECT p.SSN, p.FirstName, p.LastName, p.Address, p.TelNum
FROM CriticalCases cc, Patient p
WHERE cc.numberOfAdmissionsToICU > 4 AND cc.Patient_SSN = p.SSN;

-- Create a view OverloadedWPIDoctors to identify doctors with an overload from WPI
CREATE VIEW OverloadedWPIDoctors AS
SELECT
    dl.DoctorID,
    E.FNAME AS FirstName,
    E.LNAME AS LastName
FROM
    DoctorsLoad dl, Employee E
WHERE
    dl.DoctorID = E.empID AND Load = 'Overload' AND GraduatedFrom = 'WPI';

-- Create a view UnderloadedDoctorsComments to display comments for underloaded doctors
CREATE VIEW UnderloadedDoctorsComments AS
SELECT e.DoctorID, ca.Patient_SSN, e.ExamineComment
FROM Examine e, DoctorsLoad dl,(
    SELECT admissionNum, CC.Patient_SSN 
    FROM Admission A, CriticalCases CC
    WHERE A.Patient_SSN = CC.Patient_SSN
) ca
WHERE ca.admissionNum = e.AdmissionNum
AND e.DoctorID = dl.DoctorID
AND dl.Load = 'Underload';

-- Test Views --
SELECT * FROM CriticalCases;
SELECT * FROM DoctorsLoad;
SELECT * FROM Critical_Case_Patients;
SELECT * FROM OverloadedWPIDoctors;
SELECT * FROM UnderloadedDoctorsComments;

-- Triggers ----------------------------------------------

-- Trigger to enforce that a doctor must leave a note if the patient is in the ICU

CREATE OR REPLACE TRIGGER IsICUPatient
BEFORE INSERT OR UPDATE ON Examine
FOR EACH ROW
DECLARE
    v_ICU_Count NUMBER;
BEGIN
    -- Count the number of ICU stays for the given AdmissionNum
    SELECT COUNT(*)
    INTO v_ICU_Count
    FROM StayIn si, RoomService rs
    WHERE si.roomNum = rs.roomNum AND (rs.roomService = 'ICU' OR rs.roomService = 'Emergency Room')
    AND si.AdmissionNum = :NEW.AdmissionNum;  
    -- Check if ExamineComment is empty or NULL and the patient is in the ICU
    IF (:NEW.ExamineComment = '' OR :NEW.ExamineComment IS NULL) AND v_ICU_Count > 0 THEN
        RAISE_APPLICATION_ERROR(-20001, 'A doctor must leave a note if the patient is in the ICU');
    END IF;
END;
/

-- Trigger to calculate the insurance payment based on total payment for a new admission

CREATE OR REPLACE TRIGGER CalculateInsurancePayment
BEFORE INSERT ON Admission
FOR EACH ROW
BEGIN
    IF :NEW.InsurancePayment IS NULL THEN
        :NEW.InsurancePayment := 0;
    END IF;
    IF :NEW.InsurancePayment <> :NEW.TotalPayment * 0.65 THEN
        :NEW.InsurancePayment := :NEW.TotalPayment * 0.65;
    END IF;
END;
/

-- Trigger to ensure that employee ranks and supervisors are set correctly

CREATE OR REPLACE TRIGGER HasCorrectManager
BEFORE INSERT OR UPDATE ON Employee
FOR EACH ROW
DECLARE
    v_SupervisorRank INTEGER;
BEGIN
    -- EmpRank must be less than or equal to 2
    IF (:NEW.empRank > 2) THEN
        RAISE_APPLICATION_ERROR(-20002, 'Invalid empRank');
    END IF;
    
    -- EmpRank must be less than or equal to 2
    IF (:NEW.empRank < 2 AND :NEW.supervisorID IS NULL) THEN
        RAISE_APPLICATION_ERROR(-20002, 'A regular employee or division manager MUST have a manager');
    END IF;
    
    -- If EmpRank = 2 they CANNOT have a supervisor
    IF (:NEW.empRank = 2 AND :NEW.supervisorID IS NOT NULL) THEN
        RAISE_APPLICATION_ERROR(-20002, 'GMs cannot have a manager');
    END IF;
        
    -- Attempt to retrieve the supervisor's rank
        SELECT empRank INTO v_SupervisorRank
        FROM Employee
        WHERE empID = :NEW.supervisorID;

        -- Supervisor emprank must equal the employee's ++1
    IF (:NEW.empRank < 2 AND (:NEW.empRank + 1) <> v_SupervisorRank) THEN
        RAISE_APPLICATION_ERROR(-20001, 'An employee must have a manager directly 1 rank above them unless it is a General Manager, or a GM cannot have a supervisor');
    END IF;

    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            -- Handle the case when rank 2 employee's manager is checked
            NULL;
END;
/

-- Trigger to update the FutureVisit for an admission if the patient stays in the Emergency Room or ICU

CREATE OR REPLACE TRIGGER EMCVisit
BEFORE INSERT ON StayIn
FOR EACH ROW
DECLARE
    v_IsEMCRoom INTEGER;
BEGIN
    SELECT COUNT(*) INTO v_IsEMCRoom
    FROM RoomService rs
    WHERE (rs.roomService = 'Emergency Service' OR rs.roomService = 'ICU') AND :NEW.RoomNum = rs.roomNum;

    IF v_IsEMCRoom > 0 THEN
        UPDATE Admission
        SET FutureVisit = ADD_MONTHS(SYSDATE, 2)
        WHERE admissionNum = :NEW.AdmissionNum;
    END IF;
END;
/

-- Trigger to update the LastInspection for new equipment if it can be repaired by a technician

CREATE OR REPLACE TRIGGER NewEquipment
BEFORE INSERT ON Equipment
FOR EACH ROW
DECLARE
    v_IsTechnician INTEGER;
BEGIN
    SELECT COUNT(*)
    INTO v_IsTechnician
    FROM CanRepairEquipment cre
    WHERE :NEW.TypeID = cre.EquipmentType;

    IF v_IsTechnician > 0 THEN
        :NEW.LastInspection := SYSDATE;
    END IF;
END;
/



