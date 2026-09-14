package com.finding;

import com.finding.util.DBUtil;
import javax.servlet.ServletContextEvent;
import javax.servlet.ServletContextListener;
import javax.servlet.annotation.WebListener;
import java.util.Date;
import java.util.logging.Logger;

@WebListener
public class AppInitializer implements ServletContextListener {
    private static final Logger LOGGER = Logger.getLogger(AppInitializer.class.getName());

    @Override
    public void contextInitialized(ServletContextEvent sce) {
        sce.getServletContext().setAttribute("startupTime", new Date().toString());
        sce.getServletContext().setAttribute("appVersion", "2.0.0");
        LOGGER.info("FindinG v2.0 started at " + new Date());
        // Warm up DB pool
        try {
            boolean healthy = DBUtil.isHealthy();
            LOGGER.info("DB Health: " + (healthy ? "UP" : "DOWN"));
        } catch (Exception e) {
            LOGGER.warning("DB health check failed: " + e.getMessage());
        }
    }

    @Override
    public void contextDestroyed(ServletContextEvent sce) {
        LOGGER.info("FindinG shutting down, closing DB pool");
        DBUtil.close();
    }
}
