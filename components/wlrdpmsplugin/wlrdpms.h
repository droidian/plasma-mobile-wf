// SPDX-FileCopyrightText: 2024 Alexander Rutz <arpio@droidian.org>
// SPDX-License-Identifier: GPL-2.0-or-later

#pragma once

#include <QObject>
#include <qqmlregistration.h>

#include <QtWaylandClient/QWaylandClientExtension>
#include <QtWaylandClient/private/qwaylanddisplay_p.h>
#include <QtWaylandClient/private/qwaylandinputdevice_p.h>
#include <QtWaylandClient/private/qwaylandscreen_p.h>
#include "qwayland-wlr-output-power-management-unstable-v1.h"

class WlrDpmsV1;

class WlrDpmsManagerV1
    : public QWaylandClientExtensionTemplate<WlrDpmsManagerV1>,
      public QtWayland::zwlr_output_power_manager_v1

{
    Q_OBJECT
    QML_SINGLETON
    QML_ELEMENT

    Q_PROPERTY(bool pwrOn READ pwrOn NOTIFY pwrOnChanged)

public:
    WlrDpmsManagerV1();
    bool pwrOn();
    void setPwrOn(bool state);

public slots:
    void handleExtensionActive();
    
Q_SIGNALS:
    void pwrOnChanged();

private Q_SLOTS:

private:
    WlrDpmsV1 *m_wlrdpms = nullptr;
    bool m_pwrOn = false;
};

class WlrDpmsV1
    : public QWaylandClientExtensionTemplate<WlrDpmsV1>,
      public QtWayland::zwlr_output_power_v1{
    Q_OBJECT
public:
    WlrDpmsV1(WlrDpmsManagerV1 *manager,
              struct ::zwlr_output_power_v1 *wl_object);

protected:
    virtual void zwlr_output_power_v1_mode(uint32_t mode) override;
    virtual void zwlr_output_power_v1_failed() override;

private:
    WlrDpmsManagerV1 *m_wpmsmanager;
};