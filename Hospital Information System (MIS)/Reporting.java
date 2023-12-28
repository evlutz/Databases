import java.math.BigDecimal;
import java.sql.*;
import java.util.HashSet;
import java.util.Scanner;
import java.util.Set;


public class Reporting {

    public static void main(String[] args) throws SQLException{
        if (args.length < 2) {
            System.out.println("Usage: java Reporting <username> <password>");
            return;
        }

        String username = args[0];
        String password = args[1];

        // System.out.println("-------- Oracle JDBC Connection Testing ------");
        // System.out.println("-------- Registering Oracle Driver ------");
        try {
            Class.forName("oracle.jdbc.driver.OracleDriver");
        } catch (ClassNotFoundException e) {
            System.out.println("Where is your Oracle JDBC Driver? Did you follow the execution steps?");
            System.out.println("*****Open the file and read the comments in the beginning of the file****");
            e.printStackTrace();
            return;
        }
        //System.out.println("Oracle JDBC Driver Registered Successfully !");
        //System.out.println("-------- Building a Connection ------");
        Connection connection = null;
        try {
            connection = DriverManager.getConnection(
                    "jdbc:oracle:thin:@oracle.wpi.edu:1521:orcl",
                    username,
                    password);
        } catch (SQLException e) {
            System.out.println("Connection Failed! Check output console");
            e.printStackTrace();
            return;
        }
        if (connection != null) {
            //System.out.println("You made it. Connection is successful");
        } else {
            System.out.println("Failed to make connection!");
        }

        Scanner input = new Scanner(System.in);




        if(args.length == 2){
            System.out.println("1- Report Patients Basic Information");
            System.out.println("2- Report Doctors Basic Information");
            System.out.println("3- Report Admissions Information");
            System.out.println("4- Update Admissions Payment");
        }
        else if(args.length == 3 && Integer.parseInt(args[2]) == 1){
            System.out.print("Enter Patient SSN: ");
            int SSN = input.nextInt();

            PreparedStatement pstmt = connection.prepareStatement("SELECT * FROM PATIENT WHERE SSN = ?");
            pstmt.setInt(1, SSN);
            ResultSet rset = pstmt.executeQuery();

            int outputSSN;
            String FirstName, LastName, Address;
            while(rset.next()){
                outputSSN = rset.getInt("SSN");
                FirstName = rset.getString("FirstName");
                LastName = rset.getString("LastName");
                Address = rset.getString("Address");
                System.out.println("Patient SSN: " + outputSSN);
                System.out.println("Patient First Name: " + FirstName);
                System.out.println("Patient Last Name: " + LastName);
                System.out.println("Patient Address: " + Address);
            }

            rset.close();
        }
        else if(args.length == 3 && Integer.parseInt(args[2]) == 2){
            System.out.print("Enter Doctor ID: ");
            int ID = input.nextInt();

            PreparedStatement pstmt = connection.prepareStatement("SELECT * FROM DOCTOR, EMPLOYEE WHERE EmployeeID = empID AND EmployeeID = ?");
            pstmt.setInt(1, ID);
            ResultSet rset = pstmt.executeQuery();

            int DoctorID;
            String FirstName, LastName, Gender, GraduatedFrom, Specialty;
            while(rset.next()){
                DoctorID = rset.getInt("EmployeeID");
                FirstName = rset.getString("FName");
                LastName = rset.getString("LName");
                Gender = rset.getString("gender");
                GraduatedFrom = rset.getString("GraduatedFrom");
                Specialty = rset.getString("specialty");

                System.out.println("Doctor ID: " + DoctorID);
                System.out.println("Doctor First Name: " + FirstName);
                System.out.println("Doctor Last Name: " + LastName);
                System.out.println("Doctor Gender: " + Gender);
                System.out.println("Doctor Graduated From: " + GraduatedFrom);
                System.out.println("Doctor Specialty: " + Specialty);
            }

            rset.close();
        }
        else if(args.length == 3 && Integer.parseInt(args[2]) == 3){
            System.out.print("Enter Admission Number: ");
            int aNum = input.nextInt();

            PreparedStatement pstmt1 = connection.prepareStatement("SELECT * FROM ADMISSION WHERE admissionNum = ?");
            pstmt1.setInt(1, aNum);
            ResultSet rset1 = pstmt1.executeQuery();
            int admissionNumber, SSN;
            BigDecimal totalPayment;
            String admissionDate;

            PreparedStatement pstmt2 = connection.prepareStatement("SELECT * FROM STAYIN WHERE AdmissionNum = ?");
            pstmt2.setInt(1, aNum);
            ResultSet rset2 = pstmt2.executeQuery();
            int roomNum;
            String startDate, leaveDate;

            PreparedStatement pstmt3 = connection.prepareStatement("SELECT * FROM EXAMINE WHERE AdmissionNum = ?");
            pstmt3.setInt(1, aNum);
            ResultSet rset3 = pstmt3.executeQuery();
            Set<Integer> uniqueDoctorIDs = new HashSet<>();
            int doctorID;

            while(rset1.next()){
                admissionNumber = rset1.getInt("admissionNum");
                SSN = rset1.getInt("Patient_SSN");
                admissionDate = rset1.getString("AdmissionDate");
                totalPayment = rset1.getBigDecimal("TotalPayment");

                System.out.println("Admission Number: " + admissionNumber);
                System.out.println("Patient SSN: " + SSN);
                System.out.println("Admission date (start date): " + admissionDate);
                System.out.println("Total Payment: " + totalPayment);
                System.out.println("Rooms:");

                while(rset2.next()){
                    roomNum = rset2.getInt("RoomNum");
                    startDate = rset2.getString("startDate");
                    leaveDate = rset2.getString("endDate");

                    System.out.println("\tRoomNum: " + roomNum + "\tFromDate: " + startDate + "\tToDate: " + leaveDate);
                }

                System.out.println("Doctors examined the patient in this admission:");

                while(rset3.next()){
                    doctorID = rset3.getInt("DoctorID");
                    if(uniqueDoctorIDs.add(doctorID))
                        System.out.println("\tDoctor ID:" + doctorID);
                }
            }

            rset1.close();
            rset2.close();
            rset3.close();
        }
        else if(args.length == 3 && Integer.parseInt(args[2]) == 4) {
            System.out.print("Enter Admission Number: ");
            int SSN = input.nextInt();

            System.out.print("Enter the new total payment: ");
            BigDecimal newPayment = input.nextBigDecimal();
            System.out.println(newPayment);

            PreparedStatement pstmt = connection.prepareStatement("UPDATE ADMISSION SET TotalPayment= ? WHERE admissionNum = ?");
            pstmt.setBigDecimal(1, newPayment);
            pstmt.setInt(2, SSN);
            pstmt.executeUpdate();

        }

        connection.close();
    }
}
