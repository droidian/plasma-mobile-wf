/*
 * SPDX-FileCopyrightText: 2020 Han Young <hanyoung@protonmail.com>
 * SPDX-FileCopyrightText: 2022 by Devin Lin <devin@kde.org>
 *
 * SPDX-License-Identifier: GPL-2.0-or-later
 */

#include "flashlightutil.h"

#include <QDBusReply>
#include <QDBusVariant>
#include <QDebug>

FlashlightUtil::FlashlightUtil(QObject *parent)
    : QObject(parent)
    , m_isAvailable(false)
    , m_torchEnabled(false)
{
    QDBusConnection bus = QDBusConnection::sessionBus();
    if (!bus.isConnected()) {
        qWarning() << "No session bus available";
        return;
    }

    m_iface = new QDBusInterface(
        "org.droidian.Flashlightd",
        "/org/droidian/Flashlightd",
        "org.droidian.Flashlightd",
        bus,
        this
    );

    if (!m_iface->isValid()) {
        qWarning() << "Cannot create interface:"
                   << bus.lastError().message();
        return;
    }

    QDBusInterface propsIface(
        "org.droidian.Flashlightd",
        "/org/droidian/Flashlightd",
        "org.freedesktop.DBus.Properties",
        bus
    );

    QDBusReply<QVariant> reply = propsIface.call(
        "Get",
        "org.droidian.Flashlightd",
        "Brightness"
    );

    if (reply.isValid()) {
        int brightness = reply.value().toInt();
        m_torchEnabled = brightness != 0;
        m_isAvailable = true;
    } else {
        qWarning() << "Failed to read Brightness from flashlightd"
                   << reply.error().message();
    }
}

FlashlightUtil::~FlashlightUtil() = default;

void FlashlightUtil::toggleTorch()
{
    if (!m_iface || !m_iface->isValid()) {
        qWarning() << "Flashlight D-Bus interface invalid";
        return;
    }

    int newValue = m_torchEnabled ? 0 : 1;

    QDBusReply<void> reply = m_iface->call("SetBrightness", static_cast<uint>(newValue));
    if (!reply.isValid()) {
        qWarning() << "Failed to call SetBrightness:"
                   << reply.error().message();
        return;
    }

    m_torchEnabled = !m_torchEnabled;
    Q_EMIT torchChanged(m_torchEnabled);
}

bool FlashlightUtil::torchEnabled() const
{
    return m_torchEnabled;
}

bool FlashlightUtil::isAvailable() const
{
    return m_isAvailable;
}