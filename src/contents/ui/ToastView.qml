/*
 * Copyright (C) 2021 Beijing Jingling Information System Technology Co., Ltd. All rights reserved.
 *
 * Authors:
 * Zhang He Gang <zhanghegang@jingos.com>
 *
 */
import QtQuick 2.0
import QtGraphicalEffects 1.0
import QtQuick.Controls 2.15
import org.kde.kirigami 2.15 as Kirigami

ToolTip
{
    id: toast

    property alias toastContent : toastText.text
    property alias toastItem: footerBlur.sourceItem

    delay: 0
    timeout: 2000

    width: (278 * lastAppScaleSize)
    height: 65 * lastAppScaleSize
    background: Rectangle
    {
        radius: 18 * lastAppScaleSize
        color: "transparent"
        ShaderEffectSource
        {
            id: footerBlur

            width: parent.width
            height: parent.height

            visible: false
            sourceItem: recordMainView
            sourceRect: Qt.rect(toast.x, toast.y, width, height)
        }

        FastBlur{
            id:fastBlur

            anchors.fill: parent

            source: footerBlur
            radius: 60 * lastAppScaleSize
            cached: true
            visible: false
        }

        Rectangle{
            id:maskRect

            anchors.fill:fastBlur

            visible: false
            clip: true
            radius: 30 * lastAppScaleSize
        }
        OpacityMask{
            id: mask
            anchors.fill: maskRect
            visible: true
            source: fastBlur
            maskSource: maskRect
        }

        Rectangle{
            anchors.fill: footerBlur
            color: Kirigami.JTheme.floatBackground
            radius: 30 * lastAppScaleSize
        }
    }
    Text
    {
        id: toastText
        anchors{
             horizontalCenter: parent.horizontalCenter
            verticalCenter: parent.verticalCenter
            left: parent.left
            leftMargin: 30 * lastAppScaleSize
            right: parent.right
            rightMargin: 30 * lastAppScaleSize
        }
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        wrapMode: Text.WordWrap
        text: ""
        font
        {
            pixelSize: defaultFontSize
        }
        color: Kirigami.JTheme.majorForeground
    }
}
