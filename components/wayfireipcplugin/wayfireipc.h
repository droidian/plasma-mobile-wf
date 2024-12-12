// SPDX-FileCopyrightText: 2024 Alexander Rutz <arpio@droidian.org>
// SPDX-License-Identifier: GPL-2.0-or-later

#pragma once

#include <QObject>
#include <qqmlregistration.h>

#include <QLocalSocket>
#include <QDataStream>

class WayfireIPC : public QObject
{
    Q_OBJECT
    QML_SINGLETON
    QML_ELEMENT

public:
    WayfireIPC(QObject *parent = nullptr);
    
Q_SIGNALS:
    void viewMapped(QString appId);

private Q_SLOTS:
    void onReadData();

private:
    QLocalSocket *m_wfsocket = nullptr;
    QDataStream m_in;
};