// SPDX-FileCopyrightText: 2025 Alexander Rutz <arpio@droidian.org>
// SPDX-License-Identifier: GPL-2.0-or-later

#pragma once

#include <wayland-client.h>

#include <extsessionlockmanager.h>
#include <qwayland-ext-session-lock-v1.h>

class ExtSessionLockSurface;

class Q_WAYLANDCLIENT_EXPORT ExtSessionLock
    : public QObject
    , public QtWayland::ext_session_lock_v1
{
    Q_OBJECT
public:
    ExtSessionLock(struct ::ext_session_lock_v1 *object);
    ExtSessionLock();
    ~ExtSessionLock();

    QtWaylandClient::QWaylandShellSurface *createLockSurface(QtWaylandClient::QWaylandWindow *window);

Q_SIGNALS:
    void locked();
    void finished();

protected:
    void ext_session_lock_v1_locked() override;
    void ext_session_lock_v1_finished() override;
};