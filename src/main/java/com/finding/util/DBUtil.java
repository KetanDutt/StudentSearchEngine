package com.finding.util;

import com.zaxxer.hikari.HikariConfig;
import com.zaxxer.hikari.HikariDataSource;
import java.io.InputStream;
import java.sql.Connection;
import java.sql.SQLException;
import java.util.Properties;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * Database utility with HikariCP connection pooling.
 * Centralizes DB configuration and prevents resource leaks.
 */
public class DBUtil {
    private static final Logger LOGGER = Logger.getLogger(DBUtil.class.getName());
    private static HikariDataSource dataSource;
    private static final String DEFAULT_URL = "jdbc:mysql://localhost:3306/project?useSSL=false&allowPublicKeyRetrieval=true&serverTimezone=UTC&characterEncoding=UTF-8";
    private static final String DEFAULT_USER = "root";
    private static final String DEFAULT_PASSWORD = "toor";

    static {
        try {
            initDataSource();
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Failed to initialize datasource", e);
        }
    }

    private static void initDataSource() {
        Properties props = new Properties();
        String dbUrl = DEFAULT_URL;
        String dbUser = DEFAULT_USER;
        String dbPassword = DEFAULT_PASSWORD;

        try (InputStream is = DBUtil.class.getClassLoader().getResourceAsStream("config.properties")) {
            if (is != null) {
                props.load(is);
                dbUrl = props.getProperty("db.url", DEFAULT_URL);
                dbUser = props.getProperty("db.user", DEFAULT_USER);
                dbPassword = props.getProperty("db.password", DEFAULT_PASSWORD);
            }
        } catch (Exception e) {
            LOGGER.log(Level.WARNING, "config.properties not found, using defaults");
        }

        // Allow env overrides (12-factor app)
        String envUrl = System.getenv("DB_URL");
        String envUser = System.getenv("DB_USER");
        String envPass = System.getenv("DB_PASSWORD");
        if (envUrl != null && !envUrl.isEmpty()) dbUrl = envUrl;
        if (envUser != null && !envUser.isEmpty()) dbUser = envUser;
        if (envPass != null && !envPass.isEmpty()) dbPassword = envPass;

        HikariConfig config = new HikariConfig();
        config.setJdbcUrl(dbUrl);
        config.setUsername(dbUser);
        config.setPassword(dbPassword);
        config.setDriverClassName("com.mysql.cj.jdbc.Driver");
        config.setMaximumPoolSize(10);
        config.setMinimumIdle(2);
        config.setConnectionTimeout(30000);
        config.setIdleTimeout(600000);
        config.setMaxLifetime(1800000);
        config.setLeakDetectionThreshold(60000);
        config.addDataSourceProperty("cachePrepStmts", "true");
        config.addDataSourceProperty("prepStmtCacheSize", "250");
        config.addDataSourceProperty("prepStmtCacheSqlLimit", "2048");
        config.addDataSourceProperty("useServerPrepStmts", "true");

        dataSource = new HikariDataSource(config);
        LOGGER.info("HikariCP DataSource initialized");
    }

    /**
     * Get a connection from pool. Caller must close it (returns to pool).
     */
    public static Connection getConnection() throws SQLException {
        if (dataSource == null) {
            throw new SQLException("DataSource not initialized");
        }
        return dataSource.getConnection();
    }

    /**
     * Legacy method for JSPs that still use DriverManager directly - now uses pool.
     */
    public static Connection getLegacyConnection() throws SQLException {
        return getConnection();
    }

    public static void close() {
        if (dataSource != null && !dataSource.isClosed()) {
            dataSource.close();
        }
    }

    // For testing health
    public static boolean isHealthy() {
        try (Connection con = getConnection()) {
            return con.isValid(2);
        } catch (Exception e) {
            return false;
        }
    }
}
