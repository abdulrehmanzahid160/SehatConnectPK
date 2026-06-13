package com.nutech.sehatconnect.exception;

public class InvalidInputException extends RuntimeException {

    private final String fieldName;

    public InvalidInputException(String fieldName, String reason) {
        super("Invalid input for '" + fieldName + "': " + reason);
        this.fieldName = fieldName;
    }

    public String getFieldName() {
        return fieldName;
    }
}
