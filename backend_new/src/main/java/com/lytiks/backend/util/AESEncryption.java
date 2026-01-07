package com.lytiks.backend.util;

import javax.crypto.Cipher;
import javax.crypto.spec.IvParameterSpec;
import javax.crypto.spec.SecretKeySpec;
import java.util.Base64;

public class AESEncryption {
    
    // Claves proporcionadas por el sistema
    private static final String KEY_STRING = "92EQ11A79WOP3B9I";  // 16 caracteres para AES-128
    private static final String IV_STRING = "SSL23LALLDL14378";   // 16 caracteres para IV
    
    private static final String ALGORITHM = "AES";
    private static final String TRANSFORMATION = "AES/CBC/PKCS5Padding";
    
    /**
     * Encripta un texto plano usando AES
     */
    public static String encrypt(String plainText) {
        try {
            SecretKeySpec keySpec = new SecretKeySpec(KEY_STRING.getBytes("UTF-8"), ALGORITHM);
            IvParameterSpec ivSpec = new IvParameterSpec(IV_STRING.getBytes("UTF-8"));
            
            Cipher cipher = Cipher.getInstance(TRANSFORMATION);
            cipher.init(Cipher.ENCRYPT_MODE, keySpec, ivSpec);
            
            byte[] encrypted = cipher.doFinal(plainText.getBytes("UTF-8"));
            return Base64.getEncoder().encodeToString(encrypted);
            
        } catch (Exception e) {
            throw new RuntimeException("Error al encriptar: " + e.getMessage(), e);
        }
    }
    
    /**
     * Desencripta un texto encriptado (en base64) usando AES
     */
    public static String decrypt(String encryptedText) {
        try {
            SecretKeySpec keySpec = new SecretKeySpec(KEY_STRING.getBytes("UTF-8"), ALGORITHM);
            IvParameterSpec ivSpec = new IvParameterSpec(IV_STRING.getBytes("UTF-8"));
            
            Cipher cipher = Cipher.getInstance(TRANSFORMATION);
            cipher.init(Cipher.DECRYPT_MODE, keySpec, ivSpec);
            
            byte[] encrypted = Base64.getDecoder().decode(encryptedText);
            byte[] decrypted = cipher.doFinal(encrypted);
            
            return new String(decrypted, "UTF-8");
            
        } catch (Exception e) {
            throw new RuntimeException("Error al desencriptar: " + e.getMessage(), e);
        }
    }
    
    /**
     * Verifica si una contraseña plana coincide con una encriptada
     */
    public static boolean verifyPassword(String plainPassword, String encryptedPassword) {
        try {
            String encryptedPlain = encrypt(plainPassword);
            return encryptedPlain.equals(encryptedPassword);
        } catch (Exception e) {
            return false;
        }
    }
    
    /**
     * Método de prueba para validar la encriptación
     */
    public static void testEncryption() {
        String testPassword = "test123";
        
        try {
            // Encriptar
            String encrypted = encrypt(testPassword);
            System.out.println("🔒 Contraseña original: " + testPassword);
            System.out.println("🔐 Contraseña encriptada: " + encrypted);
            
            // Desencriptar
            String decrypted = decrypt(encrypted);
            System.out.println("🔓 Contraseña desencriptada: " + decrypted);
            
            // Verificar
            boolean isValid = verifyPassword(testPassword, encrypted);
            System.out.println("✅ Verificación: " + (isValid ? "EXITOSA" : "FALLIDA"));
            
        } catch (Exception e) {
            System.out.println("❌ Error en prueba: " + e.getMessage());
        }
    }
}