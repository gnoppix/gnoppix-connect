/**
 * SPDX-FileCopyrightText: 2020 Aniket Kumar <anikketkumar786@gmail.com>
 *
 * SPDX-License-Identifier: GPL-2.0-only OR GPL-3.0-only OR LicenseRef-KDE-Accepted-GPL
 */

import QtQuick 2.1
import QtQuick.Controls 2.2 as Controls
import QtQuick.Layouts 1.1
import org.kde.kirigami 2.4 as Kirigami
import QtGraphicalEffects 1.0
import QtQuick.Dialogs 1.1
import org.kde.kdeconnect.sms 1.0

ColumnLayout {
    id: root
    property var addresses
    property var selectedFileUrls: []
    readonly property int maxMessageSize: 600000
    property alias text: messageField.text

    MessageDialog {
        id: messageDialog
        title: i18nd("kdeconnect-sms", "Failed to send")
        text: i18nd("kdeconnect-sms", "Max message size limit exceeded.")

        onAccepted: {
            messageDialog.close()
        }
    }

    FileDialog {
        id: fileDialog
        folder: shortcuts.home
        selectMultiple: true

        onAccepted: {
            root.selectedFileUrls = fileDialog.fileUrls
            fileDialog.close()
        }
    }

    Controls.Pane {
        id: sendingArea
        enabled: page.deviceConnected
        layer.enabled: sendingArea.enabled
        layer.effect: DropShadow {
            verticalOffset: 1
            color: Kirigami.Theme.disabledTextColor
            samples: 20
            spread: 0.3
        }
        Layout.fillWidth: true
        padding: 0
        wheelEnabled: true
        background: Rectangle {
            color: Kirigami.Theme.backgroundColor
        }

        RowLayout {
            anchors.fill: parent

            Controls.ScrollView {
                Layout.fillWidth: true
                Layout.maximumHeight: page.height > 300 ? page.height / 3 : 2 * page.height / 3
                contentWidth: page.width - sendButtonArea.width
                clip: true
                Controls.ScrollBar.horizontal.policy: Controls.ScrollBar.AlwaysOff

                Controls.TextArea {
                    width: parent.width
                    id: messageField
                    placeholderText: i18nd("kdeconnect-sms", "Compose message")
                    wrapMode: TextEdit.Wrap
                    topPadding: Kirigami.Units.gridUnit * 0.5
                    bottomPadding: topPadding
                    selectByMouse: true
                    hoverEnabled: true
                    background: MouseArea {
                        hoverEnabled: true
                        acceptedButtons: Qt.NoButton
                        cursorShape: Qt.IBeamCursor
                        z: 1
                    }
                    Keys.onReturnPressed: {
                        if (event.key === Qt.Key_Return) {
                            if (event.modifiers & Qt.ShiftModifier) {
                                messageField.append("")
                            } else {
                                sendButton.onClicked()
                                event.accepted = true
                            }
                        }
                    }
                }
            }

            ColumnLayout {
                id: sendButtonArea
                Layout.alignment: Qt.AlignBottom

                RowLayout {
                    Controls.ToolButton {
                        id: attachFilesButton
                        enabled: true
                        Layout.preferredWidth: Kirigami.Units.gridUnit * 2
                        Layout.preferredHeight: Kirigami.Units.gridUnit * 2
                        padding: 0
                        Text {
                            id: attachedFilesCount
                            text: selectedFileUrls.length
                            color: "red"
                            visible: selectedFileUrls.length > 0
                        }
                        Kirigami.Icon {
                            source: "insert-image"
                            isMask: true
                            smooth: true
                            anchors.centerIn: parent
                            width: Kirigami.Units.gridUnit * 1.5
                            height: width
                        }

                        onClicked: {
                            fileDialog.open()
                        }
                    }

                    Controls.ToolButton {
                        id: clearAttachmentButton
                        visible: selectedFileUrls.length > 0
                        Layout.preferredWidth: Kirigami.Units.gridUnit * 2
                        Layout.preferredHeight: Kirigami.Units.gridUnit * 2
                        padding: 0
                        Kirigami.Icon {
                            id: cancelIcon
                            source: "edit-clear"
                            isMask: true
                            smooth: true
                            anchors.centerIn: parent
                            width: Kirigami.Units.gridUnit * 1.5
                            height: width
                        }

                        onClicked: {
                            selectedFileUrls = []
                        }
                    }

                    Controls.ToolButton {
                        property bool isSendingInProcess: false

                        id: sendButton
                        enabled: (messageField.text.length || selectedFileUrls.length) && !isSendingInProcess
                        Layout.preferredWidth: Kirigami.Units.gridUnit * 2
                        Layout.preferredHeight: Kirigami.Units.gridUnit * 2
                        padding: 0
                        Kirigami.Icon {
                            source: "document-send"
                            enabled: sendButton.enabled
                            isMask: true
                            smooth: true
                            anchors.centerIn: parent
                            width: Kirigami.Units.gridUnit * 1.5
                            height: width
                        }

                        property bool messageSent: false

                        onClicked: {

                            // prevent sending the same message several times
                            // and don't touch enabled property
                            if (isSendingInProcess){
                                return;
                            }
                            isSendingInProcess = true

                            if (SmsHelper.totalMessageSize(selectedFileUrls, messageField.text) > maxMessageSize) {
                                messageDialog.visible = true
                            } else if (page.conversationId === page.invalidId) {
                                messageSent = conversationModel.startNewConversation(messageField.text, addresses, selectedFileUrls)
                            } else {
                                messageSent = conversationModel.sendReplyToConversation(messageField.text, selectedFileUrls)
                            }

                            if (messageSent) {
                                messageField.text = ""
                                selectedFileUrls = []
                            }
                            isSendingInProcess = false
                        }
                    }
                }

                Controls.Label {
                    id: charCount
                    text: conversationModel.getCharCountInfo(messageField.text)
                    visible: text.length > 0
                    Layout.minimumWidth: Math.max(Layout.minimumWidth, width) // Make this label only grow, never shrink
                }
            }
        }
    }
}
