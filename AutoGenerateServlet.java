package com.timetable;

import java.io.IOException;
import java.sql.*;
import java.util.*;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

@WebServlet("/AutoGenerateServlet")
public class AutoGenerateServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        try {

            Class.forName("com.mysql.cj.jdbc.Driver");

            Connection con = DriverManager.getConnection(
                    "jdbc:mysql://localhost:3306/timetable_db",
                    "root",
                    "your password");

            String[] days = {"Mon","Tue","Wed","Thu","Fri"};
            String[] times = {"9-10","10-11","11-12","1-2","2-3"};

            Random rand = new Random();

            /* GET ALL CLASSES */
            Statement st = con.createStatement();
            ResultSet classRs = st.executeQuery("SELECT class_id FROM class");

            while(classRs.next()){

                int class_id = classRs.getInt("class_id");

                for(String day : days){
                    for(String time : times){

                        /* GET RANDOM SUBJECT */
                        Statement subSt = con.createStatement();
                        ResultSet subRs = subSt.executeQuery("SELECT subject_id FROM subject ORDER BY RAND() LIMIT 1");
                        subRs.next();
                        int subject_id = subRs.getInt("subject_id");

                        /* GET RANDOM FACULTY */
                        Statement facSt = con.createStatement();
                        ResultSet facRs = facSt.executeQuery("SELECT faculty_id FROM faculty ORDER BY RAND() LIMIT 1");
                        facRs.next();
                        int faculty_id = facRs.getInt("faculty_id");

                        int room_no = rand.nextInt(5) + 101;

                        /* 🔥 CONFLICT CHECK */
                        String checkQuery = "SELECT * FROM timetable "
                                + "WHERE day=? AND time_slot=? "
                                + "AND (faculty_id=? OR room_no=?)";

                        PreparedStatement checkPs = con.prepareStatement(checkQuery);

                        checkPs.setString(1, day);
                        checkPs.setString(2, time);
                        checkPs.setInt(3, faculty_id);
                        checkPs.setInt(4, room_no);

                        ResultSet checkRs = checkPs.executeQuery();

                        if(!checkRs.next()){  // ✅ NO CONFLICT

                            String insert = "INSERT INTO timetable "
                                    + "(class_id, subject_id, faculty_id, day, room_no, time_slot) "
                                    + "VALUES (?,?,?,?,?,?)";

                            PreparedStatement ps = con.prepareStatement(insert);

                            ps.setInt(1, class_id);
                            ps.setInt(2, subject_id);
                            ps.setInt(3, faculty_id);
                            ps.setString(4, day);
                            ps.setInt(5, room_no);
                            ps.setString(6, time);

                            ps.executeUpdate();
                        }

                        checkRs.close();
                        checkPs.close();
                    }
                }
            }

            con.close();

            response.getWriter().println("<h2 style='color:green;'>Auto Timetable Generated Successfully!</h2>");

        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}
