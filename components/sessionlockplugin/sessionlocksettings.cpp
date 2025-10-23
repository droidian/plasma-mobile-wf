// SPDX-FileCopyrightText: 2025 Alexander Rutz <arpio@droidian.org>
// SPDX-License-Identifier: GPL-2.0-or-later

#include <sessionlocksettings.h>

SessionLockSettings::SessionLockSettings(QObject *parent)
    : QObject{parent}
    , m_config{KSharedConfig::openConfig(m_confFile, KConfig::SimpleConfig)}
{
    m_configWatcher = KConfigWatcher::create(m_config);
    connect(m_configWatcher.data(), &KConfigWatcher::configChanged, this, &SessionLockSettings::onConfigChanged);
}

QString SessionLockSettings::wallpaperFile()
{
	auto group = KConfigGroup{m_config, m_confGrpGeneral};
	if(!group.hasKey("wallpaperFile"))
		setWallpaperFile("/usr/share/wallpapers/DebianTheme/contents/images/1920x1080.svg");

    return group.readEntry("wallpaperFile", "/usr/share/wallpapers/DebianTheme/contents/images/1920x1080.svg");
}

void SessionLockSettings::setWallpaperFile(QString file)
{
    auto group = KConfigGroup{m_config, m_confGrpGeneral};
    group.writeEntry("wallpaperFile", file, KConfigGroup::Notify);
    m_config->sync();
}

bool SessionLockSettings::preloadSurface()
{
	auto group = KConfigGroup{m_config, m_confGrpGeneral};
	if(!group.hasKey("preloadSurface"))
		setPreloadSurface(false);

    return group.readEntry("preloadSurface", false);
}

void SessionLockSettings::setPreloadSurface(bool preload)
{
    auto group = KConfigGroup{m_config, m_confGrpGeneral};
    group.writeEntry("preloadSurface", preload, KConfigGroup::Notify);
    m_config->sync();
}

bool SessionLockSettings::showNetworkTraffic()
{
	auto group = KConfigGroup{m_config, m_confGrpGeneral};
	if(!group.hasKey("showNetworkTraffic"))
		setShowNetworkTraffic(true);

    return group.readEntry("showNetworkTraffic", true);
}

void SessionLockSettings::setShowNetworkTraffic(bool show)
{
    auto group = KConfigGroup{m_config, m_confGrpGeneral};
    group.writeEntry("showNetworkTraffic", show, KConfigGroup::Notify);
    m_config->sync();
}

bool SessionLockSettings::showChargingInfo()
{
	auto group = KConfigGroup{m_config, m_confGrpGeneral};
	if(!group.hasKey("showChargingInfo"))
		setShowChargingInfo(true);

    return group.readEntry("showChargingInfo", true);
}

void SessionLockSettings::setShowChargingInfo(bool show)
{
    auto group = KConfigGroup{m_config, m_confGrpGeneral};
    group.writeEntry("showChargingInfo", show, KConfigGroup::Notify);
    m_config->sync();
}

bool SessionLockSettings::movingClock()
{
	auto group = KConfigGroup{m_config, m_confGrpGeneral};
	if(!group.hasKey("movingClock"))
		setMovingClock(false);

    return group.readEntry("movingClock", false);
}

void SessionLockSettings::setMovingClock(bool moving)
{
    auto group = KConfigGroup{m_config, m_confGrpGeneral};
    group.writeEntry("movingClock", moving, KConfigGroup::Notify);
    m_config->sync();
}

void SessionLockSettings::onConfigChanged(const KConfigGroup &group, const QByteArrayList &names)
{
	if (group.name() == m_confGrpGeneral) {
		if(names.contains("wallpaperFile"))
			Q_EMIT wallpaperFileChanged();

		if(names.contains("preloadSurface"))
			Q_EMIT preloadSurfaceChanged();

		if(names.contains("showNetworkTraffic"))
			Q_EMIT showNetworkTrafficChanged();

		if(names.contains("showChargingInfo"))
			Q_EMIT showChargingInfoChanged();

		if(names.contains("movingClock"))
			Q_EMIT movingClockChanged();
	}
}