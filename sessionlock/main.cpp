// SPDX-FileCopyrightText: 2024 Alexander Rutz <arpio@droidian.org>
// SPDX-License-Identifier: LGPL-2.0-or-later

#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <kdsingleapplication.h>
#include "sessionlock.h"

int main(int argc, char *argv[])
{
    ExtSessionLockV1Qt::Shell::useExtSessionLock();

    QGuiApplication app(argc, argv);
    KDSingleApplication kdsa;

    if (kdsa.isPrimaryInstance()) {
        SessionLockManager *sessionlock = new SessionLockManager(&app);
        sessionlock->lock();
    } else {
        qDebug()<<"Another SessionLock instance running. Exit.";
        return 0;
    }
    return app.exec();
}
