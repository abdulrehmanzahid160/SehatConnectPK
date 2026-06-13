package com.nutech.sehatconnect.controller;

import com.fasterxml.jackson.core.type.TypeReference;
import com.nutech.sehatconnect.entity.HealthResult;
import com.nutech.sehatconnect.entity.User;
import com.nutech.sehatconnect.exception.InvalidInputException;
import com.nutech.sehatconnect.exception.UserNotFoundException;
import com.nutech.sehatconnect.model.*;
import com.nutech.sehatconnect.service.FileStorageService;
import com.nutech.sehatconnect.service.UserService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDate;
import java.util.*;

/**
 * ApiController — REST endpoints for SehatConnect.
 *
 * OOP concepts demonstrated:
 *   - Polymorphism     : HealthCalculator reference used to call calculate()/getAdvice()
 *                        on any subtype (BMI, Calorie, Sleep …)
 *   - Interface usage  : Advisable (HealthAdvisor) called after each calculation
 *   - Encapsulation    : private helper methods hide repetitive logic
 *   - Exception Handling: throws UserNotFoundException / InvalidInputException;
 *                         GlobalExceptionHandler catches them
 *   - Dependency Injection: Spring @Autowired
 */
@RestController
@RequestMapping("/api")
public class ApiController {

    @Autowired
    private UserService userService;

    @Autowired
    private FileStorageService fileStorage;

    /**
     * HealthAdvisor is injected as the Advisable interface type.
     * This is INTERFACE-BASED POLYMORPHISM: the controller only knows
     * about the Advisable contract, not the concrete HealthAdvisor class.
     */
    @Autowired
    private Advisable healthAdvisor;

    private static final String MEDICINES_FILE = "medicines.json";

    // -------------------------------------------------------------------------
    // Private helpers
    // -------------------------------------------------------------------------

    /** Extract userId from "Bearer <userId>" Authorization header. */
    private String extractUserId(String authHeader) {
        if (authHeader == null || authHeader.isBlank()) return null;
        return authHeader.replace("Bearer ", "").trim();
    }

    /**
     * POLYMORPHISM in action: accepts any HealthCalculator subtype,
     * calls calculate() and getAdvice() via the parent-class reference,
     * persists the result, and returns a response map.
     *
     * Because the parameter type is HealthCalculator (abstract), the JVM
     * dispatches to the correct override at runtime — this is runtime
     * (dynamic) polymorphism.
     */
    private Map<String, Object> runCalculator(
            HealthCalculator calculator,
            String resultKey,
            String userId) {

        // calculate() and getAdvice() are abstract — resolved at runtime
        double result = calculator.calculate();
        String advice = calculator.getAdvice();

        // Interface-based polymorphism: healthAdvisor is typed as Advisable
        HealthResult hr = new HealthResult();
        hr.setCalculatorType(resultKey);
        hr.setResultValue(result);
        hr.setAdvice(advice);
        String enrichedAdvice = healthAdvisor.giveAdvice(hr); // Advisable.giveAdvice(HealthResult)

        // Persist result if user is logged in
        if (userId != null && !userId.isEmpty()) {
            userService.saveHealthResult(hr, userId);
        }

        Map<String, Object> response = new LinkedHashMap<>();
        response.put(resultKey, result);
        response.put("advice", advice);
        response.put("tip", enrichedAdvice);
        return response;
    }

    // -------------------------------------------------------------------------
    // Health Calculator Endpoints
    // -------------------------------------------------------------------------

    @PostMapping("/bmi")
    public Map<String, Object> calculateBmi(
            @RequestBody Map<String, Object> payload,
            @RequestHeader(value = "Authorization", required = false) String authHeader) {

        // Exception Handling: NumberFormatException caught by GlobalExceptionHandler
        double weight = Double.parseDouble(payload.get("weight").toString());
        double height = Double.parseDouble(payload.get("height").toString());

        BMICalculator calc = new BMICalculator();
        calc.setWeight(weight);
        calc.setHeight(height);

        // POLYMORPHISM: runCalculator() works via abstract HealthCalculator reference
        return runCalculator(calc, "bmi", extractUserId(authHeader));
    }

    @PostMapping("/water")
    public Map<String, Object> calculateWater(
            @RequestBody Map<String, Object> payload,
            @RequestHeader(value = "Authorization", required = false) String authHeader) {

        double weight     = Double.parseDouble(payload.get("weight").toString());
        String activity   = payload.get("activityLevel").toString();

        WaterIntakeCalculator calc = new WaterIntakeCalculator();
        calc.setWeight(weight);
        calc.setActivityLevel(activity);

        return runCalculator(calc, "waterLitres", extractUserId(authHeader));
    }



    @PostMapping("/calorie")
    public Map<String, Object> calculateCalorie(
            @RequestBody Map<String, Object> payload,
            @RequestHeader(value = "Authorization", required = false) String authHeader) {

        double weight  = Double.parseDouble(payload.get("weight").toString());
        double height  = Double.parseDouble(payload.get("height").toString());
        int    age     = Integer.parseInt(payload.get("age").toString());
        String gender  = payload.get("gender").toString();
        String activity = payload.get("activityLevel").toString();

        CalorieCalculator calc = new CalorieCalculator();
        calc.setWeight(weight);
        calc.setHeight(height);
        calc.setAge(age);         // inherited from HealthCalculator
        calc.setGender(gender);   // inherited from HealthCalculator
        calc.setActivityLevel(activity);

        return runCalculator(calc, "calories", extractUserId(authHeader));
    }

    @PostMapping("/sleep")
    public Map<String, Object> calculateSleep(
            @RequestBody Map<String, Object> payload,
            @RequestHeader(value = "Authorization", required = false) String authHeader) {

        double hours    = Double.parseDouble(payload.get("hoursSlept").toString());
        String ageGroup = payload.get("ageGroup").toString();

        SleepCalculator calc = new SleepCalculator();
        calc.setHoursSlept(hours);
        calc.setAgeGroup(ageGroup);

        return runCalculator(calc, "sleepDebt", extractUserId(authHeader));
    }

    // -------------------------------------------------------------------------
    // Medicine Reminder Endpoints  (persisted to data/medicines.json)
    // -------------------------------------------------------------------------

    @PostMapping("/medicine/add")
    public Map<String, String> addMedicine(@RequestBody Map<String, Object> payload) {
        String userId = payload.get("userId").toString();
        String name   = payload.get("name").toString();
        String dosage = payload.get("dosage").toString();
        String timing = payload.get("timing").toString();

        if (name.isBlank())   throw new InvalidInputException("name",   "cannot be empty");
        if (dosage.isBlank()) throw new InvalidInputException("dosage", "cannot be empty");

        Map<String, List<Map<String, String>>> store = loadMedicinesStore();
        store.putIfAbsent(userId, new ArrayList<>());

        Map<String, String> med = new LinkedHashMap<>();
        med.put("name",   name);
        med.put("dosage", dosage);
        med.put("timing", timing);
        store.get(userId).add(med);

        fileStorage.writeMap(MEDICINES_FILE, store);

        Map<String, String> response = new HashMap<>();
        response.put("message", "Medicine added successfully");
        return response;
    }

    @DeleteMapping("/medicine/remove/{userId}/{medicineName}")
    public Map<String, String> removeMedicine(
            @PathVariable String userId,
            @PathVariable String medicineName) {

        Map<String, List<Map<String, String>>> store = loadMedicinesStore();
        if (store.containsKey(userId)) {
            store.get(userId).removeIf(m -> medicineName.equalsIgnoreCase(m.get("name")));
            fileStorage.writeMap(MEDICINES_FILE, store);
        }

        Map<String, String> response = new HashMap<>();
        response.put("message", "Medicine removed (if it existed)");
        return response;
    }

    @GetMapping("/medicine/list/{userId}")
    public List<Map<String, String>> getMedicines(@PathVariable String userId) {
        return loadMedicinesStore().getOrDefault(userId, List.of());
    }

    // -------------------------------------------------------------------------
    // Report Endpoints
    // -------------------------------------------------------------------------

    /**
     * Generate and save a health report for the user.
     * Uses the Reportable interface — ApiController only calls buildReportText()
     * and getReportFilename(), not any HealthReport-specific methods.
     */
    @GetMapping("/report/{userId}")
    public ResponseEntity<String> getReport(@PathVariable String userId) {
        User user = userService.getUserById(userId);
        if (user == null) throw new UserNotFoundException(userId);

        List<HealthResult> results = userService.getHealthHistory(userId);

        // Reportable interface — controller is decoupled from concrete class
        Reportable report = new HealthReport(user.getName(), results);
        fileStorage.writeTextFile(report.getReportFilename(), report.buildReportText());

        // Also return JSON to the Flutter front-end
        return ResponseEntity.ok(((HealthReport) report).toJSON());
    }

    /** Re-read a previously saved .txt report from disk. */
    @GetMapping("/report/{userId}/text")
    public ResponseEntity<String> getReportText(@PathVariable String userId) {
        User user = userService.getUserById(userId);
        if (user == null) throw new UserNotFoundException(userId);

        String filename = "report_" + user.getName().replaceAll("\\s+", "_") + ".txt";
        String content  = fileStorage.readTextFile(filename);

        if (content == null) {
            return ResponseEntity.notFound().build();
        }
        return ResponseEntity.ok(content);
    }

    // -------------------------------------------------------------------------
    // User Endpoints
    // -------------------------------------------------------------------------

    @PostMapping("/user/save")
    public User saveUser(
            @RequestBody User user,
            @RequestHeader("Authorization") String authHeader) {

        String userId = extractUserId(authHeader);
        if (userId == null || userId.isBlank()) {
            throw new InvalidInputException("Authorization", "userId must be provided in Bearer token");
        }
        return userService.updateUser(user, userId);
    }

    @GetMapping("/user/{userId}")
    public User getUser(@PathVariable String userId) {
        User user = userService.getUserById(userId);
        if (user == null) throw new UserNotFoundException(userId);
        return user;
    }

    // -------------------------------------------------------------------------
    // Private file-loading helpers
    // -------------------------------------------------------------------------

    private Map<String, List<Map<String, String>>> loadMedicinesStore() {
        return fileStorage.readMap(
                MEDICINES_FILE,
                new TypeReference<Map<String, List<Map<String, String>>>>() {});
    }
}
