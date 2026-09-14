<%@ page language="java" contentType="application/json; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.finding.util.DBUtil" %>
<%@ page import="java.util.*" %>
<%
    response.setHeader("Cache-Control", "no-cache");
    boolean dbHealthy = false;
    String dbMessage = "Unknown";
    long start = System.currentTimeMillis();
    try {
        dbHealthy = DBUtil.isHealthy();
        dbMessage = dbHealthy ? "Connected" : "Failed";
    } catch (Exception e) {
        dbMessage = e.getMessage();
    }
    long elapsed = System.currentTimeMillis() - start;

    String status = dbHealthy ? "UP" : "DOWN";
    int httpStatus = dbHealthy ? 200 : 503;
    response.setStatus(httpStatus);
%>
{
  "status": "<%= status %>",
  "timestamp": "<%= new Date().toInstant().toString() %>",
  "version": "2.0.0",
  "components": {
    "database": {
      "status": "<%= dbHealthy ? "UP" : "DOWN" %>",
      "message": "<%= dbMessage %>",
      "responseTimeMs": <%= elapsed %>
    },
    "app": {
      "status": "UP",
      "uptime": "<%= application.getAttribute("startupTime") != null ? application.getAttribute("startupTime") : "unknown" %>"
    }
  },
  "checks": {
    "session": "<%= session != null ? "active" : "none" %>",
    "javaVersion": "<%= System.getProperty("java.version") %>"
  }
}
