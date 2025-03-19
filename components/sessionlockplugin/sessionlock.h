// SPDX-FileCopyrightText: 2025 Alexander Rutz <arpio@droidian.org>
// SPDX-License-Identifier: GPL-2.0-or-later

#pragma once

#include <QObject>
#include <qqmlregistration.h>
#include <QQuickView>
#include <security/pam_appl.h>
#include <security/pam_modutil.h>
#include <extsessionlockmanager.h>
#include <sessionlocksettings.h>

class SessionLock : public QObject
{
    Q_OBJECT
    QML_SINGLETON
    QML_ELEMENT

    Q_PROPERTY(bool locked READ locked NOTIFY lockedChanged)

public:
    SessionLock(QObject *parent = nullptr);
    Q_INVOKABLE void requestLock();
    Q_INVOKABLE void requestUnlock(QString pwd);
    bool locked();
    
Q_SIGNALS:
    void failed();
    void succeeded();
    void lockedChanged();
    void unlockRequested();

private Q_SLOTS:
    void screenAdded(QScreen *screen);
    void sessionlockMngrActivated();
    
private:
    pam_handle_t *m_pamh = nullptr;
    int authenticate(QString username, QString ro_password);
    int finish_pam_with(int res);
    void unlock();
    void createLockSurface();
    bool m_isLocked = false;
    ExtSessionLockManager *m_sessionMngr = nullptr;
    QList<QQuickView *> m_viewList;
    SessionLockSettings *m_sessionlocksettings = nullptr;
};