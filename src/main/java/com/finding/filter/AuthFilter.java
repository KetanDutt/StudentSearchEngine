package com.finding.filter;

import javax.servlet.*;
import javax.servlet.annotation.WebFilter;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;

/**
 * Authentication filter to protect secured pages.
 * Redirects unauthenticated users to login.
 */
@WebFilter(filterName = "AuthFilter", urlPatterns = {"/stu.html", "/hr.html", "/stureg.html", "/hrreg.html", "/stusearch.jsp", "/hrsearch.jsp"})
public class AuthFilter implements Filter {

    @Override
    public void init(FilterConfig filterConfig) {}

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {
        HttpServletRequest req = (HttpServletRequest) request;
        HttpServletResponse res = (HttpServletResponse) response;
        HttpSession session = req.getSession(false);

        String uri = req.getRequestURI();
        // Allow public resources
        if (uri.contains("index.html") || uri.contains("register.html") || uri.contains("login.jsp") || uri.contains("reg.jsp")
                || uri.contains(".css") || uri.contains(".js") || uri.contains(".png") || uri.contains(".ico")) {
            chain.doFilter(request, response);
            return;
        }

        boolean loggedIn = session != null && session.getAttribute("user") != null;
        // Also support legacy attribute names
        if (!loggedIn && session != null) {
            loggedIn = session.getAttribute("usr") != null || session.getAttribute("userid") != null;
        }

        if (loggedIn) {
            chain.doFilter(request, response);
        } else {
            // For JSP filter mapping, we redirect if session missing
            // But allow if it's the filter's own check for public pages - we already handled
            // If no session, redirect to index
            if (isApiRequest(req)) {
                res.sendError(HttpServletResponse.SC_UNAUTHORIZED, "Session expired");
            } else {
                res.sendRedirect(req.getContextPath() + "/index.html?error=session_expired");
            }
        }
    }

    private boolean isApiRequest(HttpServletRequest req) {
        String accept = req.getHeader("Accept");
        return accept != null && accept.contains("application/json");
    }

    @Override
    public void destroy() {}
}
