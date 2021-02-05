

/*
 * SPDX-FileCopyrightText: 2021 Wang Rui <wangrui@jingos.com>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */
import QtQuick 2.12
import QtQuick.Controls 2.12
import "commonsize.js" as CSJ
import KRecorder 1.0
import QtGraphicalEffects 1.12

Menu {
    id: menu

    property int mwidth: root.screen.width * CSJ.Left_view_Edit_Menu_width / CSJ.ScreenCurrentWidth
    property int mheight: root.screen.height * CSJ.Left_view_Edit_Menu_height
                          / CSJ.ScreenCurrentHeight
    property var separatorColor: "#4DFFFFFF"
    property int separatorWidth: mwidth * 8 / 10
    property int mouseX
    property int mouseY
    property int menuItemCount: 4

    signal bulkClicked
    signal deleteClicked
    signal renameClicked
    signal saveClicked

    padding: 0
    margins: 0

    function rmBulkAction() {
        var ba = menu.actionAt(0)
        if (ba.text === CSJ.Left_View_Edit_Menu_Bulk) {
            menu.takeAction(0)
        }
    }
    function addBulkAction() {
        var ba = menu.actionAt(0)
        if (ba.text !== CSJ.Left_View_Edit_Menu_Bulk) {
            menu.insertAction(0, bulkAction)
        }
    }

    Action {
        id: bulkAction
        text: qsTr(CSJ.Left_View_Edit_Menu_Bulk)
        checkable: true
        checked: false
        onCheckedChanged: {
            bulkClicked()
        }
    }

    Action {
        text: qsTr(CSJ.Left_View_Edit_Menu_Delete)
        checkable: true
        checked: false
        onCheckedChanged: {
            deleteClicked()
        }
    }

    Action {
        text: qsTr(CSJ.Left_View_Edit_Menu_Rename)
        checkable: true
        checked: false
        onCheckedChanged: {
            renameClicked()
        }
    }

    Action {
        text: qsTr(CSJ.Left_View_Edit_Menu_Save)
        checkable: true
        checked: false
        onCheckedChanged: {
            saveClicked()
        }
    }

    delegate: MenuItem {
        id: menuItem
        width: menu.mwidth
        height: mheight / menuItemCount
        implicitWidth: menu.mwidth
        implicitHeight: mheight / menuItemCount
        padding: 0
        opacity: menuItem.text === CSJ.Left_View_Edit_Menu_Save ? 0.5 : 1.0

        MouseArea {
            anchors.fill: parent
            enabled: menuItem.opacity === 0.5
        }

        arrow: Canvas {
            width: 0
            height: 0
            visible: menuItem.subMenu
            onPaint: {
                var ctx = getContext("2d")
                ctx.fillStyle = menuItem.highlighted ? "#ffffff" : "#21be2b"
                ctx.moveTo(15, 15)
                ctx.lineTo(width - 15, height / 2)
                ctx.lineTo(15, height - 15)
                ctx.closePath()
                ctx.fill()
            }
        }

        indicator: Item {
            width: 0
            height: 0
        }

        contentItem: Item {
            id: munuContentItem
            height: mheight / menuItemCount
            implicitWidth: getAllWidth()

            function getAllWidth() {
                return menu.mwidth
            }
            Text {
                anchors {
                    left: parent.left
                    verticalCenter: parent.verticalCenter
                }
                leftPadding: mwidth / 10
                text: menuItem.text
                font.pointSize: defaultFontSize + 2
                color: menuItem.highlighted ? "#ffffff" : "#ffffff"
                horizontalAlignment: Text.AlignLeft
                verticalAlignment: Text.AlignVCenter
                elide: Text.ElideRight
            }
            Image {
                id: rightImage
                width: height
                height: parent.height / 3
                anchors {
                    right: parent.right
                    rightMargin: mwidth / 10
                    verticalCenter: parent.verticalCenter
                }
                source: getSource()
                function getSource() {
                    switch (menuItem.text) {
                    case CSJ.Left_View_Edit_Menu_Bulk:
                        return "qrc:/assets/edit_bulk.png"
                    case CSJ.Left_View_Edit_Menu_Delete:
                        return "qrc:/assets/edit_delete.png"
                    case CSJ.Left_View_Edit_Menu_Rename:
                        return "qrc:/assets/edit_rename.png"
                    case CSJ.Left_View_Edit_Menu_Save:
                        return "qrc:/assets/edit_savetofile.png"
                    }
                    return ""
                }
            }
        }

        background: Item {
            width: menu.mwidth
            height: mheight / 4
            implicitWidth: menu.mwidth
            implicitHeight: mheight / menuItemCount
            clip: true

            Rectangle {
                anchors.fill: parent
                anchors.bottomMargin: menu.currentIndex === 0 ? -radius : 0
                anchors.topMargin: menu.currentIndex === menu.count - 1 ? -radius : 0
                radius: menu.currentIndex === 0
                        || menu.currentIndex === menu.count - 1 ? 20 : 0
                color: menuItem.highlighted ? "#2E747480" : "transparent"
            }
            Rectangle {
                id: bline
                width: separatorWidth
                height: 1
                anchors.bottom: parent.bottom
                anchors.horizontalCenter: parent.horizontalCenter
                visible: menuItem.text !== CSJ.Left_View_Edit_Menu_Save
                color: separatorColor
            }
        }
    }

    background: Rectangle {
        id: mBr
        width: mwidth
        implicitWidth: mwidth
        color: "#000000"
        border.width: 0
        radius: 20
        ShaderEffectSource {
            id: eff
            width: fastBlur.width
            height: fastBlur.height
            sourceItem: recordMainView
            anchors.centerIn: fastBlur
            visible: false
            sourceRect: Qt.rect(mouseX, mouseY, width, height)
        }
        FastBlur {
            id: fastBlur
            anchors.fill: parent
            source: eff
            radius: 64
            cached: true
            visible: false
        }

        Rectangle {
            id: maskRect
            anchors.fill: fastBlur
            radius: 20
            visible: false
            clip: true
        }
        OpacityMask {
            id: mask
            anchors.fill: maskRect
            visible: true
            source: fastBlur
            maskSource: maskRect
        }
        Rectangle {
            anchors.fill: mBr
            radius: 20
            visible: false
            color: "#CC000000"
            clip: true
        }
    }
}
