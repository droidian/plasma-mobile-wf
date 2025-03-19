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

	property var layout: 'English'

	ListModel {
		id: row1
		ListElement{displayText: '1'; capitalization: false;}
		ListElement{displayText: '2'; capitalization: false;}
		ListElement{displayText: '3'; capitalization: false;}
		ListElement{displayText: '4'; capitalization: false;}
		ListElement{displayText: '5'; capitalization: false;}
		ListElement{displayText: '6'; capitalization: false;}
		ListElement{displayText: '7'; capitalization: false;}
		ListElement{displayText: '8'; capitalization: false;}
		ListElement{displayText: '9'; capitalization: false;}
		ListElement{displayText: '0'; capitalization: false;}
	}

	ListModel {
		id: row1_shift
		ListElement{displayText: '!'; capitalization: false;}
		ListElement{displayText: '@'; capitalization: false;}
		ListElement{displayText: '#'; capitalization: false;}
		ListElement{displayText: '$'; capitalization: false;}
		ListElement{displayText: '%'; capitalization: false;}
		ListElement{displayText: '^'; capitalization: false;}
		ListElement{displayText: '&'; capitalization: false;}
		ListElement{displayText: '*'; capitalization: false;}
		ListElement{displayText: '('; capitalization: false;}
		ListElement{displayText: ')'; capitalization: false;}
	}

	ListModel {
		id: row1B
		ListElement{displayText: '\u21E5'; capitalization: false;}
		ListElement{displayText: 'Ctrl'; capitalization: false;}
		ListElement{displayText: 'Alt'; capitalization: false;}
		ListElement{displayText: '\u21D1'; capitalization: false;}
		ListElement{displayText: '\u21D3'; capitalization: false;}
		ListElement{displayText: '\u21D0'; capitalization: false;}
		ListElement{displayText: '\u21D2'; capitalization: false;}
	}

	ListModel {
		id: row2
		ListElement{displayText: 'q'; capitalization: true;}
		ListElement{displayText: 'w'; capitalization: true;}
		ListElement{displayText: 'e'; capitalization: true;}
		ListElement{displayText: 'r'; capitalization: true;}
		ListElement{displayText: 't'; capitalization: true;}
		ListElement{displayText: 'y'; capitalization: true;}
		ListElement{displayText: 'u'; capitalization: true;}
		ListElement{displayText: 'i'; capitalization: true;}
		ListElement{displayText: 'o'; capitalization: true;}
		ListElement{displayText: 'p'; capitalization: true;}
	}

	ListModel {
		id: row2B
		ListElement{displayText: '*'; capitalization: false;}
		ListElement{displayText: '-'; capitalization: false;}
		ListElement{displayText: '+'; capitalization: false;}
		ListElement{displayText: '"'; capitalization: false;}
		ListElement{displayText: '<'; capitalization: false;}
		ListElement{displayText: '>'; capitalization: false;}
		ListElement{displayText: "'"; capitalization: false;}
		ListElement{displayText: ':'; capitalization: false;}
		ListElement{displayText: ';'; capitalization: false;}
		ListElement{displayText: '~'; capitalization: false;}
	}

	ListModel {
		id: row3
		ListElement{displayText: 'a'; capitalization: true;}
		ListElement{displayText: 's'; capitalization: true;}
		ListElement{displayText: 'd'; capitalization: true;}
		ListElement{displayText: 'f'; capitalization: true;}
		ListElement{displayText: 'g'; capitalization: true;}
		ListElement{displayText: 'h'; capitalization: true;}
		ListElement{displayText: 'j'; capitalization: true;}
		ListElement{displayText: 'k'; capitalization: true;}
		ListElement{displayText: 'l'; capitalization: true;}
	}

	ListModel {
		id: row3B
		ListElement{displayText: '='; capitalization: false;}
		ListElement{displayText: '$'; capitalization: false;}
		ListElement{displayText: '€'; capitalization: false;}
		ListElement{displayText: '£'; capitalization: false;}
		ListElement{displayText: '₵'; capitalization: false;}
		ListElement{displayText: '¥'; capitalization: false;}
		ListElement{displayText: '§'; capitalization: false;}
		ListElement{displayText: '['; capitalization: false;}
		ListElement{displayText: ']'; capitalization: false;}
	}

	ListModel {
		id: row4
		ListElement{displayText: '\u21E7'; capitalization: false;}
		ListElement{displayText: 'z'; capitalization: true;}
		ListElement{displayText: 'x'; capitalization: true;}
		ListElement{displayText: 'c'; capitalization: true;}
		ListElement{displayText: 'v'; capitalization: true;}
		ListElement{displayText: 'b'; capitalization: true;}
		ListElement{displayText: 'n'; capitalization: true;}
		ListElement{displayText: 'm'; capitalization: true;}
		ListElement{displayText: '\u21D0'; capitalization: false;}
		
	}

	ListModel {
		id: row4B
		ListElement{displayText: '\u21E7'; capitalization: false;}
		ListElement{displayText: '_'; capitalization: false;}
		ListElement{displayText: '`'; capitalization: false;}
		ListElement{displayText: '{'; capitalization: false;}
		ListElement{displayText: '}'; capitalization: false;}
		ListElement{displayText: '\u2216'; capitalization: false;}
		ListElement{displayText: '|'; capitalization: false;}
		ListElement{displayText: '?'; capitalization: false;}
		ListElement{displayText: '\u21D0'; capitalization: false;}
	}
}