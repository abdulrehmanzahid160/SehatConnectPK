package com.nutech.sehatconnect.service;

import com.fasterxml.jackson.core.type.TypeReference;
import com.nutech.sehatconnect.entity.HealthResult;
import com.nutech.sehatconnect.entity.User;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.*;
import java.util.stream.Collectors;

@Service
public class UserService {

    private static final String USERS_FILE = "users.json";
    private static final String RESULTS_FILE = "health_results.json";

    @Autowired
    private FileStorageService fileStorage;

    public User saveUser(User user) {
        List<User> users = loadUsers();

        if (user.getId() == null || user.getId().isEmpty()) {
            user.setId(UUID.randomUUID().toString());
        }

        // Replace existing or add new
        users.removeIf(u -> u.getId().equals(user.getId()));
        users.add(user);

        fileStorage.writeList(USERS_FILE, users);
        return user;
    }

    /**
     * Find a user by their internal UUID.
     */
    public User getUserById(String userId) {
        return loadUsers().stream()
                .filter(u -> u.getId().equals(userId))
                .findFirst()
                .orElse(null);
    }

    public User updateUser(User userDetails, String userId) {
        // Biological and standard constraints validation with clear developer comments
        validateUser(userDetails);

        User existing = getUserById(userId);
        if (existing != null) {
            existing.setName(userDetails.getName());
            existing.setAge(userDetails.getAge());
            existing.setGender(userDetails.getGender());
            existing.setWeight(userDetails.getWeight());
            existing.setHeight(userDetails.getHeight());
            return saveUser(existing);
        }
        // New user – assign the supplied ID so client can reference it again
        userDetails.setId(userId);
        return saveUser(userDetails);
    }

    /**
     * Professional bounds check validator for citizen records.
     */
    private void validateUser(User user) {
        if (user.getName() == null || user.getName().isBlank()) {
            throw new com.nutech.sehatconnect.exception.InvalidInputException("name", "Name cannot be empty");
        }
        if (user.getAge() <= 0 || user.getAge() > 120) {
            throw new com.nutech.sehatconnect.exception.InvalidInputException("age",
                    "Age must be between 1 and 120 years");
        }
        if (user.getWeight() <= 1.0 || user.getWeight() > 500) {
            throw new com.nutech.sehatconnect.exception.InvalidInputException("weight",
                    "Weight must be between 1.0 and 500.0 kg");
        }
        if (user.getHeight() <= 10.0 || user.getHeight() > 300) {
            throw new com.nutech.sehatconnect.exception.InvalidInputException("height",
                    "Height must be between 10.0 and 300.0 cm");
        }
    }

    public HealthResult saveHealthResult(HealthResult result, String userId) {
        User user = getUserById(userId);
        if (user == null) {
            // Save result without user association
            result.setUserId(userId);
        } else {
            result.setUserId(user.getId());
        }

        if (result.getId() == null || result.getId().isEmpty()) {
            result.setId(UUID.randomUUID().toString());
        }

        List<HealthResult> results = loadHealthResults();
        results.add(result);
        fileStorage.writeList(RESULTS_FILE, results);
        return result;
    }

    public List<HealthResult> getHealthHistory(String userId) {
        return loadHealthResults().stream()
                .filter(r -> userId.equals(r.getUserId()))
                .sorted(Comparator.comparing(HealthResult::getTimestamp,
                        Comparator.nullsLast(Comparator.reverseOrder())))
                .collect(Collectors.toList());
    }

    private List<User> loadUsers() {
        return fileStorage.readList(USERS_FILE, new TypeReference<List<User>>() {
        });
    }

    private List<HealthResult> loadHealthResults() {
        return fileStorage.readList(RESULTS_FILE, new TypeReference<List<HealthResult>>() {
        });
    }
}
