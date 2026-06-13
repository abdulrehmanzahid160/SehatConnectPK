package com.nutech.sehatconnect.model;

import java.util.ArrayList;
import java.util.List;

public class MedicineReminder {
    private List<Medicine> medicines;

    public MedicineReminder() {
        this.medicines = new ArrayList<>();
    }

    public void addMedicine(String name, String dosage, String timing) {
        medicines.add(new Medicine(name, dosage, timing));
    }

    public void removeMedicine(String name) {
        medicines.removeIf(m -> m.getName().equalsIgnoreCase(name));
    }

    public List<Medicine> getMedicines() {
        return medicines;
    }

    public class Medicine {
        private String name;
        private String dosage;
        private String timing; // Morning, Afternoon, Evening, Night

        public Medicine(String name, String dosage, String timing) {
            this.name = name;
            this.dosage = dosage;
            this.timing = timing;
        }

        public String getName() {
            return name;
        }

        public void setName(String name) {
            this.name = name;
        }

        public String getDosage() {
            return dosage;
        }

        public void setDosage(String dosage) {
            this.dosage = dosage;
        }

        public String getTiming() {
            return timing;
        }

        public void setTiming(String timing) {
            this.timing = timing;
        }
    }
}
