<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="com.finding.util.DBUtil" %>
<%@ page import="com.finding.util.SecurityUtil" %>
<%
    response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");

    String sessionUser = (String) session.getAttribute("user");
    if (sessionUser == null) {
        response.sendRedirect("index.html?error=session_expired");
        return;
    }

    String userParam = request.getParameter("user");
    if (userParam == null || userParam.trim().isEmpty()) userParam = sessionUser;
    userParam = userParam.trim();

    if (!sessionUser.equals(userParam)) {
%>
<script>alert("You can only edit your own profile"); window.open("hr.html","_self");</script>
<%
        return;
    }

    String cid = request.getParameter("cid");
    String auth = request.getParameter("auth");
    String yr = request.getParameter("yr");
    String emp = request.getParameter("emp");
    String hsal = request.getParameter("hsal");
    String brch = request.getParameter("brch");
    String addr = request.getParameter("addr");
    String t1 = request.getParameter("t1");
    String c1 = request.getParameter("c1");
    String y1 = request.getParameter("y1");
    String a1 = request.getParameter("a1");
    String t2 = request.getParameter("t2");
    String c2 = request.getParameter("c2");
    String y2 = request.getParameter("y2");
    String a2 = request.getParameter("a2");
    String jid = request.getParameter("jid");
    String ja = request.getParameter("ja");
    String jt = request.getParameter("jt");
    String js = request.getParameter("js");
    String jid2 = request.getParameter("jid2");
    String ja2 = request.getParameter("ja2");
    String jt2 = request.getParameter("jt2");
    String js2 = request.getParameter("js2");

    if (cid == null || cid.trim().isEmpty()) {
%>
<script>alert("Company name required"); window.history.back();</script>
<%
        return;
    }

    // Sanitize
    cid = SecurityUtil.escapeHtml(cid.trim());
    auth = auth != null ? SecurityUtil.escapeHtml(auth.trim()) : "";
    yr = yr != null ? SecurityUtil.sanitizeSearch(yr) : "";
    emp = emp != null ? SecurityUtil.sanitizeSearch(emp) : "";
    hsal = hsal != null ? SecurityUtil.sanitizeSearch(hsal) : "";
    brch = brch != null ? SecurityUtil.sanitizeSearch(brch) : "";
    addr = addr != null ? SecurityUtil.escapeHtml(addr.trim()) : "";
    t1 = t1 != null ? SecurityUtil.escapeHtml(t1.trim()) : "";
    c1 = c1 != null ? SecurityUtil.escapeHtml(c1.trim()) : "";
    y1 = y1 != null ? SecurityUtil.sanitizeSearch(y1) : "";
    a1 = a1 != null ? SecurityUtil.sanitizeSearch(a1) : "";
    t2 = t2 != null ? SecurityUtil.escapeHtml(t2.trim()) : "";
    c2 = c2 != null ? SecurityUtil.escapeHtml(c2.trim()) : "";
    y2 = y2 != null ? SecurityUtil.sanitizeSearch(y2) : "";
    a2 = a2 != null ? SecurityUtil.sanitizeSearch(a2) : "";
    jid = jid != null ? SecurityUtil.escapeHtml(jid.trim()) : "";
    ja = ja != null ? SecurityUtil.escapeHtml(ja.trim()) : "";
    jt = jt != null ? SecurityUtil.escapeHtml(jt.trim()) : "";
    js = js != null ? SecurityUtil.sanitizeSearch(js) : "";
    jid2 = jid2 != null ? SecurityUtil.escapeHtml(jid2.trim()) : "";
    ja2 = ja2 != null ? SecurityUtil.escapeHtml(ja2.trim()) : "";
    jt2 = jt2 != null ? SecurityUtil.escapeHtml(jt2.trim()) : "";
    js2 = js2 != null ? SecurityUtil.sanitizeSearch(js2) : "";

    Connection con = null;
    PreparedStatement ps = null;

    try {
        con = DBUtil.getConnection();

        boolean exists = false;
        try (PreparedStatement checkPs = con.prepareStatement("SELECT user FROM company WHERE user = ?")) {
            checkPs.setString(1, userParam);
            try (ResultSet rs = checkPs.executeQuery()) {
                exists = rs.next();
            }
        }

        if (exists) {
            String sql = "UPDATE company SET cid=?, auth=?, yr=?, emp=?, hsal=?, brch=?, addr=?, t1=?, c1=?, y1=?, a1=?, t2=?, c2=?, y2=?, a2=?, jid=?, ja=?, jt=?, js=?, jid2=?, ja2=?, jt2=?, js2=? WHERE user=?";
            ps = con.prepareStatement(sql);
            ps.setString(1, cid);
            ps.setString(2, auth);
            ps.setString(3, yr);
            ps.setString(4, emp);
            ps.setString(5, hsal);
            ps.setString(6, brch);
            ps.setString(7, addr);
            ps.setString(8, t1);
            ps.setString(9, c1);
            ps.setString(10, y1);
            ps.setString(11, a1);
            ps.setString(12, t2);
            ps.setString(13, c2);
            ps.setString(14, y2);
            ps.setString(15, a2);
            ps.setString(16, jid);
            ps.setString(17, ja);
            ps.setString(18, jt);
            ps.setString(19, js);
            ps.setString(20, jid2);
            ps.setString(21, ja2);
            ps.setString(22, jt2);
            ps.setString(23, js2);
            ps.setString(24, userParam);
        } else {
            String sql = "INSERT INTO company (user, cid, auth, yr, emp, hsal, brch, addr, t1, c1, y1, a1, t2, c2, y2, a2, jid, ja, jt, js, jid2, ja2, jt2, js2) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
            ps = con.prepareStatement(sql);
            ps.setString(1, userParam);
            ps.setString(2, cid);
            ps.setString(3, auth);
            ps.setString(4, yr);
            ps.setString(5, emp);
            ps.setString(6, hsal);
            ps.setString(7, brch);
            ps.setString(8, addr);
            ps.setString(9, t1);
            ps.setString(10, c1);
            ps.setString(11, y1);
            ps.setString(12, a1);
            ps.setString(13, t2);
            ps.setString(14, c2);
            ps.setString(15, y2);
            ps.setString(16, a2);
            ps.setString(17, jid);
            ps.setString(18, ja);
            ps.setString(19, jt);
            ps.setString(20, js);
            ps.setString(21, jid2);
            ps.setString(22, ja2);
            ps.setString(23, jt2);
            ps.setString(24, js2);
        }

        int rows = ps.executeUpdate();
        if (rows > 0) {
%>
<script>
  alert("Company profile saved!");
  window.open("hr.html","_self");
</script>
<%
        } else {
%>
<script>alert("Failed to save"); window.history.back();</script>
<%
        }
    } catch (SQLException e) {
        System.err.println("Company reg error: " + e.getMessage());
        e.printStackTrace();
%>
<script>alert("Database error: <%= SecurityUtil.escapeHtml(e.getMessage()) %>"); window.history.back();</script>
<%
    } finally {
        try { if (ps != null) ps.close(); } catch (Exception ignored) {}
        try { if (con != null) con.close(); } catch (Exception ignored) {}
    }
%>
