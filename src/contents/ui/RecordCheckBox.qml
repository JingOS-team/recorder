/*
 * SPDX-FileCopyrightText: 2021 Wang Rui <wangrui@jingos.com>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
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
//                sourceSize: Qt.size(44,44)
                source: control.checked ? "qrc:/assets/checkbox_ok.png":imageSourceDefault
            }
        }
    }
}
