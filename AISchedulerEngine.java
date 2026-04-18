package com.timetable;

import java.sql.*;
import java.util.*;

public class AISchedulerEngine {

    Connection con;

    public AISchedulerEngine(Connection con) {
        this.con = con;
    }

    // ==============================
    // MAIN AI GENERATE FUNCTION
    // ==============================
    public void generateTimetable() throws Exception {

        clearOldTimetable();

        List<Integer> classes = getClasses();
        List<Subject> subjects = getSubjects();
        List<Integer> faculties = getFaculties();

        String[] days = {"Mon", "Tue", "Wed", "Thu", "Fri"};
        String[] slots = {"9-10", "10-11", "11-12", "1-2", "2-3"};

        Map<Integer, Integer> facultyLoad = new HashMap<>();

        for (int classId : classes) {

            for (String day : days) {
                for (String slot : slots) {

                    Assignment best = findBestAssignment(
                            classId,
                            day,
                            slot,
                            subjects,
                            faculties,
                            facultyLoad
                    );

                    if (best != null) {
                        insertTimetable(best);
                        facultyLoad.put(
                                best.facultyId,
                                facultyLoad.getOrDefault(best.facultyId, 0) + 1
                        );
                    }
                }
            }
        }
    }

    // ==============================
    // AI CORE DECISION ENGINE
    // ==============================
    private Assignment findBestAssignment(
            int classId,
            String day,
            String slot,
            List<Subject> subjects,
            List<Integer> faculties,
            Map<Integer, Integer> facultyLoad
    ) throws Exception {

        Assignment best = null;
        int bestScore = -1;

        for (Subject sub : subjects) {

            for (int facultyId : faculties) {

                int room = getRandomRoom();

                if (hasConflict(classId, facultyId, room, day, slot)) {
                    continue;
                }

                int score = calculateScore(facultyId, facultyLoad);

                if (score > bestScore) {
                    bestScore = score;

                    best = new Assignment();
                    best.classId = classId;
                    best.subjectId = sub.id;
                    best.facultyId = facultyId;
                    best.day = day;
                    best.slot = slot;
                    best.room = room;
                }
            }
        }

        return best;
    }

    // ==============================
    // AI SCORING SYSTEM
    // ==============================
    private int calculateScore(int facultyId, Map<Integer, Integer> load) {

        int currentLoad = load.getOrDefault(facultyId, 0);

        // LOWER LOAD = HIGHER PRIORITY (BALANCING AI)
        return 100 - (currentLoad * 10);
    }

    // ==============================
    // CONFLICT CHECK ENGINE
    // ==============================
    private boolean hasConflict(int classId, int facultyId, int room,
                                 String day, String slot) throws Exception {

        String sql =
                "SELECT 1 FROM timetable " +
                "WHERE day=? AND time_slot=? " +
                "AND (faculty_id=? OR room_no=? OR class_id=?)";

        PreparedStatement ps = con.prepareStatement(sql);
        ps.setString(1, day);
        ps.setString(2, slot);
        ps.setInt(3, facultyId);
        ps.setInt(4, room);
        ps.setInt(5, classId);

        ResultSet rs = ps.executeQuery();
        return rs.next();
    }

    // ==============================
    // INSERT INTO DB
    // ==============================
    private void insertTimetable(Assignment a) throws Exception {

        String sql =
                "INSERT INTO timetable " +
                "(class_id, subject_id, faculty_id, day, room_no, time_slot) " +
                "VALUES (?, ?, ?, ?, ?, ?)";

        PreparedStatement ps = con.prepareStatement(sql);
        ps.setInt(1, a.classId);
        ps.setInt(2, a.subjectId);
        ps.setInt(3, a.facultyId);
        ps.setString(4, a.day);
        ps.setInt(5, a.room);
        ps.setString(6, a.slot);

        ps.executeUpdate();
    }

    // ==============================
    // HELPERS
    // ==============================
    private List<Integer> getClasses() throws Exception {
        List<Integer> list = new ArrayList<>();
        Statement st = con.createStatement();
        ResultSet rs = st.executeQuery("SELECT class_id FROM class");

        while (rs.next()) {
            list.add(rs.getInt(1));
        }
        return list;
    }

    private List<Subject> getSubjects() throws Exception {
        List<Subject> list = new ArrayList<>();
        Statement st = con.createStatement();
        ResultSet rs = st.executeQuery("SELECT subject_id FROM subject");

        while (rs.next()) {
            list.add(new Subject(rs.getInt(1)));
        }
        return list;
    }

    private List<Integer> getFaculties() throws Exception {
        List<Integer> list = new ArrayList<>();
        Statement st = con.createStatement();
        ResultSet rs = st.executeQuery("SELECT faculty_id FROM faculty");

        while (rs.next()) {
            list.add(rs.getInt(1));
        }
        return list;
    }

    private int getRandomRoom() {
        return 101 + new Random().nextInt(5);
    }

    private void clearOldTimetable() throws Exception {
        Statement st = con.createStatement();
        st.executeUpdate("DELETE FROM timetable");
    }

    // ==============================
    // DATA MODELS
    // ==============================
    class Subject {
        int id;
        Subject(int id) { this.id = id; }
    }

    class Assignment {
        int classId;
        int subjectId;
        int facultyId;
        String day;
        String slot;
        int room;
    }
}