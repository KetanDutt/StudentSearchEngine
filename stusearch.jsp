<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*"%>
<%@ page import="com.finding.util.DBUtil"%>
<%@ page import="com.finding.util.SecurityUtil"%>
<%
    String sessionUser = (String) session.getAttribute("user");
    if (sessionUser == null) {
        response.sendRedirect("index.html?error=session_expired");
        return;
    }

    String searchRaw = request.getParameter("search");
    String search = SecurityUtil.sanitizeSearch(searchRaw != null ? searchRaw : "");
    if (search.isEmpty()) {
        search = "";
    }

    // Pagination
    int pageNum = 1;
    int pageSize = 20;
    try {
        String p = request.getParameter("page");
        if (p != null) pageNum = Math.max(1, Integer.parseInt(p));
    } catch (Exception ignored) {}
    int offset = (pageNum - 1) * pageSize;

    // For LIKE queries, we need to escape % and _
    String likePattern = "%" + search.replace("%", "\\%").replace("_", "\\_") + "%";
%>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>FindinG - Student Search Results</title>
<link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">
<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
<link rel="stylesheet" href="css/style.css">
</head>
<body>
<nav class="navbar navbar-expand-lg navbar-dark">
  <div class="container-fluid px-4">
    <a class="navbar-brand" href="index.html">FindinG</a>
    <div class="navbar-nav ms-auto">
      <a class="nav-link" href="hr.html">Dashboard</a>
      <a class="nav-link" href="logout.jsp">Logout</a>
    </div>
  </div>
</nav>

<div class="container py-4">
  <div class="jumbotron2 card-modern">
    <div class="d-flex justify-content-between align-items-center mb-4 flex-wrap gap-3">
      <div>
        <h2 class="h3 fw-bold mb-1">🎓 Student Search Results</h2>
        <p class="text-muted mb-0 small">Showing results for: <strong><%= SecurityUtil.escapeHtml(search) %></strong> | Page <%= pageNum %></p>
      </div>
      <form action="stusearch.jsp" method="post" class="d-flex gap-2">
        <input type="text" name="search" class="form-control" placeholder="New search..." value="<%= SecurityUtil.escapeHtml(search) %>">
        <button class="btn btn-primary">Search</button>
      </form>
    </div>

    <div class="table-responsive">
      <table class="table table-hover align-middle">
        <thead>
          <tr>
            <th>User</th>
            <th>Mobile</th>
            <th>College</th>
            <th>University</th>
            <th>Branch</th>
            <th>Major Tech</th>
            <th>Company</th>
            <th>Minor Tech</th>
            <th>Company</th>
            <th>Desired Role</th>
            <th>Location</th>
            <th>Salary</th>
          </tr>
        </thead>
        <tbody>
<%
    Connection con = null;
    PreparedStatement ps = null;
    ResultSet rs = null;
    int count = 0;
    try {
        con = DBUtil.getConnection();
        // Secure search with PreparedStatement - prevents SQL injection
        // Using parameterized LIKE queries
        String sql = "SELECT user, mnum, cid, uid, brch, t1, c1, t2, c2, jid, ja, js " +
                     "FROM student WHERE " +
                     "user LIKE ? OR age LIKE ? OR mnum LIKE ? OR fname LIKE ? OR mname LIKE ? OR addr LIKE ? OR " +
                     "cid LIKE ? OR uid LIKE ? OR brch LIKE ? OR sem LIKE ? OR `10thb` LIKE ? OR `10thp` LIKE ? OR `12thb` LIKE ? OR `12thp` LIKE ? OR " +
                     "t1 LIKE ? OR t2 LIKE ? OR c1 LIKE ? OR c2 LIKE ? OR ds1 LIKE ? OR ds2 LIKE ? OR de1 LIKE ? OR de2 LIKE ? OR " +
                     "jid LIKE ? OR ja LIKE ? OR jt LIKE ? OR js LIKE ? " +
                     "ORDER BY user LIMIT ? OFFSET ?";

        ps = con.prepareStatement(sql);
        int idx = 1;
        for (int i = 0; i < 26; i++) {
            ps.setString(idx++, likePattern);
        }
        ps.setInt(idx++, pageSize);
        ps.setInt(idx++, offset);

        rs = ps.executeQuery();
        while (rs.next()) {
            count++;
%>
          <tr>
            <td><span class="badge bg-primary"><%= SecurityUtil.escapeHtml(rs.getString("user")) %></span></td>
            <td><%= SecurityUtil.escapeHtml(rs.getString("mnum")) %></td>
            <td><%= SecurityUtil.escapeHtml(rs.getString("cid")) %></td>
            <td><%= SecurityUtil.escapeHtml(rs.getString("uid")) %></td>
            <td><span class="badge bg-secondary"><%= SecurityUtil.escapeHtml(rs.getString("brch")) %></span></td>
            <td><%= SecurityUtil.escapeHtml(rs.getString("t1")) %></td>
            <td class="small text-muted"><%= SecurityUtil.escapeHtml(rs.getString("c1")) %></td>
            <td><%= SecurityUtil.escapeHtml(rs.getString("t2")) %></td>
            <td class="small text-muted"><%= SecurityUtil.escapeHtml(rs.getString("c2")) %></td>
            <td class="fw-bold"><%= SecurityUtil.escapeHtml(rs.getString("jid")) %></td>
            <td><%= SecurityUtil.escapeHtml(rs.getString("ja")) %></td>
            <td><span class="badge bg-success"><%= SecurityUtil.escapeHtml(rs.getString("js")) %></span></td>
          </tr>
<%
        }
        if (count == 0) {
%>
          <tr><td colspan="12" class="text-center py-5 text-muted">No students found for "<%= SecurityUtil.escapeHtml(search) %>". Try different keywords.</td></tr>
<%
        }
    } catch (SQLException e) {
        System.err.println("Search error: " + e.getMessage());
%>
          <tr><td colspan="12" class="text-center text-danger">Database error: <%= SecurityUtil.escapeHtml(e.getMessage()) %></td></tr>
<%
    } finally {
        try { if (rs != null) rs.close(); } catch (Exception ignored) {}
        try { if (ps != null) ps.close(); } catch (Exception ignored) {}
        try { if (con != null) con.close(); } catch (Exception ignored) {}
    }
%>
        </tbody>
      </table>
    </div>

    <div class="d-flex justify-content-between align-items-center mt-4">
      <div class="small text-muted">Found <%= count %> results on this page</div>
      <div class="btn-group">
        <% if (pageNum > 1) { %>
          <a href="stusearch.jsp?search=<%= java.net.URLEncoder.encode(search, "UTF-8") %>&page=<%= pageNum-1 %>" class="btn btn-outline-secondary btn-sm">← Previous</a>
        <% } %>
        <span class="btn btn-secondary btn-sm disabled">Page <%= pageNum %></span>
        <% if (count == pageSize) { %>
          <a href="stusearch.jsp?search=<%= java.net.URLEncoder.encode(search, "UTF-8") %>&page=<%= pageNum+1 %>" class="btn btn-outline-secondary btn-sm">Next →</a>
        <% } %>
      </div>
    </div>

    <div class="mt-4 p-3 bg-light rounded">
      <h6 class="small fw-bold">💡 Search Tips</h6>
      <p class="small text-muted mb-0">Search across: username, age, mobile, names, address, college, university, branch, semester, boards, percentages, technologies, companies, duration, job role, location, type, salary. Results are paginated for performance.</p>
    </div>
  </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
