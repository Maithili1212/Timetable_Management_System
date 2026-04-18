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

    String[] days = {"Mon","Tue","Wed","Thu","Fri"};
    String[] times = {"9-10","10-11","11-12","1-2","2-3"};

    Random rand = new Random();

    class Gene {
        int classId, subjectId, facultyId, room;
        String day, time;
    }

    class Timetable {
        List<Gene> genes = new ArrayList<>();
        int fitness;
    }

    // FITNESS FUNCTION
    int calculateFitness(Timetable t) {

        int penalty = 0;

        Set<String> facultySet = new HashSet<>();
        Set<String> roomSet = new HashSet<>();

        Map<String, Integer> facultyLoad = new HashMap<>();

        for(Gene g : t.genes){

            String fKey = g.facultyId + "_" + g.day + "_" + g.time;
            String rKey = g.room + "_" + g.day + "_" + g.time;

            // Faculty clash
            if(facultySet.contains(fKey)) penalty += 20;
            else facultySet.add(fKey);

            // Room clash
            if(roomSet.contains(rKey)) penalty += 20;
            else roomSet.add(rKey);

            // Faculty overload
            String loadKey = g.facultyId + "_" + g.day;
            facultyLoad.put(loadKey, facultyLoad.getOrDefault(loadKey,0)+1);

            if(facultyLoad.get(loadKey) > 5) penalty += 10;
        }

        return 1000 - penalty;
    }

    // CREATE RANDOM TIMETABLE
    Timetable generateRandom(List<Integer> classes, Map<Integer,Integer> subFacMap) {

        Timetable t = new Timetable();
        List<Integer> subjects = new ArrayList<>(subFacMap.keySet());

        for(int classId : classes){
            for(String d : days){
                for(String tm : times){

                    if(subjects.isEmpty()) continue;

                    Gene g = new Gene();

                    int subjectId = subjects.get(rand.nextInt(subjects.size()));
                    int facultyId = subFacMap.get(subjectId);

                    if(facultyId <= 0) continue;

                    g.classId = classId;
                    g.subjectId = subjectId;
                    g.facultyId = facultyId;
                    g.day = d;
                    g.time = tm;
                    g.room = 101 + rand.nextInt(5);

                    t.genes.add(g);
                }
            }
        }

        t.fitness = calculateFitness(t);
        return t;
    }

    // CROSSOVER
    Timetable crossover(Timetable p1, Timetable p2){

        Timetable child = new Timetable();

        for(int i=0; i<p1.genes.size(); i++){
            if(rand.nextBoolean())
                child.genes.add(p1.genes.get(i));
            else
                child.genes.add(p2.genes.get(i));
        }

        child.fitness = calculateFitness(child);
        return child;
    }

    // MUTATION
    void mutate(Timetable t, Map<Integer,Integer> subFacMap){

        if(t.genes.isEmpty()) return;

        int index = rand.nextInt(t.genes.size());

        List<Integer> subjects = new ArrayList<>(subFacMap.keySet());
        if(subjects.isEmpty()) return;

        int newSub = subjects.get(rand.nextInt(subjects.size()));

        Gene g = t.genes.get(index);

        int facultyId = subFacMap.get(newSub);

        if(facultyId <= 0) return;

        g.subjectId = newSub;
        g.facultyId = facultyId;
        g.room = 101 + rand.nextInt(5);
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        Connection con = null;

        try {

            Class.forName("com.mysql.cj.jdbc.Driver");

            con = DriverManager.getConnection(
                "jdbc:mysql://localhost:3306/timetable_db","root","2772006");

            // CLEAR OLD TIMETABLE
            Statement clear = con.createStatement();
            clear.executeUpdate("DELETE FROM timetable");

            // LOAD DATA
            List<Integer> classes = new ArrayList<>();
            Map<Integer,Integer> subFacMap = new HashMap<>();

            Statement st = con.createStatement();

            // LOAD CLASSES
            ResultSet rs1 = st.executeQuery("SELECT class_id FROM class");
            while(rs1.next()) {
                classes.add(rs1.getInt(1));
            }

            rs1.close();

            // LOAD SUBJECT + FACULTY
            ResultSet rs2 = st.executeQuery("SELECT subject_id, faculty_id FROM subject");

            while(rs2.next()) {

                int subjectId = rs2.getInt("subject_id");
                int facultyId = rs2.getInt("faculty_id");

                if(rs2.wasNull() || facultyId <= 0){
                    continue;
                }

                subFacMap.put(subjectId, facultyId);
            }

            rs2.close();
            st.close();

            // VALIDATION
            if(subFacMap.isEmpty()){
                throw new Exception("No valid subject-faculty mapping found!");
            }

            // INITIAL POPULATION
            List<Timetable> population = new ArrayList<>();

            for(int i=0; i<20; i++){
                population.add(generateRandom(classes, subFacMap));
            }

            // GENERATIONS
            for(int gen=0; gen<50; gen++){

                population.sort((a,b)->b.fitness - a.fitness);

                List<Timetable> newPop = new ArrayList<>();

                // ELITE SELECTION
                for(int i=0; i<5; i++){
                    newPop.add(population.get(i));
                }

                // CROSSOVER + MUTATION
                while(newPop.size() < 20){

                    Timetable p1 = population.get(rand.nextInt(10));
                    Timetable p2 = population.get(rand.nextInt(10));

                    Timetable child = crossover(p1,p2);

                    if(rand.nextDouble() < 0.2){
                        mutate(child, subFacMap);
                    }

                    newPop.add(child);
                }

                population = newPop;
            }

            // BEST TIMETABLE
            population.sort((a,b)->b.fitness - a.fitness);
            Timetable best = population.get(0);

            // SAVE TO DATABASE
            PreparedStatement ps = con.prepareStatement(
                "INSERT INTO timetable(class_id,subject_id,faculty_id,day,room_no,time_slot) VALUES (?,?,?,?,?,?)");

            for(Gene g : best.genes){

                if(g.facultyId <= 0) continue;

                ps.setInt(1, g.classId);
                ps.setInt(2, g.subjectId);
                ps.setInt(3, g.facultyId);
                ps.setString(4, g.day);
                ps.setInt(5, g.room);
                ps.setString(6, g.time);

                ps.executeUpdate();
            }

            ps.close();
            con.close();

            // REDIRECT WITH SUCCESS MESSAGE
            response.sendRedirect("viewTimetable.jsp?msg=AI Timetable Generated Successfully");
            return;

        } catch(Exception e){
            e.printStackTrace();

            if(con != null){
                try { con.close(); } catch(Exception ex){}
            }

            response.sendRedirect("viewTimetable.jsp?msg=Error: " + e.getMessage());
        }
    }
}