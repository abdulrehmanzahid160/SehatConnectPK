package com.nutech.sehatconnect.model;

import com.nutech.sehatconnect.exception.InvalidInputException;

public class CalorieCalculator extends HealthCalculator {

    private double weight; // kg
    private double height; // cm
    private String activityLevel;

    public double getWeight() {
        return weight;
    }

    public void setWeight(double weight) {
        this.weight = weight;
    }

    public double getHeight() {
        return height;
    }

    public void setHeight(double height) {
        this.height = height;
    }

    public String getActivityLevel() {
        return activityLevel;
    }

    public void setActivityLevel(String activityLevel) {
        this.activityLevel = activityLevel;
    }

    @Override
    public double calculate() {
        // validations
        if (weight <= 0)
            throw new InvalidInputException("weight", "must be greater than 0");
        if (weight > 500)
            throw new InvalidInputException("weight", "cannot exceed 500 kg");
        if (height <= 0)
            throw new InvalidInputException("height", "must be greater than 0");
        if (height > 300)
            throw new InvalidInputException("height", "cannot exceed 300 cm");
        if (getAge() <= 0)
            throw new InvalidInputException("age", "must be greater than 0");
        if (getAge() > 120)
            throw new InvalidInputException("age", "cannot exceed 120 years");
        if (getGender() == null || getGender().isBlank())
            throw new InvalidInputException("gender", "must be 'male' or 'female'");

        double bmr;
        if ("male".equalsIgnoreCase(getGender())) {
            bmr = 88.362 + (13.397 * weight) + (4.799 * height) - (5.677 * getAge());
        } else {
            bmr = 447.593 + (9.247 * weight) + (3.098 * height) - (4.330 * getAge());
        }

        // Activity multiplier
        double multiplier;
        if (activityLevel == null) {
            multiplier = 1.2;
        } else {
            switch (activityLevel.toLowerCase()) {
                case "light":
                    multiplier = 1.375;
                    break;
                case "moderate":
                    multiplier = 1.55;
                    break;
                case "active":
                    multiplier = 1.725;
                    break;
                default:
                    multiplier = 1.2;
                    break;
            }
        }
        return bmr * multiplier;
    }

    @Override
    public String getAdvice() {
        double tdee = calculate();
        return String.format(
                "Aapko rozana %.0f calories leni chahiye apne wazan ko barqarar rakhne ke liye.", tdee);
    }
}
