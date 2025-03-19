// SPDX-FileCopyrightText: 2025 Alexander Rutz <arpio@droidian.org>
// SPDX-License-Identifier: GPL-2.0-or-later

#pragma once

#include <QObject>
#include <KConfigGroup>
#include <KConfigWatcher>
#include <KSharedConfig>
#include <qqmlregistration.h>

class SessionLockSettings : public QObject
{
    Q_OBJECT
    QML_SINGLETON
    QML_ELEMENT

    Q_PROPERTY(QString wallpaperFile READ wallpaperFile WRITE setWallpaperFile NOTIFY wallpaperFileChanged)
    Q_PROPERTY(bool preloadSurface READ preloadSurface WRITE setPreloadSurface NOTIFY preloadSurfaceChanged)
    Q_PROPERTY(bool showNetworkTraffic READ showNetworkTraffic WRITE setShowNetworkTraffic NOTIFY showNetworkTrafficChanged)
    Q_PROPERTY(bool showChargingInfo READ showChargingInfo WRITE setShowChargingInfo NOTIFY showChargingInfoChanged)
    Q_PROPERTY(bool movingClock READ movingClock WRITE setMovingClock NOTIFY movingClockChanged)

public:
	SessionLockSettings(QObject *parent = nullptr);

	QString wallpaperFile();
	void setWallpaperFile(QString file);

	bool preloadSurface();
	void setPreloadSurface(bool preload);

	bool showNetworkTraffic();
	void setShowNetworkTraffic(bool show);

	bool showChargingInfo();
	void setShowChargingInfo(bool show);

	bool movingClock();
	void setMovingClock(bool moving);
    
Q_SIGNALS:
	void wallpaperFileChanged();
	void preloadSurfaceChanged();
	void showNetworkTrafficChanged();
	void showChargingInfoChanged();
	void movingClockChanged();

private Q_SLOTS:
	void onConfigChanged(const KConfigGroup &group, const QByteArrayList &names);
    
private:
	QString m_confFile = QStringLiteral("plasma-sessionlockrc");
	QString m_confGrpGeneral = QStringLiteral("General");

	KConfigWatcher::Ptr m_configWatcher;
    KSharedConfig::Ptr m_config;
};