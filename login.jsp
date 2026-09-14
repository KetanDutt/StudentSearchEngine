<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="com.finding.util.DBUtil" %>
<%@ page import="com.finding.util.SecurityUtil" %>
<%
    // Prevent caching
    response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
    response.setHeader("Pragma", "no-cache");
    response.setDateHeader("Expires", 0);

    String userParam = request.getParameter("usr");
    String pwdParam = request.getParameter("pwd");

    // Input validation
    if (userParam == null || userParam.trim().isEmpty() || pwdParam == null || pwdParam.isEmpty()) {
        response.sendRedirect("index.html?error=invalid");
        return;
    }

    String username = userParam.trim();
    if (username.length() > 50) {
        response.sendRedirect("index.html?error=invalid");
        return;
    }

    // Sanitize
    username = SecurityUtil.sanitizeSearch(username);

    Connection con = null;
    PreparedStatement ps = null;
    ResultSet rs = null;

    try {
        con = DBUtil.getConnection();
        
        // Secure query with PreparedStatement - prevents SQL injection
        String sql = "SELECT user, pwd, fname, lname, email, occ FROM user WHERE user = ?";
        ps = con.prepareStatement(sql);
        ps.setString(1, username);
        rs = ps.executeQuery();

        if (rs.next()) {
            String storedPwd = rs.getString("pwd");
            String occupation = rs.getString("occ");
            
            // Secure password check with BCrypt + legacy fallback
            boolean pwdMatch = SecurityUtil.checkPassword(pwdParam, storedPwd);
            
            if (pwdMatch) {
                // Upgrade legacy plain password to BCrypt if needed
                if (!storedPwd.startsWith("$2a$") && !storedPwd.startsWith("$2b$")) {
                    try (PreparedStatement upgradePs = con.prepareStatement("UPDATE user SET pwd = ? WHERE user = ?")) {
                        upgradePs.setString(1, SecurityUtil.hashPassword(pwdParam));
                        upgradePs.setString(2, username);
                        upgradePs.executeUpdate();
                    } catch (Exception ex) {
                        // Log but don't fail login
                        System.err.println("Password upgrade failed: " + ex.getMessage());
                    }
                }

                // Secure session management
                session.invalidate();
                session = request.getSession(true);
                session.setAttribute("user", username);
                session.setAttribute("fname", rs.getString("fname"));
                session.setAttribute("lname", rs.getString("lname"));
                session.setAttribute("email", rs.getString("email"));
                session.setAttribute("occ", occupation);
                session.setAttribute("loginTime", System.currentTimeMillis());
                session.setMaxInactiveInterval(30 * 60); // 30 minutes

                // Check if profile exists
                if ("stu".equals(occupation)) {
                    try (PreparedStatement ps2 = con.prepareStatement("SELECT user FROM student WHERE user = ?")) {
                        ps2.setString(1, username);
                        try (ResultSet rs2 = ps2.executeQuery()) {
                            if (rs2.next()) {
                                response.sendRedirect("stu.html");
                            } else {
                                response.sendRedirect("stureg.html");
                            }
                        }
                    }
                } else if ("hr".equals(occupation)) {
                    try (PreparedStatement ps2 = con.prepareStatement("SELECT user FROM company WHERE user = ?")) {
                        ps2.setString(1, username);
                        try (ResultSet rs2 = ps2.executeQuery()) {
                            if (rs2.next()) {
                                response.sendRedirect("hr.html");
                            } else {
                                response.sendRedirect("hrreg.html");
                            }
                        }
                    }
                } else {
                    response.sendRedirect("index.html?error=invalid_role");
                }
                return;
            } else {
                // Wrong password
                response.sendRedirect("index.html?error=invalid");
                return;
            }
        } else {
            // User not found
            response.sendRedirect("index.html?error=invalid");
            return;
        }
    } catch (SQLException e) {
        System.err.println("Login DB error: " + e.getMessage());
        e.printStackTrace();
        response.sendRedirect("index.html?error=db_error");
        return;
    } catch (Exception e) {
        System.err.println("Login error: " + e.getMessage());
        e.printStackTrace();
        response.sendRedirect("index.html?error=server_error");
        return;
    } finally {
        try { if (rs != null) rs.close(); } catch (Exception ignored) {}
        try { if (ps != null) ps.close(); } catch (Exception ignored) {}
        try { if (con != null) con.close(); } catch (Exception ignored) {}
    }
%>
