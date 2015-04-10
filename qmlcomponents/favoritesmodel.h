/*
 *   Copyright 2015 by Marco MArtin <mart@kde.org>

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

#ifndef FAVORITESMODEL_H
#define FAVORITESMODEL_H

#include <QIdentityProxyModel>


class QTimer;


class FavoritesModel : public QIdentityProxyModel
{
    Q_OBJECT

public:
    FavoritesModel(QObject *parent = 0);
    ~FavoritesModel();

    QHash<int, QByteArray> roleNames() const Q_DECL_OVERRIDE;
    int rowCount(const QModelIndex &parent = QModelIndex()) const Q_DECL_OVERRIDE;

    int count() const
    {
        return rowCount();
    }

private:

};

#endif
