package com.finding.util;

import org.mindrot.jbcrypt.BCrypt;
import java.security.SecureRandom;
import java.util.regex.Pattern;

/**
 * Security utilities: password hashing, validation, sanitization.
 */
public class SecurityUtil {

    private static final Pattern EMAIL_PATTERN = Pattern.compile(
            "^[A-Z0-9._%+-]+@[A-Z0-9.-]+\\.[A-Z]{2,}$", Pattern.CASE_INSENSITIVE);
    private static final Pattern USERNAME_PATTERN = Pattern.compile("^[a-zA-Z0-9_]{3,30}$");
    private static final SecureRandom RANDOM = new SecureRandom();

    /**
     * Hash password with BCrypt (work factor 12)
     */
    public static String hashPassword(String plainPassword) {
        if (plainPassword == null) throw new IllegalArgumentException("Password null");
        return BCrypt.hashpw(plainPassword, BCrypt.gensalt(12));
    }

    /**
     * Check plain vs hashed. Supports legacy plain-text for migration.
     */
    public static boolean checkPassword(String plainPassword, String hashedPassword) {
        if (plainPassword == null || hashedPassword == null) return false;
        // BCrypt hashes start with $2a$ or $2b$
        if (hashedPassword.startsWith("$2a$") || hashedPassword.startsWith("$2b$") || hashedPassword.startsWith("$2y$")) {
            try {
                return BCrypt.checkpw(plainPassword, hashedPassword);
            } catch (Exception e) {
                return false;
            }
        } else {
            // Legacy fallback: plain compare (will be upgraded on next login)
            return plainPassword.equals(hashedPassword);
        }
    }

    public static boolean isValidEmail(String email) {
        return email != null && EMAIL_PATTERN.matcher(email).matches();
    }

    public static boolean isValidUsername(String username) {
        return username != null && USERNAME_PATTERN.matcher(username).matches();
    }

    public static boolean isStrongPassword(String password) {
        if (password == null || password.length() < 8) return false;
        boolean hasUpper = false, hasLower = false, hasDigit = false;
        for (char c : password.toCharArray()) {
            if (Character.isUpperCase(c)) hasUpper = true;
            else if (Character.isLowerCase(c)) hasLower = true;
            else if (Character.isDigit(c)) hasDigit = true;
        }
        return hasUpper && hasLower && hasDigit;
    }

    /**
     * Basic XSS prevention: escape HTML.
     */
    public static String escapeHtml(String input) {
        if (input == null) return "";
        return input.replace("&", "&amp;")
                .replace("<", "&lt;")
                .replace(">", "&gt;")
                .replace("\"", "&quot;")
                .replace("'", "&#x27;");
    }

    /**
     * Sanitize search input: remove dangerous chars, trim, limit length.
     */
    public static String sanitizeSearch(String input) {
        if (input == null) return "";
        String s = input.trim();
        if (s.length() > 100) s = s.substring(0, 100);
        // Remove null bytes and control chars except space
        s = s.replaceAll("[\\x00-\\x08\\x0B\\x0C\\x0E-\\x1F]", "");
        return s;
    }

    public static String generateCsrfToken() {
        byte[] bytes = new byte[32];
        RANDOM.nextBytes(bytes);
        StringBuilder sb = new StringBuilder();
        for (byte b : bytes) sb.append(String.format("%02x", b));
        return sb.toString();
    }
}
