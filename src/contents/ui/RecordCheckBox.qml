
/*
 * Copyright (C) 2021 Beijing Jingling Information System Technology Co., Ltd. All rights reserved.
 *
 * Authors:
 * Zhang He Gang <zhanghegang@jingos.com>
 *
 */

import QtQuick 2.12
import QtQuick.Controls 1.4 as Controls
import QtQuick.Layouts 1.2
import QtQuick.Controls.Styles 1.4
import "commonsize.js" as CSJ

Controls.CheckBox{
    id:itemCheckBox

    property int radiusCB
    property int bordWidth
    property var imageSourceDefault: "qrc:/assets/checkbox_default.png"

    style: CheckBoxStyle {
        indicator: Rectangle {
            color: "transparent"
            width: itemCheckBox.width
            height: itemCheckBox.width
            radius:radiusCB
            Image {
                width: itemCheckBox.width
                height: itemCheckBox.width
                source: control.checked ? "qrc:/assets/checkbox_ok.png":imageSourceDefault
            }
        }
    }
}
