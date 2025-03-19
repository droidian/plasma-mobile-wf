// SPDX-FileCopyrightText: 2025 Alexander Rutz <arpio@droidian.org>
// SPDX-License-Identifier: GPL-2.0-or-later

#include <extsessionlock.h>
#include <extsessionlocksurface.h>

ExtSessionLock::ExtSessionLock(struct ::ext_session_lock_v1 *object)
    : QtWayland::ext_session_lock_v1(object)
{
}

ExtSessionLock::ExtSessionLock()
    : QtWayland::ext_session_lock_v1()
{
}

ExtSessionLock::~ExtSessionLock()
{
}

QtWaylandClient::QWaylandShellSurface *ExtSessionLock::createLockSurface(QtWaylandClient::QWaylandWindow *window)
{
    return new ExtSessionLockSurface(this, window);
}

void ExtSessionLock::ext_session_lock_v1_locked()
{
    Q_EMIT locked();
}

void ExtSessionLock::ext_session_lock_v1_finished()
{
    qDebug()<<"ext_session_lock_v1_finished()";
    Q_EMIT finished();
}