// SPDX-FileCopyrightText: 2024 Alexander Rutz <arpio@droidian.org>
// SPDX-FileCopyrightText: 2024 Deepak Kumar <notwho53@gmail.com>
// SPDX-License-Identifier: GPL-2.0-or-later

#include <QDebug>

#include "wayfireipc.h"

WayfireIPC::WayfireIPC(QObject *parent)
    : QObject{parent}
{
    m_wfsocket = new QLocalSocket();
    m_in.setDevice(m_wfsocket);
    m_in.setVersion(QDataStream::Qt_6_7);
    m_in.setByteOrder(QDataStream::LittleEndian);

    connect(m_wfsocket, &QLocalSocket::readyRead, this, &WayfireIPC::onReadData);

    QString socket_str = qgetenv("WAYFIRE_SOCKET");

    if (socket_str != "")
        m_wfsocket->connectToServer(socket_str);
    
    if (m_wfsocket->waitForConnected(1000)){
        QJsonObject jsonObj { {"method", "window-rules/events/watch"}, };
        QJsonDocument jsonDoc = QJsonDocument(jsonObj);
        sendMessage(jsonDoc);
    }
}

void WayfireIPC::setFullscreen(int viewId, bool state)
{
    QJsonObject msgObj;
    QJsonObject dataObj;
    
    dataObj["view_id"] = viewId;
    dataObj["state"] = state;

    msgObj["method"] = "wm-actions/set-fullscreen";
    msgObj["data"] = dataObj;

    QJsonDocument jsonDoc = QJsonDocument(msgObj);
    sendMessage(jsonDoc);
}

void WayfireIPC::toggleShowDesktop()
{
    QJsonObject msgObj;
    msgObj["method"] = "wm-actions/plamo_showdesktop";

    QJsonDocument jsonDoc = QJsonDocument(msgObj);
    sendMessage(jsonDoc);
    anyAppFocused = false;
}

void WayfireIPC::toggleScale()
{
    QJsonObject msgObj;
    msgObj["method"] = "scale/toggle";

    QJsonDocument jsonDoc = QJsonDocument(msgObj);
    sendMessage(jsonDoc);
}

void WayfireIPC::stipcBtn(int buttonCode, const QString& mode, bool modifier)
{
    QJsonObject msgObj;
    QJsonObject dataObj;
    
    dataObj["button_code"] = buttonCode;
    dataObj["mode"] = mode;
    dataObj["modifier"] = modifier;

    msgObj["method"] = "stipc/feed_button";
    msgObj["data"] = dataObj;

    QJsonDocument jsonDoc = QJsonDocument(msgObj);
    sendMessage(jsonDoc);
}

bool WayfireIPC::isAnyAppFocused()
{
    return anyAppFocused;
}

void WayfireIPC::onReadData()
{
    qint64 bytesToRead = m_wfsocket->bytesAvailable();

    while(bytesToRead > 0){
        char *data;
        m_in.readBytes(data, bytesToRead);

        QJsonDocument msg = QJsonDocument::fromJson(QString(data).toUtf8());

        QString event = msg.object().value("event").toString();
        QString appId = msg.object().value("view").toObject().value("app-id").toString();
        int viewId = msg.object().value("view").toObject().value("id").toInt();

        if(event == "view-mapped" && appId != ""){
            Q_EMIT viewMapped(appId);
        } else if(event == "view-focused" && appId != ""){
            anyAppFocused = true;
            if (appId == "org.kde.polkit-kde-authentication-agent-1") {
                setFullscreen(viewId, false);
            }
        }

        bytesToRead = m_wfsocket->bytesAvailable();
        delete data;
    }
}

void WayfireIPC::sendMessage(QJsonDocument jsonDoc)
{
    std::string msgString = jsonDoc.toJson(QJsonDocument::Compact).toStdString();
    qDebug() << "Sending message:" << QString::fromStdString(msgString);

    QDataStream out;
    out.setDevice(m_wfsocket);
    out.setVersion(QDataStream::Qt_6_7);
    out.setByteOrder(QDataStream::LittleEndian);
    out.writeBytes(msgString.c_str(), msgString.size());
}
