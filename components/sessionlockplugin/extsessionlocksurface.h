// SPDX-FileCopyrightText: 2025 Alexander Rutz <arpio@droidian.org>
// SPDX-License-Identifier: GPL-2.0-or-later

#pragma once

#include <QtWaylandClient/private/qwaylandshellsurface_p.h>

#include <extsessionlock.h>
#include <qwayland-ext-session-lock-v1.h>

class ExtSessionLock;

class Q_WAYLANDCLIENT_EXPORT ExtSessionLockSurface
    : public QtWaylandClient::QWaylandShellSurface
    , public QtWayland::ext_session_lock_surface_v1
{
    Q_OBJECT
public:
    ExtSessionLockSurface(ExtSessionLock *sessionlock, QtWaylandClient::QWaylandWindow *window);
    ~ExtSessionLockSurface() override;

    void applyConfigure() override;
    bool isExposed() const override;

private Q_SLOTS:
    void onSessionLocked();

private:
    void ext_session_lock_surface_v1_configure(uint32_t serial, uint32_t width, uint32_t height) override;

    ExtSessionLock *m_sessionlock;
    QtWaylandClient::QWaylandWindow *m_window;
    QSize m_pendingSize;

    bool m_configured = false;
    bool m_configuring = false;
};