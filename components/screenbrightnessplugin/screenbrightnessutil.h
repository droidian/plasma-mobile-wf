// SPDX-FileCopyrightText: 2024 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: GPL-2.0-or-later

#pragma once

#include <QObject>
#include <qqmlregistration.h>
#include <libdroid/leds.h>

/**
 * Utility class that provides useful functions related to screen brightness.
 *
 * @author Devin Lin <devin@kde.org>
 **/
class ScreenBrightnessUtil : public QObject
{
    Q_OBJECT
    Q_PROPERTY(int brightness READ brightness WRITE setBrightness NOTIFY brightnessChanged);
    Q_PROPERTY(int maxBrightness READ maxBrightness NOTIFY maxBrightnessChanged)
    Q_PROPERTY(bool brightnessAvailable READ brightnessAvailable NOTIFY brightnessAvailableChanged)
    QML_ELEMENT

public:
    ScreenBrightnessUtil(QObject *parent = nullptr);
    ~ScreenBrightnessUtil();

    int brightness() const;
    void setBrightness(int brightness);

    int maxBrightness() const;

    bool brightnessAvailable() const;

Q_SIGNALS:
    void brightnessChanged();
    void maxBrightnessChanged();
    void brightnessAvailableChanged();

private:
    DroidLeds *m_droidLeds;
    int m_brightness{0};
    int m_maxBrightness{255};
};
