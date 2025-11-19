// SPDX-FileCopyrightText: 2024 Alexander Rutz <arpio@droidian.org>
// SPDX-License-Identifier: GPL-2.0-or-later

#include <QDebug>
#include <QProximitySensor>
#include <QProximityReading>

#include "sensors.h"

Sensors::Sensors(QObject *parent)
    : QObject{parent}
{
    QProximitySensor *proxSensor = new QProximitySensor(this);
    connect(proxSensor, &QProximitySensor::readingChanged, this, [=]() {
        QProximityReading *reading = proxSensor->reading();
        if (reading)
            emit proximityChanged(reading->close());
    });
    proxSensor->start();
}
