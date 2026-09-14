<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="com.finding.util.DBUtil" %>
<%@ page import="com.finding.util.SecurityUtil" %>
<%
    String sessionUser = (String) session.getAttribute("user");
    String occ = (String) session.getAttribute("occ");
    if (sessionUser == null) {
        response.sendRedirect("index.html?error=session_expired");
        return;
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>FindinG - My Profile</title>
<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
<link rel="stylesheet" href="css/style.css">
</head>
<body>
<nav class="navbar navbar-expand-lg navbar-dark">
  <div class="container-fluid px-4">
    <a class="navbar-brand" href="index.html">FindinG</a>
    <div class="navbar-nav ms-auto">
      <a class="nav-link" href="<%= "stu".equals(occ) ? "stu.html" : "hr.html" %>">Dashboard</a>
      <a class="nav-link" href="logout.jsp">Logout</a>
    </div>
  </div>
</nav>

<div class="container py-5">
  <div class="row justify-content-center">
    <div class="col-lg-8">
      <div class="jumbotron card-modern">
        <h2 class="fw-bold mb-4">👤 My Profile - <%= SecurityUtil.escapeHtml(sessionUser) %></h2>
        
        <div class="mb-4">
          <h5>Account Info</h5>
          <table class="table table-bordered">
            <tr><th>Username</th><td><%= SecurityUtil.escapeHtml(sessionUser) %></td></tr>
            <tr><th>First Name</th><td><%= SecurityUtil.escapeHtml((String)session.getAttribute("fname")) %></td></tr>
            <tr><th>Last Name</th><td><%= SecurityUtil.escapeHtml((String)session.getAttribute("lname")) %></td></tr>
            <tr><th>Email</th><td><%= SecurityUtil.escapeHtml((String)session.getAttribute("email")) %></td></tr>
            <tr><th>Role</th><td><span class="badge bg-primary"><%= "stu".equals(occ) ? "Student" : "Company" %></span></td></tr>
          </table>
        </div>

        <div class="mb-4">
          <h5>Detailed Profile</h5>
<%
    Connection con = null;
    PreparedStatement ps = null;
    ResultSet rs = null;
    try {
        con = DBUtil.getConnection();
        if ("stu".equals(occ)) {
            ps = con.prepareStatement("SELECT * FROM student WHERE user = ?");
            ps.setString(1, sessionUser);
            rs = ps.executeQuery();
            if (rs.next()) {
%>
          <table class="table table-striped table-bordered">
            <tr><th>College</th><td><%= SecurityUtil.escapeHtml(rs.getString("cid")) %></td></tr>
            <tr><th>University</th><td><%= SecurityUtil.escapeHtml(rs.getString("uid")) %></td></tr>
            <tr><th>Branch</th><td><%= SecurityUtil.escapeHtml(rs.getString("brch")) %></td></tr>
            <tr><th>Semester</th><td><%= SecurityUtil.escapeHtml(rs.getString("sem")) %></td></tr>
            <tr><th>Major Tech</th><td><%= SecurityUtil.escapeHtml(rs.getString("t1")) %> @ <%= SecurityUtil.escapeHtml(rs.getString("c1")) %></td></tr>
            <tr><th>Job Preference</th><td><%= SecurityUtil.escapeHtml(rs.getString("jid")) %> - <%= SecurityUtil.escapeHtml(rs.getString("ja")) %></td></tr>
          </table>
<%
            } else {
%>
          <div class="alert alert-warning">Profile not completed. <a href="stureg.html">Complete now</a></div>
<%
            }
        } else {
            ps = con.prepareStatement("SELECT * FROM company WHERE user = ?");
            ps.setString(1, sessionUser);
            rs = ps.executeQuery();
            if (rs.next()) {
%>
          <table class="table table-striped table-bordered">
            <tr><th>Company</th><td><%= SecurityUtil.escapeHtml(rs.getString("cid")) %></td></tr>
            <tr><th>Employees</th><td><%= SecurityUtil.escapeHtml(rs.getString("emp")) %></td></tr>
            <tr><th>Established</th><td><%= SecurityUtil.escapeHtml(rs.getString("yr")) %></td></tr>
            <tr><th>Major Product</th><td><%= SecurityUtil.escapeHtml(rs.getString("t1")) %></td></tr>
            <tr><th>Job Opening</th><td><%= SecurityUtil.escapeHtml(rs.getString("jid")) %> - <%= SecurityUtil.escapeHtml(rs.getString("js")) %></td></tr>
          </table>
<%
            } else {
%>
          <div class="alert alert-warning">Profile not completed. <a href="hrreg.html">Complete now</a></div>
<%
            }
        }
    } catch (Exception e) {
%>
          <div class="alert alert-danger">Error: <%= SecurityUtil.escapeHtml(e.getMessage()) %></div>
<%
    } finally {
        try { if (rs != null) rs.close(); } catch (Exception ignored) {}
        try { if (ps != null) ps.close(); } catch (Exception ignored) {}
        try { if (con != null) con.close(); } catch (Exception ignored) {}
    }
%>
        </div>

        <div class="d-flex gap-2">
          <a href="<%= "stu".equals(occ) ? "stureg.html" : "hrreg.html" %>" class="btn btn-primary">Edit Profile</a>
          <a href="<%= "stu".equals(occ) ? "stu.html" : "hr.html" %>" class="btn btn-outline-secondary">Back to Dashboard</a>
        </div>
      </div>
    </div>
  </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
