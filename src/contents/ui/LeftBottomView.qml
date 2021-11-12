/*
 * Copyright (C) 2021 Beijing Jingling Information System Technology Co., Ltd. All rights reserved.
 *
 * Authors:
 * Zhang He Gang <zhanghegang@jingos.com>
 *
 */

import QtQuick 2.12
import org.kde.kirigami 2.12 as Kirigami
import QtQuick.Controls 2.2 as Controls
import QtQuick.Layouts 1.2

RowLayout {
    id:leftBottom

    property int itemWidth : width/4
    property int itemImageHeight :height*2/5

    LeftBottomItem{
        id:deleteItem

        width:itemWidth
        height: parent.height
        imageHeight: itemImageHeight
        textContent: i18n("delete")
        imageSource: ""
        onBottomItemclicked: {
        }
    }
    LeftBottomItem{
        id:renameItem

        width: itemWidth
        height: parent.height
        imageSource: ""
        imageHeight: itemImageHeight
        textContent: i18n("rename")
        onBottomItemclicked: {
        }
    }
    LeftBottomItem{
        id:selectAllItem

        width:itemWidth
        height: parent.height
        imageSource: ""
        imageHeight: itemImageHeight
        textContent: i18n("selectAll")
        onBottomItemclicked: {
        }
    }
    LeftBottomItem{
        id:moreItem

        width:itemWidth
        height: parent.height
        imageSource: ""
        imageHeight: itemImageHeight
        textContent: i18n("more")
        onBottomItemclicked: {
        }
    }
}
