// SPDX-FileCopyrightText: 2024 Alexander Rutz <arpio@droidian.org>
// SPDX-License-Identifier: GPL-2.0-or-later

#include <QDebug>
#include <QtGui/QGuiApplication>
#include <QQmlContext>
#include <QTimer>
#include "sessionlock.h"

using namespace ExtSessionLockV1Qt;

static int conversation(int num_msg, const struct pam_message **msg, struct pam_response **resp, void *data)
{
    Q_UNUSED(msg);
    
    if (num_msg < 1)
        return PAM_CONV_ERR;

    *resp = static_cast<struct pam_response *>(calloc(num_msg, sizeof(struct pam_response)));

    if (*resp == 0)
        return PAM_SYSTEM_ERR;

    for (int i = 0; i < num_msg; i++) {
        struct pam_response *reply = &(*resp[i]);
        reply->resp = strdup((const char*) data);
        reply->resp_retcode = 0;
    }
    return PAM_SUCCESS;
}

SessionLockManager::SessionLockManager(QObject *parent)
    : QObject{parent}
{
    ExtSessionLockV1Qt::Shell::useExtSessionLock();
    qDebug() << "ok-init";
}

void SessionLockManager::unlock(QString pwd)
{
    if(authenticate("droidian", pwd)){
        Q_EMIT failed();
        return;
    }
    Q_EMIT succeeded();
}

void SessionLockManager::lock()
{
    qDebug() << "ok-lock";
    auto screens = QGuiApplication::screens();
    int i        = 0;
    for (auto screen : screens) {
        QQuickView *view = new QQuickView;
        view->setSource(QUrl(QStringLiteral("qrc:/Main.qml")));
        view->setResizeMode(QQuickView::SizeRootObjectToView);
        view->rootContext()->setContextProperty("PlamoLock", this);
        view->setColor(QColor(Qt::transparent));
        Window::registerWindowFromQtScreen(view, screen);
        view->showFullScreen();
        i += 1;
    }
    Command::instance()->LockScreen();
}

void SessionLockManager::quitNow()
{
    Command::instance()->unLockScreen();
}

int SessionLockManager::authenticate(QString username, QString ro_password)
{
    struct passwd *pw;
    int ret = 1;

    if ((pw = getpwnam(username.toStdString().c_str())) == NULL)
        return 2;

    const struct pam_conv conv = { conversation, (void *) ro_password.toStdString().c_str() };

    if ((ret = pam_start("common-auth", pw->pw_name, &conv, &m_pamh)) != PAM_SUCCESS)
        return finish_pam_with(ret);

    if ((ret = pam_authenticate(m_pamh, 0)) != PAM_SUCCESS)
        return finish_pam_with(ret);

    if ((ret = pam_acct_mgmt(m_pamh, 0)) != PAM_SUCCESS)
        return finish_pam_with(ret);

    return finish_pam_with(PAM_SUCCESS);
}

int SessionLockManager::finish_pam_with(int value)
{
    if (pam_end(m_pamh, value) != PAM_SUCCESS)
        return 5;
    return value;
}
