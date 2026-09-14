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
    int pageNum = 1;
    int pageSize = 20;
    try {
        String p = request.getParameter("page");
        if (p != null) pageNum = Math.max(1, Integer.parseInt(p));
    } catch (Exception ignored) {}
    int offset = (pageNum - 1) * pageSize;
    String likePattern = "%" + search.replace("%", "\\%").replace("_", "\\_") + "%";
%>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>FindinG - Company Search Results</title>
<link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">
<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
<link rel="stylesheet" href="css/style.css">
</head>
<body>
<nav class="navbar navbar-expand-lg navbar-dark">
  <div class="container-fluid px-4">
    <a class="navbar-brand" href="index.html">FindinG</a>
    <div class="navbar-nav ms-auto">
      <a class="nav-link" href="stu.html">Dashboard</a>
      <a class="nav-link" href="logout.jsp">Logout</a>
    </div>
  </div>
</nav>

<div class="container py-4">
  <div class="jumbotron2 card-modern">
    <div class="d-flex justify-content-between align-items-center mb-4 flex-wrap gap-3">
      <div>
        <h2 class="h3 fw-bold mb-1">🏢 Company Search Results</h2>
        <p class="text-muted mb-0 small">Showing results for: <strong><%= SecurityUtil.escapeHtml(search) %></strong> | Page <%= pageNum %></p>
      </div>
      <form action="hrsearch.jsp" method="post" class="d-flex gap-2">
        <input type="text" name="search" class="form-control" placeholder="New search..." value="<%= SecurityUtil.escapeHtml(search) %>">
        <button class="btn btn-primary">Search</button>
      </form>
    </div>

    <div class="table-responsive">
      <table class="table table-hover align-middle">
        <thead>
          <tr>
            <th>User</th>
            <th>Company</th>
            <th>Employees</th>
            <th>Max Salary</th>
            <th>Major Product</th>
            <th>Client</th>
            <th>Minor Product</th>
            <th>Client</th>
            <th>Job Role</th>
            <th>Type</th>
            <th>Salary</th>
            <th>Job Role 2</th>
            <th>Type 2</th>
            <th>Salary 2</th>
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
        String sql = "SELECT user, cid, emp, hsal, t1, c1, t2, c2, jid, jt, js, jid2, jt2, js2 FROM company WHERE " +
                     "user LIKE ? OR cid LIKE ? OR auth LIKE ? OR yr LIKE ? OR emp LIKE ? OR hsal LIKE ? OR brch LIKE ? OR addr LIKE ? OR " +
                     "t1 LIKE ? OR t2 LIKE ? OR c1 LIKE ? OR c2 LIKE ? OR a1 LIKE ? OR a2 LIKE ? OR y1 LIKE ? OR y2 LIKE ? OR " +
                     "jid LIKE ? OR ja LIKE ? OR jt LIKE ? OR js LIKE ? OR jid2 LIKE ? OR ja2 LIKE ? OR jt2 LIKE ? OR js2 LIKE ? " +
                     "ORDER BY cid LIMIT ? OFFSET ?";
        ps = con.prepareStatement(sql);
        int idx = 1;
        for (int i = 0; i < 24; i++) ps.setString(idx++, likePattern);
        ps.setInt(idx++, pageSize);
        ps.setInt(idx++, offset);
        rs = ps.executeQuery();
        while (rs.next()) {
            count++;
%>
          <tr>
            <td><span class="badge bg-primary"><%= SecurityUtil.escapeHtml(rs.getString("user")) %></span></td>
            <td class="fw-bold"><%= SecurityUtil.escapeHtml(rs.getString("cid")) %></td>
            <td><%= SecurityUtil.escapeHtml(rs.getString("emp")) %></td>
            <td><span class="badge bg-success"><%= SecurityUtil.escapeHtml(rs.getString("hsal")) %></span></td>
            <td><%= SecurityUtil.escapeHtml(rs.getString("t1")) %></td>
            <td class="small text-muted"><%= SecurityUtil.escapeHtml(rs.getString("c1")) %></td>
            <td><%= SecurityUtil.escapeHtml(rs.getString("t2")) %></td>
            <td class="small text-muted"><%= SecurityUtil.escapeHtml(rs.getString("c2")) %></td>
            <td class="fw-bold"><%= SecurityUtil.escapeHtml(rs.getString("jid")) %></td>
            <td><span class="badge bg-secondary"><%= SecurityUtil.escapeHtml(rs.getString("jt")) %></span></td>
            <td><%= SecurityUtil.escapeHtml(rs.getString("js")) %></td>
            <td><%= SecurityUtil.escapeHtml(rs.getString("jid2")) %></td>
            <td><span class="badge bg-secondary"><%= SecurityUtil.escapeHtml(rs.getString("jt2")) %></span></td>
            <td><%= SecurityUtil.escapeHtml(rs.getString("js2")) %></td>
          </tr>
<%
        }
        if (count == 0) {
%>
          <tr><td colspan="14" class="text-center py-5 text-muted">No companies found for "<%= SecurityUtil.escapeHtml(search) %>". Try different keywords like technology, location, or job role.</td></tr>
<%
        }
    } catch (SQLException e) {
%>
          <tr><td colspan="14" class="text-center text-danger">DB error: <%= SecurityUtil.escapeHtml(e.getMessage()) %></td></tr>
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
      <div class="small text-muted">Found <%= count %> results</div>
      <div class="btn-group">
        <% if (pageNum > 1) { %>
          <a href="hrsearch.jsp?search=<%= java.net.URLEncoder.encode(search, "UTF-8") %>&page=<%= pageNum-1 %>" class="btn btn-outline-secondary btn-sm">← Previous</a>
        <% } %>
        <span class="btn btn-secondary btn-sm disabled">Page <%= pageNum %></span>
        <% if (count == pageSize) { %>
          <a href="hrsearch.jsp?search=<%= java.net.URLEncoder.encode(search, "UTF-8") %>&page=<%= pageNum+1 %>" class="btn btn-outline-secondary btn-sm">Next →</a>
        <% } %>
      </div>
    </div>
  </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
