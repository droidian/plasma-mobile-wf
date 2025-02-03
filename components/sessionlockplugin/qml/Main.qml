import QtQuick

Rectangle {
	id: rootItem
	color: "black"

	Behavior on opacity { PropertyAnimation {duration: 400} }

	Connections {
        target: PlamoLock

        function onSucceeded() {
            console.log('login succeeded');
            rootItem.opacity = 0
        }
    }

	LockScreen{
		id: lockscreenItem
		width: 500
		height: 500
	}

	ParallelAnimation {
		id: animateSize
		running: false
		PropertyAnimation {target: lockscreenItem; properties: "width"; to: rootItem.width; duration: 150}
		PropertyAnimation {target: lockscreenItem; properties: "height"; to: rootItem.height; duration: 150}
	}

	onHeightChanged: {
		animateSize.start()
	}

	onOpacityChanged: {
		if(opacity == 0)
			PlamoLock.quitNow();
	}
}