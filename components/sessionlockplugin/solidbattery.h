// SPDX-FileCopyrightText: 2025 Alexander Rutz <arpio@droidian.org>
// SPDX-License-Identifier: GPL-2.0-or-later

#pragma once

#include <QObject>
#include <qqmlregistration.h>
#include <Solid/Battery>
#include <Solid/Device>
#include <QVariant>

class SolidBattery : public QObject {
	Q_OBJECT
    QML_SINGLETON
    QML_ELEMENT

	Q_PROPERTY(QVariant primary READ get_primary NOTIFY primaryChanged)

public:
	SolidBattery(QObject *parent = nullptr);

	Q_INVOKABLE void initBattery();

	QVariant get_primary();

Q_SIGNALS:
    void primaryChanged();

private Q_SLOTS:

private:
	QVariant m_primary;
};