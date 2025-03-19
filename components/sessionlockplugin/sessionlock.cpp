// SPDX-FileCopyrightText: 2025 Alexander Rutz <arpio@droidian.org>
// SPDX-License-Identifier: GPL-2.0-or-later

#include <QDebug>
#include <QQmlContext>
#include <QQmlEngine>
#include <QTimer>

#include <sessionlock.h>

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

SessionLock::SessionLock(QObject *parent)
    : QObject{parent}
{
    m_sessionlocksettings = new SessionLockSettings();

    if(m_sessionMngr == nullptr){
        m_sessionMngr = new ExtSessionLockManager();

        connect(m_sessionMngr, &ExtSessionLockManager::activeChanged, this,
                    &SessionLock::sessionlockMngrActivated);
    }

    connect(qApp, &QGuiApplication::screenAdded, this,
                &SessionLock::screenAdded);
}

void SessionLock::requestLock()
{
    if(m_isLocked || !m_sessionMngr->isActive()){
        return;
    }

    if(m_viewList.empty())
        createLockSurface();

    if(m_sessionMngr != nullptr){
        m_sessionMngr->requestLock();
    }
    
    m_isLocked = true;
    Q_EMIT lockedChanged();
}

void SessionLock::requestUnlock(QString pwd)
{
    Q_EMIT unlockRequested();
    if(authenticate("droidian", pwd)){
        Q_EMIT failed();
        return;
    }
    Q_EMIT succeeded();
    QTimer::singleShot(200, this, &SessionLock::unlock);
}

bool SessionLock::locked()
{
    return m_isLocked;
}

void SessionLock::unlock()
{
    m_sessionMngr->requestUnlock();
    m_isLocked = false;

    if(!m_viewList.empty()){
        for (auto *view : m_viewList){
            delete view;
        }
        m_viewList.clear();
    }

    if(m_sessionlocksettings->preloadSurface())
        createLockSurface();

    Q_EMIT lockedChanged();
}

void SessionLock::createLockSurface()
{
    if(!m_viewList.empty()){
        for (auto *view : m_viewList){
            delete view;
        }
        m_viewList.clear();
    }
    
    for (auto screen : QGuiApplication::screens()) {
        QQuickView *view  = new QQuickView(QQmlEngine::contextForObject(this)->engine(), nullptr);
        if(!m_sessionMngr->setShellIntegrationForWindow(view)){
            qDebug()<<"Failed to set shell integration for"<<view;
            delete view;
            return;
        }
        view->loadFromModule("org.kde.plasma.private.mobileshell.sessionlockplugin", "Main");
        view->rootContext()->setContextProperty("SessionLock", this);
        view->setColor(QColor(Qt::transparent));
        view->setScreen(screen);
        view->setResizeMode(QQuickView::SizeRootObjectToView);
        view->showFullScreen();
        m_viewList.append(view);
    }
}

int SessionLock::authenticate(QString username, QString ro_password)
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

int SessionLock::finish_pam_with(int value)
{
    if (pam_end(m_pamh, value) != PAM_SUCCESS)
        return 5;
    return value;
}

void SessionLock::screenAdded(QScreen *screen)
{
    qDebug()<<"SCREEN ADDED, NOT IMPLEMENTED!!!";
}

void SessionLock::sessionlockMngrActivated()
{
    requestLock();
}