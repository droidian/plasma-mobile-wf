// SPDX-FileCopyrightText: 2025 Alexander Rutz <arpio@droidian.org>
// SPDX-License-Identifier: GPL-2.0-or-later

#pragma once

#include <QWindow>
#include <wayland-client.h>
#include <QtWaylandClient/private/qwaylandshellintegration_p.h>
#include <qwayland-ext-session-lock-v1.h>

class ExtSessionLock;

class Q_WAYLANDCLIENT_EXPORT ExtSessionLockManager
    : public QtWaylandClient::QWaylandShellIntegrationTemplate<ExtSessionLockManager>
    , public QtWayland::ext_session_lock_manager_v1
{
public:
    ExtSessionLockManager();
    ~ExtSessionLockManager() override;

    QtWaylandClient::QWaylandShellSurface *createShellSurface(QtWaylandClient::QWaylandWindow *window) override;

    void requestLock();
    void requestUnlock();
    bool setShellIntegrationForWindow(QWindow *window);

Q_SIGNALS:
    void activNow();

private:
    QScopedPointer<ExtSessionLock> m_sessionlock;
};
