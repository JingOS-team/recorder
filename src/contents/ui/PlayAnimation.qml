/*
 * SPDX-FileCopyrightText: 2021 Wang Rui <wangrui@jingos.com>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

import QtQuick 2.12
import QtGraphicalEffects 1.0
import QtQuick.Shapes 1.12

Item {
    id: control

    property double wave_offset: 0.0
    property color wave_color: "white"
    property bool rAnimationRunning
    property bool isAnimationPlayer
    property int imageIndex: 0
    property int imageCount: 15
    property int imageFlag: 0

    clip: false

    Image {
        id: imageAmiaMin

        width: control.width
        height: control.height
        anchors.centerIn: parent
        //black white_more
        source: isAnimationPlayer ? "qrc:/assets/black_more.png":"qrc:/assets/red_more.png"

        RotationAnimation{
            loops: Animation.Infinite
            running:rAnimationRunning
            target: imageAmiaMin
            property: "rotation"
            from: 0
            to:360
            duration: 4900
        }
    }

    Image {
        id: imageAmiaMore

        visible: rAnimationRunning
        width: control.width
        height: control.height
        anchors.centerIn: parent
        source:  isAnimationPlayer ? "qrc:/assets/black_min.png":"qrc:/assets/red_min.png"

        RotationAnimation{
            loops: Animation.Infinite
            running:rAnimationRunning
            target: imageAmiaMore
            property: "rotation"
            from: 0
            to:360
            duration: 2450
        }
    }

}
