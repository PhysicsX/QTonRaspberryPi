import QtQuick 2.12
import QtQuick.Window 2.12
import QtQuick.Controls 2.12

Window {
    visible: true
    width: 640
    height: 480
    title: qsTr("CROSS COMPILED QT6")


	Rectangle {
	    width: parent.width
	    height: parent.height

	    Rectangle {
		id: button

		width: 100
		height: 30
		color: "blue"
		anchors.centerIn: parent

		Text {
		    id: buttonText
		    text: qsTr("Button")
		    color: "white"
		    anchors.centerIn: parent
		}

		MouseArea {
		    anchors.fill: parent
		    onClicked: {
		        buttonText.text = qsTr("Clicked");
		        buttonText.color = "black";
				myObject.onButtonClicked()

		    }
		}
	    }
	}
}
