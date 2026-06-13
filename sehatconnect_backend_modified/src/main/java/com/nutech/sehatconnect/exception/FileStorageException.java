package com.nutech.sehatconnect.exception;

public class FileStorageException extends RuntimeException {

    private final String filename;

    public FileStorageException(String filename, String operation, Throwable cause) {
        super("File storage error during '" + operation + "' on file: " + filename, cause);
        this.filename = filename;
    }

    public String getFilename() {
        return filename;
    }
}
