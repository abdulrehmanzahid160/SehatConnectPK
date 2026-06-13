package com.nutech.sehatconnect;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

@SpringBootApplication
public class SehatConnectApp {

    public static void main(String[] args) {
        SpringApplication.run(SehatConnectApp.class, args);
        System.out.println("SehatConnect Backend is running...");
    }
}
