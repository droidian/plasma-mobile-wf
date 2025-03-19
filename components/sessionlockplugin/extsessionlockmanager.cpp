// SPDX-FileCopyrightText: 2024 Alexander Rutz <arpio@droidian.org>
// SPDX-License-Identifier: GPL-2.0-or-later

#include <QDebug>

#include <QtWaylandClient/private/qwaylandintegration_p.h>
#include <QtWaylandClient/private/qwaylanddisplay_p.h>
#include <QtWaylandClient/private/qwaylandwindow_p.h>

#include <extsessionlockmanager.h>
#include <extsessionlock.h>

ExtSessionLockManager::ExtSessionLockManager()
    : QWaylandShellIntegrationTemplate<ExtSessionLockManager>(1)
    , m_sessionlock(new ExtSessionLock)
{
}

ExtSessionLockManager::~ExtSessionLockManager()
{   
    destroy();
}

QtWaylandClient::QWaylandShellSurface *ExtSessionLockManager::createShellSurface(QtWaylandClient::QWaylandWindow *window)
{
    return m_sessionlock->createLockSurface(window);
}

bool ExtSessionLockManager::setShellIntegrationForWindow(QWindow *window)
{
    window->create();

    auto waylandWindow = dynamic_cast<QtWaylandClient::QWaylandWindow *>(window->handle());
    if (!waylandWindow) {
        qDebug() << window << "is not a wayland window. Cannot set shell integration.";
        return false;
    }
    waylandWindow->setShellIntegration(this);
    return true;
}

void ExtSessionLockManager::requestLock()
{
    if (isActive()){
        if(!m_sessionlock)
            m_sessionlock.reset(new ExtSessionLock());

        m_sessionlock->init(lock());
    } else{
        qDebug()<<"Cannot lock session, ExtSessionLockManager not activated";
    }
}

void ExtSessionLockManager::requestUnlock()
{
    m_sessionlock->unlock_and_destroy();
    QtWaylandClient::QWaylandIntegration::instance()->display()->forceRoundTrip();
    m_sessionlock.reset(new ExtSessionLock());
}
