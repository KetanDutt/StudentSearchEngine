<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="com.finding.util.DBUtil" %>
<%@ page import="com.finding.util.SecurityUtil" %>
<%
    response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");

    String userid = request.getParameter("userid");
    String pwd = request.getParameter("pwd");
    String fname = request.getParameter("fname");
    String lname = request.getParameter("lname");
    String email = request.getParameter("email");
    String occ = request.getParameter("occ");

    // Server-side validation
    if (userid == null || pwd == null || fname == null || lname == null || email == null || occ == null) {
%>
<script>alert("All fields are required"); window.history.back();</script>
<%
        return;
    }

    userid = userid.trim();
    fname = fname.trim();
    lname = lname.trim();
    email = email.trim();
    occ = occ.trim();

    // Validate inputs
    if (!SecurityUtil.isValidUsername(userid)) {
%>
<script>alert("Invalid username. Use 3-30 alphanumeric chars and underscore only."); window.history.back();</script>
<%
        return;
    }

    if (!SecurityUtil.isStrongPassword(pwd)) {
%>
<script>alert("Weak password. Must be 8+ chars with uppercase, lowercase and number."); window.history.back();</script>
<%
        return;
    }

    if (!SecurityUtil.isValidEmail(email)) {
%>
<script>alert("Invalid email format."); window.history.back();</script>
<%
        return;
    }

    if (!("stu".equals(occ) || "hr".equals(occ))) {
%>
<script>alert("Invalid occupation."); window.history.back();</script>
<%
        return;
    }

    if (fname.isEmpty() || lname.isEmpty() || fname.length() > 100 || lname.length() > 100) {
%>
<script>alert("Invalid first/last name."); window.history.back();</script>
<%
        return;
    }

    Connection con = null;
    PreparedStatement psCheck = null;
    PreparedStatement psInsert = null;
    ResultSet rs = null;

    try {
        con = DBUtil.getConnection();

        // Check duplicate username
        psCheck = con.prepareStatement("SELECT user FROM user WHERE user = ?");
        psCheck.setString(1, userid);
        rs = psCheck.executeQuery();
        if (rs.next()) {
%>
<script>alert("Username already exists. Choose different username."); window.open("register.html","_self");</script>
<%
            return;
        }
        rs.close();
        psCheck.close();

        // Check duplicate email
        psCheck = con.prepareStatement("SELECT email FROM user WHERE email = ?");
        psCheck.setString(1, email);
        rs = psCheck.executeQuery();
        if (rs.next()) {
%>
<script>alert("Email already registered."); window.open("register.html","_self");</script>
<%
            return;
        }
        rs.close();
        psCheck.close();

        // Hash password securely
        String hashedPwd = SecurityUtil.hashPassword(pwd);

        // Secure insert with PreparedStatement
        String sql = "INSERT INTO user (user, pwd, fname, lname, email, occ) VALUES (?, ?, ?, ?, ?, ?)";
        psInsert = con.prepareStatement(sql);
        psInsert.setString(1, userid);
        psInsert.setString(2, hashedPwd);
        psInsert.setString(3, SecurityUtil.escapeHtml(fname));
        psInsert.setString(4, SecurityUtil.escapeHtml(lname));
        psInsert.setString(5, email);
        psInsert.setString(6, occ);

        int rows = psInsert.executeUpdate();

        if (rows > 0) {
            // Auto-login after registration
            session.invalidate();
            session = request.getSession(true);
            session.setAttribute("user", userid);
            session.setAttribute("fname", fname);
            session.setAttribute("lname", lname);
            session.setAttribute("email", email);
            session.setAttribute("occ", occ);
%>
<script>
  alert("Registration successful! Welcome <%= SecurityUtil.escapeHtml(fname) %>.");
  window.open("<%= "stu".equals(occ) ? "stureg.html" : "hrreg.html" %>","_self");
</script>
<%
        } else {
%>
<script>alert("Registration failed. Try again."); window.open("register.html","_self");</script>
<%
        }
    } catch (SQLException e) {
        System.err.println("Registration DB error: " + e.getMessage());
        e.printStackTrace();
%>
<script>alert("Database error: <%= SecurityUtil.escapeHtml(e.getMessage()) %>"); window.open("register.html","_self");</script>
<%
    } catch (Exception e) {
        System.err.println("Registration error: " + e.getMessage());
        e.printStackTrace();
%>
<script>alert("Server error occurred."); window.open("register.html","_self");</script>
<%
    } finally {
        try { if (rs != null) rs.close(); } catch (Exception ignored) {}
        try { if (psCheck != null) psCheck.close(); } catch (Exception ignored) {}
        try { if (psInsert != null) psInsert.close(); } catch (Exception ignored) {}
        try { if (con != null) con.close(); } catch (Exception ignored) {}
    }
%>
