// SPDX-FileCopyrightText: 2024 Devin Lin <devin@kde.org>
// SPDX-FileCopyrightText: 2024 Deepak Kumar <notwho53@gmail.com>
// SPDX-License-Identifier: GPL-2.0-or-later

#include "screenbrightnessutil.h"
#include <QDebug>

ScreenBrightnessUtil::ScreenBrightnessUtil(QObject *parent)
    : QObject{parent}
{
    m_droidLeds = droid_leds_new();
    
    if (droid_leds_is_kind_supported(m_droidLeds, DROID_LEDS_KIND_BACKLIGHT)) {
		setBrightness(200);
        Q_EMIT brightnessAvailableChanged();
    } else {
        qWarning() << "Backlight not supported by libdroid";
        m_droidLeds = nullptr;
    }
}

ScreenBrightnessUtil::~ScreenBrightnessUtil()
{
    if (m_droidLeds) {
        g_object_unref(m_droidLeds);
    }
}

int ScreenBrightnessUtil::brightness() const
{
    return m_brightness;
}

void ScreenBrightnessUtil::setBrightness(int brightness)
{
    if (!m_droidLeds) return;

    brightness = qBound(0, brightness, m_maxBrightness);
    
    if (droid_leds_set_backlight(m_droidLeds, brightness, TRUE)) {
        m_brightness = brightness;
        Q_EMIT brightnessChanged();
    } else {
        qWarning() << "Failed to set backlight brightness";
    }
}

int ScreenBrightnessUtil::maxBrightness() const
{
    return m_maxBrightness;
}

bool ScreenBrightnessUtil::brightnessAvailable() const
{
    return m_droidLeds != nullptr;
}
