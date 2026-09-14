<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="com.finding.util.DBUtil" %>
<%@ page import="com.finding.util.SecurityUtil" %>
<%
    response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");

    // Session check
    String sessionUser = (String) session.getAttribute("user");
    if (sessionUser == null) {
        response.sendRedirect("index.html?error=session_expired");
        return;
    }

    // Get parameters with null safety
    String userParam = request.getParameter("user");
    if (userParam == null || userParam.trim().isEmpty()) userParam = sessionUser;
    userParam = userParam.trim();

    // Only allow user to edit own profile unless admin (simple check)
    if (!sessionUser.equals(userParam)) {
%>
<script>alert("You can only edit your own profile"); window.open("stu.html","_self");</script>
<%
        return;
    }

    String age = request.getParameter("age");
    String mnum = request.getParameter("mnum");
    String fname = request.getParameter("fname");
    String mname = request.getParameter("mname");
    String addr = request.getParameter("addr");
    String cid = request.getParameter("cid");
    String uid = request.getParameter("uid");
    String brch = request.getParameter("brch");
    String sem = request.getParameter("sem");
    String b10th = request.getParameter("10thb");
    String p10th = request.getParameter("10thp");
    String b12th = request.getParameter("12thb");
    String p12th = request.getParameter("12thp");
    String t1 = request.getParameter("t1");
    String c1 = request.getParameter("c1");
    String ds1 = request.getParameter("ds1");
    String de1 = request.getParameter("de1");
    String t2 = request.getParameter("t2");
    String c2 = request.getParameter("c2");
    String ds2 = request.getParameter("ds2");
    String de2 = request.getParameter("de2");
    String jid = request.getParameter("jid");
    String ja = request.getParameter("ja");
    String jt = request.getParameter("jt");
    String js = request.getParameter("js");

    // Basic validation
    if (cid == null || cid.trim().isEmpty() || brch == null || brch.trim().isEmpty()) {
%>
<script>alert("College and Branch are required"); window.history.back();</script>
<%
        return;
    }

    // Sanitize inputs
    age = age != null ? SecurityUtil.sanitizeSearch(age) : "";
    mnum = mnum != null ? SecurityUtil.sanitizeSearch(mnum) : "";
    fname = fname != null ? SecurityUtil.escapeHtml(fname.trim()) : "";
    mname = mname != null ? SecurityUtil.escapeHtml(mname.trim()) : "";
    addr = addr != null ? SecurityUtil.escapeHtml(addr.trim()) : "";
    cid = SecurityUtil.escapeHtml(cid.trim());
    uid = uid != null ? SecurityUtil.escapeHtml(uid.trim()) : "";
    brch = SecurityUtil.escapeHtml(brch.trim());
    sem = sem != null ? SecurityUtil.sanitizeSearch(sem) : "";
    b10th = b10th != null ? SecurityUtil.escapeHtml(b10th.trim()) : "";
    p10th = p10th != null ? SecurityUtil.sanitizeSearch(p10th) : "";
    b12th = b12th != null ? SecurityUtil.escapeHtml(b12th.trim()) : "";
    p12th = p12th != null ? SecurityUtil.sanitizeSearch(p12th) : "";
    t1 = t1 != null ? SecurityUtil.escapeHtml(t1.trim()) : "";
    c1 = c1 != null ? SecurityUtil.escapeHtml(c1.trim()) : "";
    ds1 = ds1 != null ? SecurityUtil.sanitizeSearch(ds1) : "";
    de1 = de1 != null ? SecurityUtil.sanitizeSearch(de1) : "";
    t2 = t2 != null ? SecurityUtil.escapeHtml(t2.trim()) : "";
    c2 = c2 != null ? SecurityUtil.escapeHtml(c2.trim()) : "";
    ds2 = ds2 != null ? SecurityUtil.sanitizeSearch(ds2) : "";
    de2 = de2 != null ? SecurityUtil.sanitizeSearch(de2) : "";
    jid = jid != null ? SecurityUtil.escapeHtml(jid.trim()) : "";
    ja = ja != null ? SecurityUtil.escapeHtml(ja.trim()) : "";
    jt = jt != null ? SecurityUtil.escapeHtml(jt.trim()) : "";
    js = js != null ? SecurityUtil.sanitizeSearch(js) : "";

    Connection con = null;
    PreparedStatement ps = null;

    try {
        con = DBUtil.getConnection();

        // Check if exists - for upsert logic
        boolean exists = false;
        try (PreparedStatement checkPs = con.prepareStatement("SELECT user FROM student WHERE user = ?")) {
            checkPs.setString(1, userParam);
            try (ResultSet rs = checkPs.executeQuery()) {
                exists = rs.next();
            }
        }

        if (exists) {
            // Update
            String sql = "UPDATE student SET age=?, mnum=?, fname=?, mname=?, addr=?, cid=?, uid=?, brch=?, sem=?, `10thb`=?, `10thp`=?, `12thb`=?, `12thp`=?, t1=?, c1=?, ds1=?, de1=?, t2=?, c2=?, ds2=?, de2=?, jid=?, ja=?, jt=?, js=? WHERE user=?";
            ps = con.prepareStatement(sql);
            ps.setString(1, age);
            ps.setString(2, mnum);
            ps.setString(3, fname);
            ps.setString(4, mname);
            ps.setString(5, addr);
            ps.setString(6, cid);
            ps.setString(7, uid);
            ps.setString(8, brch);
            ps.setString(9, sem);
            ps.setString(10, b10th);
            ps.setString(11, p10th);
            ps.setString(12, b12th);
            ps.setString(13, p12th);
            ps.setString(14, t1);
            ps.setString(15, c1);
            ps.setString(16, ds1);
            ps.setString(17, de1);
            ps.setString(18, t2);
            ps.setString(19, c2);
            ps.setString(20, ds2);
            ps.setString(21, de2);
            ps.setString(22, jid);
            ps.setString(23, ja);
            ps.setString(24, jt);
            ps.setString(25, js);
            ps.setString(26, userParam);
        } else {
            // Insert
            String sql = "INSERT INTO student (user, age, mnum, fname, mname, addr, cid, uid, brch, sem, `10thb`, `10thp`, `12thb`, `12thp`, t1, c1, ds1, de1, t2, c2, ds2, de2, jid, ja, jt, js) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
            ps = con.prepareStatement(sql);
            ps.setString(1, userParam);
            ps.setString(2, age);
            ps.setString(3, mnum);
            ps.setString(4, fname);
            ps.setString(5, mname);
            ps.setString(6, addr);
            ps.setString(7, cid);
            ps.setString(8, uid);
            ps.setString(9, brch);
            ps.setString(10, sem);
            ps.setString(11, b10th);
            ps.setString(12, p10th);
            ps.setString(13, b12th);
            ps.setString(14, p12th);
            ps.setString(15, t1);
            ps.setString(16, c1);
            ps.setString(17, ds1);
            ps.setString(18, de1);
            ps.setString(19, t2);
            ps.setString(20, c2);
            ps.setString(21, ds2);
            ps.setString(22, de2);
            ps.setString(23, jid);
            ps.setString(24, ja);
            ps.setString(25, jt);
            ps.setString(26, js);
        }

        int rows = ps.executeUpdate();
        if (rows > 0) {
%>
<script>
  alert("Profile saved successfully!");
  window.open("stu.html","_self");
</script>
<%
        } else {
%>
<script>alert("Failed to save profile"); window.history.back();</script>
<%
        }
    } catch (SQLException e) {
        System.err.println("Student reg error: " + e.getMessage());
        e.printStackTrace();
%>
<script>alert("Database error: <%= SecurityUtil.escapeHtml(e.getMessage()) %>"); window.history.back();</script>
<%
    } finally {
        try { if (ps != null) ps.close(); } catch (Exception ignored) {}
        try { if (con != null) con.close(); } catch (Exception ignored) {}
    }
%>
