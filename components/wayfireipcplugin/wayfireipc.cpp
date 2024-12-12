// SPDX-FileCopyrightText: 2024 Alexander Rutz <arpio@droidian.org>
// SPDX-License-Identifier: GPL-2.0-or-later

#include <QDebug>
#include <QJsonDocument>
#include <QJsonObject>

#include "wayfireipc.h"

WayfireIPC::WayfireIPC(QObject *parent)
    : QObject{parent}
{
    m_wfsocket = new QLocalSocket();
    m_in.setDevice(m_wfsocket);
    m_in.setVersion(QDataStream::Qt_6_7);
    m_in.setByteOrder(QDataStream::LittleEndian);

    connect(m_wfsocket, &QLocalSocket::readyRead, this, &WayfireIPC::onReadData);

    m_wfsocket->connectToServer("/tmp/wayfire-wayland-1.socket");
    if (m_wfsocket->waitForConnected(1000)){
        qDebug()<<"Connected to wayfire socket!";
    }

    QJsonObject jsonObj { {"method", "window-rules/events/watch"}, };
    QJsonDocument jsonDoc = QJsonDocument(jsonObj);

    std::string msgString = jsonDoc.toJson(QJsonDocument::Compact).toStdString();

    QDataStream out;
    out.setDevice(m_wfsocket);
    out.setVersion(QDataStream::Qt_6_7);
    out.setByteOrder(QDataStream::LittleEndian);
    out.writeBytes(msgString.c_str(), msgString.size());
}

void WayfireIPC::onReadData()
{
    qint64 bytesToRead = m_wfsocket->bytesAvailable();

    while(bytesToRead > 0){
        char *data;
        m_in.readBytes(data, bytesToRead);

        QJsonDocument msg = QJsonDocument::fromJson(QString(data).toUtf8());

        if(msg.object().value("event") == "view-mapped")
            Q_EMIT viewMapped(msg.object().value("view").toObject().value("app-id").toString());

        bytesToRead = m_wfsocket->bytesAvailable();
        delete data;
    }
}