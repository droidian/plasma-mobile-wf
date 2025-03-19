// SPDX-FileCopyrightText: 2025 Alexander Rutz <arpio@droidian.org>
// SPDX-License-Identifier: GPL-2.0-or-later

#include <QtWaylandClient/private/qwaylandwindow_p.h>
#include <QtWaylandClient/private/qwaylandscreen_p.h>

#include <extsessionlocksurface.h>

ExtSessionLockSurface::ExtSessionLockSurface(ExtSessionLock *sessionlock, QtWaylandClient::QWaylandWindow *window)
    : QtWaylandClient::QWaylandShellSurface(window)
    , QtWayland::ext_session_lock_surface_v1()
    , m_sessionlock(sessionlock)
    , m_window(window)
{
    connect(m_sessionlock, &ExtSessionLock::locked, this,
                    &ExtSessionLockSurface::onSessionLocked);
}

ExtSessionLockSurface::~ExtSessionLockSurface()
{
    destroy();
}

void ExtSessionLockSurface::onSessionLocked()
{
    init(m_sessionlock->get_lock_surface(m_window->wlSurface(), m_window->waylandScreen()->output()));
}

void ExtSessionLockSurface::ext_session_lock_surface_v1_configure(uint32_t serial, uint32_t width, uint32_t height)
{
    ack_configure(serial);
    m_pendingSize = QSize(width, height);

    if (!m_configured) {
        m_configured = true;
        applyConfigure();
        window()->sendRecursiveExposeEvent();
    } else {
        window()->resizeFromApplyConfigure(m_pendingSize);
    }
}

void ExtSessionLockSurface::applyConfigure()
{
    m_configuring = true;
    window()->resizeFromApplyConfigure(m_pendingSize);
    m_configuring = false;
}

bool ExtSessionLockSurface::isExposed() const
{
    return m_configured;
}