package com.nutech.sehatconnect.model;

public abstract class HealthCalculator {
    private String name;
    private String gender;
    private int age;

    // Encapsulation: getters and setters
    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public String getGender() {
        return gender;
    }

    public void setGender(String gender) {
        this.gender = gender;
    }

    public int getAge() {
        return age;
    }

    public void setAge(int age) {
        this.age = age;
    }

    public String getProfile() {
        return "Name: " + name + ", Age: " + age + ", Gender: " + gender;
    }

    // Abstract methods
    public abstract double calculate();

    public abstract String getAdvice();
}
