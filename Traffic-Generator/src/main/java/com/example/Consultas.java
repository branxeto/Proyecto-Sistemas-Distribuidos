package com.example;

import java.util.List;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;

@JsonIgnoreProperties(ignoreUnknown = true)
public class Consultas {
    private List<Integer> severity;
    private List<Integer> level;
    private List<String> street;
    private List<String> city;
    private List<Double> speed;
    private List<Double> speedKMH;

    // Getters y setters
    public List<Integer> getSeverity() {
        return severity;
    }

    public void setSeverity(List<Integer> severity) {
        this.severity = severity;
    }

    public List<Integer> getLevel() {
        return level;
    }

    public void setLevel(List<Integer> level) {
        this.level = level;
    }

    public List<String> getStreet() {
        return street;
    }

    public void setStreet(List<String> street) {
        this.street = street;
    }

    public List<String> getCity() {
        return city;
    }

    public void setCity(List<String> city) {
        this.city = city;
    }

    public List<Double> getSpeed() {
        return speed;
    }

    public void setSpeed(List<Double> speed) {
        this.speed = speed;
    }

    public List<Double> getSpeedKMH() {
        return speedKMH;
    }

    public void setSpeedKMH(List<Double> speedKMH) {
        this.speedKMH = speedKMH;
    }
}