-- Triggers TEST CASES -------------------------------------------

-- Trigger: IsICUPatient *******************************************
-- Does not allow an empty ExamineComment when the patient is in the ICU

INSERT INTO Room (rNum, occupied) VALUES (999, 1);

INSERT INTO RoomService (roomNum, roomService) VALUES (999, 'ICU');

INSERT INTO Patient (SSN, FirstName, LastName, Address, TelNum) VALUES (777669999, 'Kensuke', 'Imamura', '31 Pinto St, Tokyo Japana', 9993331111);

--Admission Does visit ICU
INSERT INTO Admission (admissionNum, AdmissionDate, LeaveDate, TotalPayment, InsurancePayment, Patient_SSN, FutureVisit)
VALUES (1019, TO_DATE('12/13/2023', 'MM/DD/YYYY'), NULL, 100000, NULL, 777669999, NULL);

INSERT INTO StayIn (AdmissionNum, RoomNum, StartDate, EndDate) VALUES (1019, 999, TO_DATE('12/10/2023', 'MM/DD/YYYY'), TO_DATE('12/13/2023', 'MM/DD/YYYY'));

--Does not allow no comment
INSERT INTO Examine (DoctorID, AdmissionNum, ExamineComment) VALUES (14, 1019, '');

-- Admission does not visit ICU
INSERT INTO Admission (admissionNum, AdmissionDate, LeaveDate, TotalPayment, InsurancePayment, Patient_SSN, FutureVisit)
VALUES (1020, TO_DATE('12/13/2023', 'MM/DD/YYYY'), NULL, 100000, NULL, 777669999, NULL);

INSERT INTO StayIn (AdmissionNum, RoomNum, StartDate, EndDate) VALUES (1020, 101, TO_DATE('12/10/2023', 'MM/DD/YYYY'), TO_DATE('12/13/2023', 'MM/DD/YYYY'));

--Allows no comment
INSERT INTO Examine (DoctorID, AdmissionNum, ExamineComment) VALUES (14, 1020, '');



-- Trigger: CalculateInsurancePayment *******************************************
-- Calculates InsurancePayment based on TotalPayment and sets it if it is NULL

INSERT INTO Patient (SSN, FirstName, LastName, Address, TelNum) VALUES (999331111, 'Hunter', 'Mahr', '36 Hermitage Rd, Brockton, MA', 3332210734);

--Admissions with NULL InsurancePayment
INSERT INTO Admission (admissionNum, AdmissionDate, LeaveDate, TotalPayment, InsurancePayment, Patient_SSN, FutureVisit)
VALUES (1006, TO_DATE('12/13/2023', 'MM/DD/YYYY'), NULL, 100000, NULL, 999331111, NULL);

INSERT INTO Admission (admissionNum, AdmissionDate, LeaveDate, TotalPayment, InsurancePayment, Patient_SSN, FutureVisit)
VALUES (1007, TO_DATE('12/13/2023', 'MM/DD/YYYY'), NULL, 250000, 0, 999331111, NULL);

--Fetch InsurancePayments
SELECT InsurancePayment, AdmissionNum
FROM Admission
WHERE admissionNum = 1006 OR admissionNum = 1007;



-- Trigger: HasCorrectManager *******************************************
-- Checks and enforces correct management hierarchy rules

--Regular employee with a RE manager
INSERT INTO Employee (empID, FNAME, LNAME, Salary, jobTitle, OfficeNum, empRank, supervisorID, AddressStreet, AddressCity, AddressZip)
VALUES (22, 'Test', 'HasCorrectManager', 0, 'GlobalManager', 101, 0, 7, '44 Redline Street', 'Cleveland', 28321);

--Invalid Emp Rank
INSERT INTO Employee (empID, FNAME, LNAME, Salary, jobTitle, OfficeNum, empRank, supervisorID, AddressStreet, AddressCity, AddressZip)
VALUES (23, 'Test2', 'IsValudEmpRank', 0, 'GlobalManager', 101, 3, NULL, '44 Redline Street', 'Cleveland', 28321);

--Should pass, GM with no manager
INSERT INTO Employee (empID, FNAME, LNAME, Salary, jobTitle, OfficeNum, empRank, supervisorID, AddressStreet, AddressCity, AddressZip)
VALUES (26, 'Test2', 'IsValudEmpRan2k', 0, 'GlobalManager', 101, 2, NULL, '44 Redline Street', 'Cleveland', 28321);

--GM with a manager
INSERT INTO Employee (empID, FNAME, LNAME, Salary, jobTitle, OfficeNum, empRank, supervisorID, AddressStreet, AddressCity, AddressZip)
VALUES (26, 'Test2', 'IsValudEmpRan2k', 0, 'GlobalManager', 101, 2, 7, '44 Redline Street', 'Cleveland', 28321);

--RE given no manager
INSERT INTO Employee (empID, FNAME, LNAME, Salary, jobTitle, OfficeNum, empRank, supervisorID, AddressStreet, AddressCity, AddressZip)
VALUES (25, 'Test3', 'IsValudEmpRan2k', 0, 'GlobalManager', 101, 0, NULL, '44 Redline Street', 'Cleveland', 28321);



-- Trigger: EMCVisit *******************************************
-- Sets FutureVisit for admissions that went to the Emergency Room or ICU
-- Admission numbers: 1019 (ICU visit) and 1020 (No ICU visit)

--Grab visit that went to ICU: 1019 (From Q1 test case)
-- 1020 Did not visit ICU
SELECT FutureVisit, AdmissionNum
FROM Admission
WHERE admissionNum = 1019 OR admissionNum = 1020;



-- Trigger: NewEquipment *******************************************
-- Sets LastInspection for new equipment based on technician availability

INSERT INTO Equipment (SerialNumb, TypeID, PurchaseYear, LastInspection, roomNum) VALUES ('D0203X', 'Ultrasound', 2023, NULL, 1006);

SELECT *
FROM Equipment e
WHERE e.SerialNumb = 'D0203X';

