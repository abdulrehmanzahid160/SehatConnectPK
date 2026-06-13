package com.nutech.sehatconnect.model;

import com.nutech.sehatconnect.entity.HealthResult;
import org.springframework.stereotype.Component;

@Component
public class HealthAdvisor implements Advisable {

    // Overloaded method 1
    @Override
    public String giveAdvice(double result) {
        return "Result is " + result + ". Please consult documentation.";
    }

    // Overloaded method 2
    @Override
    public String giveAdvice(HealthResult hr) {
        if (hr == null || hr.getCalculatorType() == null) {
            return "No data provided.";
        }

        switch (hr.getCalculatorType().toLowerCase()) {
            case "bmi":
                if (hr.getResultValue() < 18.5)
                    return "Underweight! Wazan badhayein.";
                if (hr.getResultValue() < 25)
                    return "Normal! Wah! Sehat acha hai.";
                if (hr.getResultValue() < 30)
                    return "Overweight! Wazan kam karein!";
                return "Obese! Doctor se milyein!";
            case "water":
                return "Aapko din mein " + String.format("%.2f", hr.getResultValue())
                        + " liters pani peena chahiye. Stay hydrated!";
            default:
                return "Apni Sehat, Apna Khayal!";
        }
    }
}
