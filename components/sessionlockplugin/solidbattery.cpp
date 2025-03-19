// SPDX-FileCopyrightText: 2025 Alexander Rutz <arpio@droidian.org>
// SPDX-License-Identifier: GPL-2.0-or-later

#include <QDebug>
#include <Solid/DeviceNotifier>

#include <solidbattery.h>

SolidBattery::SolidBattery(QObject *parent)
	: QObject(parent)
{
}

void SolidBattery::initBattery()
{
    for (Solid::Device dev : Solid::Device::listFromType(Solid::DeviceInterface::Battery)) {
        if(dev.as<Solid::Battery>()->type() == Solid::Battery::PrimaryBattery)
            m_primary = QVariant::fromValue(dev.as<Solid::Battery>());

        Q_EMIT primaryChanged();
    }
}

QVariant SolidBattery::get_primary(){
    return m_primary;
}