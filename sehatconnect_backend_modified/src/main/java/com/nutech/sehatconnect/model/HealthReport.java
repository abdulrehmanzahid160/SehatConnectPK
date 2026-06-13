package com.nutech.sehatconnect.model;

import com.nutech.sehatconnect.entity.HealthResult;
import java.util.List;

public class HealthReport implements Reportable {

    private String userName;
    private List<HealthResult> results;

    public HealthReport(String userName, List<HealthResult> results) {
        this.userName = userName;
        this.results = results;
    }

    @Override
    public String buildReportText() {
        StringBuilder sb = new StringBuilder();
        sb.append("===============================\n");
        sb.append(" SehatConnect Health Report\n");
        sb.append("===============================\n");
        sb.append("Name: ").append(userName).append("\n\n");

        if (results == null || results.isEmpty()) {
            sb.append("No health records found.\n");
        } else {
            for (HealthResult hr : results) {
                sb.append("Type:   ").append(hr.getCalculatorType()).append("\n");
                sb.append("Result: ").append(hr.getResultValue()).append("\n");
                sb.append("Advice: ").append(hr.getAdvice()).append("\n");
                sb.append("Date:   ").append(hr.getTimestamp()).append("\n");
                sb.append("-------------------------------\n");
            }
        }
        return sb.toString();
    }

    @Override
    public String getReportFilename() {
        return "report_" + userName.replaceAll("\\s+", "_") + ".txt";
    }

    public String toJSON() {
        StringBuilder json = new StringBuilder();
        json.append("{\n");
        json.append("  \"userName\": \"").append(userName).append("\",\n");
        json.append("  \"results\": [\n");

        if (results != null) {
            for (int i = 0; i < results.size(); i++) {
                HealthResult hr = results.get(i);
                json.append("    {\n");
                json.append("      \"type\": \"").append(hr.getCalculatorType()).append("\",\n");
                json.append("      \"value\": ").append(hr.getResultValue()).append(",\n");
                json.append("      \"advice\": \"").append(hr.getAdvice()).append("\",\n");
                json.append("      \"date\": \"").append(hr.getTimestamp()).append("\"\n");
                json.append("    }");
                if (i < results.size() - 1)
                    json.append(",");
                json.append("\n");
            }
        }

        json.append("  ]\n");
        json.append("}");
        return json.toString();
    }

    public String getUserName() {
        return userName;
    }

    public void setUserName(String userName) {
        this.userName = userName;
    }

    public List<HealthResult> getResults() {
        return results;
    }

    public void setResults(List<HealthResult> results) {
        this.results = results;
    }
}
