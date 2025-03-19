// SPDX-FileCopyrightText: 2025 Alexander Rutz <arpio@droidian.org>
// SPDX-License-Identifier: GPL-2.0-or-later

import QtQuick

Item {
	property var row1_model: row1
	property var row1_model_shift: row1_shift
	property var row1B_model: row1B

	property var row2_model: row2
	property var row2B_model: row2B 

	property var row3_model: row3 
	property var row3B_model: row3B 

	property var row4_model: row4
	property var row4B_model: row4B

	property var layout: 'Dial'

	ListModel {
		id: row1
		ListElement{displayText: '1'; capitalization: false;}
		ListElement{displayText: '2'; capitalization: false;}
		ListElement{displayText: '3'; capitalization: false;}
	}

	ListModel {
		id: row1_shift
	}

	ListModel {
		id: row1B
	}

	ListModel {
		id: row2
		ListElement{displayText: '4'; capitalization: false;}
		ListElement{displayText: '5'; capitalization: false;}
		ListElement{displayText: '6'; capitalization: false;}
	}

	ListModel {
		id: row2B
	}

	ListModel {
		id: row3
		ListElement{displayText: '7'; capitalization: false;}
		ListElement{displayText: '8'; capitalization: false;}
		ListElement{displayText: '9'; capitalization: false;}
	}

	ListModel {
		id: row3B
	}

	ListModel {
		id: row4
		ListElement{displayText: '*'; capitalization: false;}
		ListElement{displayText: '0'; capitalization: false;}
		ListElement{displayText: '\u21D0'; capitalization: false;}
		
	}

	ListModel {
		id: row4B
		
	}
}