package com.nutech.sehatconnect.model;

import com.nutech.sehatconnect.entity.HealthResult;

//interface
public interface Advisable {
    String giveAdvice(double result);

    String giveAdvice(HealthResult hr);
}
