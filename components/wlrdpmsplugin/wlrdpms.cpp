// SPDX-FileCopyrightText: 2024 Alexander Rutz <arpio@droidian.org>
// SPDX-License-Identifier: GPL-2.0-or-later

#include <QDebug>

#include "wlrdpms.h"

WlrDpmsManagerV1::WlrDpmsManagerV1()
    : QWaylandClientExtensionTemplate(/* Supported protocol version */ 1)
{
    connect(this, &WlrDpmsManagerV1::activeChanged, this,
       &WlrDpmsManagerV1::handleExtensionActive);
}

void WlrDpmsManagerV1::dpmsInit()
{
    qDebug()<<"WlrDpmsManagerV1 initializing";
}

bool WlrDpmsManagerV1::pwrOn()
{
    return m_pwrOn;
}

void WlrDpmsManagerV1::setPwrOn(bool state)
{
    if(m_wlrdpms != nullptr)
        m_wlrdpms->set_mode((uint32_t) state);
}

void WlrDpmsManagerV1::handleExtensionActive()
{
    m_wlrdpms = new WlrDpmsV1(
                        this,
                        get_output_power(static_cast<QtWaylandClient::QWaylandScreen *>(
                            qApp->screens().first()->handle())
                            ->output()));

    connect(m_wlrdpms, &WlrDpmsV1::stateChanged, this,
       &WlrDpmsManagerV1::stateChanged);

    if(m_wlrdpms != nullptr)
        m_wlrdpms->set_mode(1);
}

void WlrDpmsManagerV1::stateChanged(bool state)
{
    if(m_pwrOn != state){
        m_pwrOn = state;
        Q_EMIT pwrOnChanged();
    }
}

WlrDpmsV1::WlrDpmsV1(WlrDpmsManagerV1 *manager,
              struct ::zwlr_output_power_v1 *wl_object)
    : QWaylandClientExtensionTemplate<WlrDpmsV1>(1)
    , QtWayland::zwlr_output_power_v1(wl_object)
    , m_wpmsmanager(manager)
{
}

void WlrDpmsV1::zwlr_output_power_v1_mode(uint32_t mode)
{
    Q_EMIT stateChanged((bool) mode);
}

void WlrDpmsV1::zwlr_output_power_v1_failed()
{
    qDebug()<<"SETTING MODE FAILED";
}