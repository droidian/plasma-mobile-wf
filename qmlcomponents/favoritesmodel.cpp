/*
 *   Copyright 2015 by Marco Martin <mart@kde.org>

 *   This program is free software; you can redistribute it and/or modify
 *   it under the terms of the GNU Library General Public License as
 *   published by the Free Software Foundation; either version 2, or
 *   (at your option) any later version.
 *
 *   This program is distributed in the hope that it will be useful,
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *   GNU General Public License for more details
 *
 *   You should have received a copy of the GNU Library General Public
 *   License along with this program; if not, write to the
 *   Free Software Foundation, Inc.,
 *   51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
 */

#include "favoritesmodel.h"

#include <QDebug>

FavoritesModel::FavoritesModel(QObject *parent)
    : QIdentityProxyModel(parent)
{
}

FavoritesModel::~FavoritesModel()
{
}

QHash<int, QByteArray> FavoritesModel::roleNames() const
{
    return sourceModel()->roleNames();
}

int FavoritesModel::rowCount(const QModelIndex &parent) const
{return QIdentityProxyModel::rowCount(parent);
    return qMin(QIdentityProxyModel::rowCount(parent), 4);
}

#include "moc_favoritesmodel.cpp"
