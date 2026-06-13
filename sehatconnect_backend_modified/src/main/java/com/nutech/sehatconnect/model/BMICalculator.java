package com.nutech.sehatconnect.model;

import com.nutech.sehatconnect.exception.InvalidInputException;

public class BMICalculator extends HealthCalculator {

    private double weight; // kg
    private double height; // metres

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

    @Override
    public double calculate() {
        // validations
        if (weight <= 0)
            throw new InvalidInputException("weight", "must be greater than 0");
        if (weight > 500)
            throw new InvalidInputException("weight", "cannot exceed 500 kg");
        if (height <= 0)
            throw new InvalidInputException("height", "must be greater than 0 (in metres)");
        if (height > 3.0)
            throw new InvalidInputException("height", "cannot exceed 3.0 meters");

        return weight / (height * height);
    }

    @Override
    public String getAdvice() {
        double bmi = calculate();
        if (bmi < 18.5)
            return "Underweight (Wazan badhayein)";
        else if (bmi <= 24.9)
            return "Normal (Wah! Sehat acha hai)";
        else if (bmi <= 29.9)
            return "Overweight (Wazan kam karein!)";
        else
            return "Obese (Doctor se milyein!)";
    }
}
