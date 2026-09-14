package com.finding;

import java.io.File;
import java.util.logging.Logger;

/**
 * Embedded Webapp Runner - One-click Java runner
 * 
 * This class allows running the webapp without external Tomcat installation.
 * It will:
 * 1. Check if Tomcat is available in tools/tomcat
 * 2. If not, use embedded approach or download Tomcat
 * 3. Deploy the war and start server
 * 
 * Usage:
 *   java -cp target/classes:target/dependency/* com.finding.EmbeddedRunner
 *   or via Maven: mvn exec:java -Dexec.mainClass="com.finding.EmbeddedRunner"
 * 
 * For Windows one-click, run.bat handles everything automatically.
 */
public class EmbeddedRunner {
    private static final Logger LOGGER = Logger.getLogger(EmbeddedRunner.class.getName());
    private static final int DEFAULT_PORT = 8080;

    public static void main(String[] args) {
        System.out.println("================================================================");
        System.out.println(" FindinG - Embedded Webapp Runner v2.0");
        System.out.println("================================================================");

        int port = DEFAULT_PORT;
        if (args.length > 0) {
            try {
                port = Integer.parseInt(args[0]);
            } catch (NumberFormatException e) {
                System.err.println("Invalid port, using default 8080");
            }
        }

        System.out.println("Port: " + port);
        System.out.println("Project Root: " + new File(".").getAbsolutePath());

        // Check if war exists
        File warFile = new File("target/finding.war");
        if (!warFile.exists()) {
            System.err.println("War file not found: target/finding.war");
            System.err.println("Please build first: mvn clean package");
            System.err.println("Or run: run.bat / run.ps1");
            System.exit(1);
        }

        System.out.println("War file found: " + warFile.getAbsolutePath() + " (" + warFile.length() / 1024 + " KB)");

        // Try to start with Tomcat from tools
        File tomcatDir = new File("tools/tomcat");
        if (tomcatDir.exists()) {
            System.out.println("Tomcat found at: " + tomcatDir.getAbsolutePath());
            startWithExternalTomcat(tomcatDir, warFile, port);
        } else {
            System.out.println("Tomcat not found in tools/, trying to use embedded or download...");
            System.out.println("For embedded mode, we will try to start via Maven Tomcat plugin");
            System.out.println("Please run: mvn clean package tomcat7:run -Dport=" + port);
            System.out.println("Or use run.bat which auto-downloads Tomcat");
            
            // Fallback: try to download and start
            downloadAndStartTomcat(warFile, port);
        }
    }

    private static void startWithExternalTomcat(File tomcatDir, File warFile, int port) {
        try {
            System.out.println("Deploying war to external Tomcat...");
            File webappsDir = new File(tomcatDir, "webapps");
            File rootWar = new File(webappsDir, "ROOT.war");
            File rootDir = new File(webappsDir, "ROOT");

            // Clean old deployment
            if (rootDir.exists()) {
                deleteRecursively(rootDir);
            }
            if (rootWar.exists()) {
                rootWar.delete();
            }

            // Copy new war
            java.nio.file.Files.copy(warFile.toPath(), rootWar.toPath());
            System.out.println("Deployed to: " + rootWar.getAbsolutePath());

            // Configure port if not default
            if (port != 8080) {
                configureTomcatPort(tomcatDir, port);
            }

            // Start Tomcat
            System.out.println("Starting Tomcat...");
            String os = System.getProperty("os.name").toLowerCase();
            File startupFile;
            if (os.contains("win")) {
                startupFile = new File(tomcatDir, "bin/startup.bat");
            } else {
                startupFile = new File(tomcatDir, "bin/startup.sh");
                startupFile.setExecutable(true);
            }

            if (startupFile.exists()) {
                ProcessBuilder pb = new ProcessBuilder(startupFile.getAbsolutePath());
                pb.directory(tomcatDir);
                pb.inheritIO();
                Process p = pb.start();
                System.out.println("Tomcat startup initiated, PID: " + p.pid());
                System.out.println("Waiting 15 seconds for startup...");
                Thread.sleep(15000);
                System.out.println("================================================================");
                System.out.println(" SUCCESS! Open http://localhost:" + port);
                System.out.println("================================================================");
                if (os.contains("win")) {
                    Runtime.getRuntime().exec("cmd /c start http://localhost:" + port);
                }
            } else {
                System.err.println("Startup file not found: " + startupFile.getAbsolutePath());
            }

        } catch (Exception e) {
            System.err.println("Failed to start Tomcat: " + e.getMessage());
            e.printStackTrace();
        }
    }

    private static void downloadAndStartTomcat(File warFile, int port) {
        try {
            System.out.println("Downloading Tomcat 9.0.85...");
            File toolsDir = new File("tools");
            if (!toolsDir.exists()) toolsDir.mkdirs();

            String tomcatUrl = "https://archive.apache.org/dist/tomcat/tomcat-9/v9.0.85/bin/apache-tomcat-9.0.85.zip";
            File zipFile = new File(toolsDir, "tomcat.zip");

            // Download using Java
            System.out.println("Downloading from: " + tomcatUrl);
            try (java.io.InputStream in = new java.net.URL(tomcatUrl).openStream()) {
                java.nio.file.Files.copy(in, zipFile.toPath(), java.nio.file.StandardCopyOption.REPLACE_EXISTING);
            }

            System.out.println("Downloaded: " + zipFile.length() / 1024 / 1024 + " MB");

            // Extract
            System.out.println("Extracting...");
            try (java.util.zip.ZipInputStream zis = new java.util.zip.ZipInputStream(new java.io.FileInputStream(zipFile))) {
                java.util.zip.ZipEntry entry;
                while ((entry = zis.getNextEntry()) != null) {
                    File newFile = new File(toolsDir, entry.getName());
                    if (entry.isDirectory()) {
                        newFile.mkdirs();
                    } else {
                        newFile.getParentFile().mkdirs();
                        try (java.io.FileOutputStream fos = new java.io.FileOutputStream(newFile)) {
                            byte[] buffer = new byte[1024];
                            int len;
                            while ((len = zis.read(buffer)) > 0) {
                                fos.write(buffer, 0, len);
                            }
                        }
                    }
                }
            }

            // Find extracted dir and rename to tomcat
            File[] files = toolsDir.listFiles((dir, name) -> name.startsWith("apache-tomcat-"));
            if (files != null && files.length > 0) {
                File extracted = files[0];
                File tomcatDir = new File(toolsDir, "tomcat");
                if (tomcatDir.exists()) deleteRecursively(tomcatDir);
                extracted.renameTo(tomcatDir);
                System.out.println("Tomcat extracted to: " + tomcatDir.getAbsolutePath());

                // Now start
                startWithExternalTomcat(tomcatDir, warFile, port);
            }

        } catch (Exception e) {
            System.err.println("Failed to download Tomcat: " + e.getMessage());
            e.printStackTrace();
            System.err.println("Please download manually from https://tomcat.apache.org/download-90.cgi");
        }
    }

    private static void configureTomcatPort(File tomcatDir, int port) {
        try {
            File serverXml = new File(tomcatDir, "conf/server.xml");
            if (serverXml.exists()) {
                String content = new String(java.nio.file.Files.readAllBytes(serverXml.toPath()));
                content = content.replaceAll("port=\"8080\"", "port=\"" + port + "\"");
                java.nio.file.Files.write(serverXml.toPath(), content.getBytes());
                System.out.println("Tomcat port configured to: " + port);
            }
        } catch (Exception e) {
            System.err.println("Failed to configure port: " + e.getMessage());
        }
    }

    private static void deleteRecursively(File file) {
        if (file.isDirectory()) {
            File[] children = file.listFiles();
            if (children != null) {
                for (File child : children) {
                    deleteRecursively(child);
                }
            }
        }
        file.delete();
    }
}
