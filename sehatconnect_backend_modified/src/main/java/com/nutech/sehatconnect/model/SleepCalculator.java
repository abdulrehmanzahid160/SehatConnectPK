package com.nutech.sehatconnect.model;

import com.nutech.sehatconnect.exception.InvalidInputException;

public class SleepCalculator extends HealthCalculator {

    private double hoursSlept;
    private String ageGroup; // adult | teen | child

    public double getHoursSlept() {
        return hoursSlept;
    }

    public void setHoursSlept(double hoursSlept) {
        this.hoursSlept = hoursSlept;
    }

    public String getAgeGroup() {
        return ageGroup;
    }

    public void setAgeGroup(String ageGroup) {
        this.ageGroup = ageGroup;
    }

    @Override
    public double calculate() {
        if (hoursSlept < 0 || hoursSlept > 24)
            throw new InvalidInputException("hoursSlept", "must be between 0 and 24");

        double ideal = 8.0;
        if (ageGroup != null) {
            switch (ageGroup.toLowerCase()) {
                case "teen":
                    ideal = 9.0;
                    break;
                case "child":
                    ideal = 10.5;
                    break;
            }
        }
        return ideal - hoursSlept;
    }

    @Override
    public String getAdvice() {
        double debt = calculate();
        if (debt > 0)
            return String.format("Aapki neend %.1f ghante kam hai. Sahi aaram karein!", debt);
        return "Aapki neend poori hai. Behtareen!";
    }
}
