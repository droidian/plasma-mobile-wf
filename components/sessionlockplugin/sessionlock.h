// SPDX-FileCopyrightText: 2024 Alexander Rutz <arpio@droidian.org>
// SPDX-License-Identifier: GPL-2.0-or-later

#pragma once

#include <QObject>
#include <QtGui/QWindow>
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

public:
    SessionLockManager(QObject *parent = nullptr);
    Q_INVOKABLE void unlock(QString pwd);
    Q_INVOKABLE void lock();
    Q_INVOKABLE void quitNow();
    
Q_SIGNALS:
    void failed();
    void succeeded();

public Q_SLOTS:

private Q_SLOTS:

private:
    pam_handle_t *m_pamh = nullptr;
    int authenticate(QString username, QString ro_password);
    int finish_pam_with(int res);
};
