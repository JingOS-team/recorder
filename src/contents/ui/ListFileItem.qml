/*
 * Copyright (C) 2021 Beijing Jingling Information System Technology Co., Ltd. All rights reserved.
 *
 * Authors:
 * Zhang He Gang <zhanghegang@jingos.com>
 *
 */

import QtQuick 2.1
import org.kde.kirigami 2.2
import QtGraphicalEffects 1.0

Rectangle {
    id: background

    property int itemRadius
    property int lineLeftMargin
    property int defaultIndex
    property int colorDuration : 50

    width: parent.width
    height: parent.height
    radius: itemRadius
    color: lineLeftMargin <= 0 ?  (recordFileList.itemIndex === defaultIndex ? listItem.activeBackgroundColor : listItem.backgroundColor) : (listItem.checked || (listItem.pressed && !listItem.checked && !listItem.sectionDelegate) ? (internal.indicateActiveFocus ? listItem.activeBackgroundColor : Qt.tint(listItem.backgroundColor, Qt.rgba(listItem.activeBackgroundColor.r, listItem.activeBackgroundColor.g, listItem.activeBackgroundColor.b, 0.3))) : listItem.backgroundColor)
    visible: recordFileList.itemIndex === defaultIndex

    Rectangle {
        id: internal

        property bool indicateActiveFocus:true
        readonly property bool _firstElement: typeof(index) !== "undefined" && index == 0

        radius: itemRadius
        anchors.fill: parent
        visible: true
        color: getcolor()
        opacity: listItem.itemHoverd ? 0.2 : 1.0

        Behavior on opacity { NumberAnimation { duration: colorDuration } }

        function getcolor(){
            var cor =  ( recordFileList.itemIndex === defaultIndex ? listItem.activeBackgroundColor : listItem.backgroundColor)
            return cor
        }
    }
    Behavior on color {
        ColorAnimation { duration: colorDuration }
    }

}
