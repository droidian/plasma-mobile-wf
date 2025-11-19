// SPDX-FileCopyrightText: 2024 Alexander Rutz <arpio@droidian.org>
// SPDX-FileCopyrightText: 2024 Deepak Kumar <notwho53@gmail.com>
// SPDX-License-Identifier: GPL-2.0-or-later

#pragma once

#include <QObject>
#include <qqmlregistration.h>

#include <QLocalSocket>
#include <QDataStream>
#include <QJsonDocument>
#include <QJsonObject>

class WayfireIPC : public QObject
{
    Q_OBJECT
    QML_SINGLETON
    QML_ELEMENT

    Q_PROPERTY(bool hasViewFocused READ hasViewFocused NOTIFY hasViewFocusedChanged)

public:
    WayfireIPC(QObject *parent = nullptr);

    void setFullscreen(int viewId, bool state);
    Q_INVOKABLE void toggleScale();
    Q_INVOKABLE void toggleShowDesktop();
    Q_INVOKABLE void minimizeAllApps();
    Q_INVOKABLE void requestCloseApp();
    bool hasViewFocused();
    
Q_SIGNALS:
    void viewMapped(QString appId);
    void pwrKeyStateChanged(int state);
    void idleTimout();
    void hasViewFocusedChanged();

private Q_SLOTS:
    void onReadData();

private:
    void sendMessage(QJsonDocument jsonDoc);
    void requestFocusedView();

    bool m_hasViewFocused = false;
    int m_focusedViewId;

    QLocalSocket *m_wfsocket = nullptr;
    QDataStream m_in;
};
