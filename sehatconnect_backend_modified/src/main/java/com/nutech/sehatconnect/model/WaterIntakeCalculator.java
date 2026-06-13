package com.nutech.sehatconnect.model;

import com.nutech.sehatconnect.exception.InvalidInputException;

public class WaterIntakeCalculator extends HealthCalculator {

    private double weight; // kg
    private String activityLevel; // sedentary | active | very_active

    public double getWeight() {
        return weight;
    }

    public void setWeight(double weight) {
        this.weight = weight;
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

        double base = weight * 0.033;
        if (activityLevel != null) {
            switch (activityLevel.toLowerCase()) {
                case "active":
                    base += 0.5;
                    break;
                case "very_active":
                    base += 1.0;
                    break;
            }
        }
        return base;
    }

    @Override
    public String getAdvice() {
        return String.format(
                "Aapko din mein %.2f liters pani peena chahiye. Stay hydrated!", calculate());
    }
}
