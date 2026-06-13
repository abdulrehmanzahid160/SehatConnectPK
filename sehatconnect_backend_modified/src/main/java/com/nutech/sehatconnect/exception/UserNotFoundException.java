package com.nutech.sehatconnect.exception;

public class UserNotFoundException extends RuntimeException {

    private final String userId;

    public UserNotFoundException(String userId) {
        super("User not found with ID: " + userId);
        this.userId = userId;
    }

    public String getUserId() {
        return userId;
    }
}
