// SPDX-FileCopyrightText: 2024 Alexander Rutz <arpio@droidian.org>
// SPDX-License-Identifier: GPL-2.0-or-later

#pragma once

#include <QObject>
#include <qqmlregistration.h>
#include <QtGui/QWindow>
#include <QtGui/QGuiApplication>
#include <QQuickView>
#include <qt-session-lock/src/interfaces/command.h>
#include <qt-session-lock/src/interfaces/shell.h>
#include <qt-session-lock/src/interfaces/window.h>
#include <security/pam_appl.h>
#include <security/pam_modutil.h>

class SessionLockManager : public QObject
{
    Q_OBJECT
    QML_SINGLETON
    QML_ELEMENT

    Q_PROPERTY(bool locked READ locked NOTIFY lockedChanged)

public:
    SessionLockManager(QObject *parent = nullptr);
    Q_INVOKABLE void requestUnlock(QString pwd);
    Q_INVOKABLE void lock(QWindow *window);
    bool locked();
    
Q_SIGNALS:
    void failed();
    void succeeded();
    void lockedChanged();

public Q_SLOTS:

private Q_SLOTS:
    void screenAdded(QScreen *screen);
private:
    pam_handle_t *m_pamh = nullptr;
    int authenticate(QString username, QString ro_password);
    int finish_pam_with(int res);
    void unlock();
    bool m_isLocked = false;
};
