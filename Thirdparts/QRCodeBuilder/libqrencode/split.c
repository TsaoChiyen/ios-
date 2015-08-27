/*
 * qrencode - QR Code encoder
 *
 * Input data splitter.
 * Copyright (C) 2006, 2007, 2008, 2009 Kentaro Fukuchi <fukuchi@megaui.net>
 *
 * The following data / specifications are taken from
 * "Two dimensional symbol -- QR-code -- Basic Specification" (JIS X0510:2004)
 *  or
 * "Automatic identification and data capture techniques -- 
 *  QR Code 2005 bar code symbology specification" (ISO/IEC 18004:2006)
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 2.1 of the License, or any later version.
 *
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
 * Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public
 * License along with this library; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA 02110-1301 USA
 */

#include <stdlib.h>
#include <string.h>
#include <errno.h>
#include "qrencode.h"
#include "qrinput.h"
#include "qrspec.h"
#include "split.h"

#define isdigit(__c__) ((unsigned char)((signed char)(__c__) - '0') < 10)
#define isalnum(__c__) (QRinput_lookAnTable(__c__) >= 0)

static QRencodeMode Split_identifyMode(const char *string, QRencodeMode hint)
{
	unsigned char c, d;
	unsigned int word;

	c = string[0];

	if(c == '\0') return QR_MODE_NUL;
	if(isdigit(c)) {
		return QR_MODE_NUM;
	} else if(isalnum(c)) {
		return QR_MODE_AN;
	} else if(hint == QR_MODE_KANJI) {
		d = string[1];
		if(d != '\0') {
			word = ((unsigned int)c << 8) | d;
			if((word >= 0x8140 && word <= 0x9ffc) || (word >= 0xe040 && word <= 0xebbf)) {
				return QR_MODE_KANJI;
			}
		}
	}

	return QR_MODE_8;
}

static NSInteger Split_eatNum(const char *string, QRinput *input, QRencodeMode hint);
static NSInteger Split_eatAn(const char *string, QRinput *input, QRencodeMode hint);
static NSInteger Split_eat8(const char *string, QRinput *input, QRencodeMode hint);
static NSInteger Split_eatKanji(const char *string, QRinput *input, QRencodeMode hint);

static NSInteger Split_eatNum(const char *string, QRinput *input,QRencodeMode hint)
{
	const char *p;
	NSInteger ret;
	NSInteger run;
	NSInteger dif;
	int ln;
	QRencodeMode mode;

	ln = QRspec_lengthIndicator(QR_MODE_NUM, input->version);

	p = string;
	while(isdigit(*p)) {
		p++;
	}
	run = p - string;
	mode = Split_identifyMode(p, hint);
	if(mode == QR_MODE_8) {
		dif = QRinput_estimateBitsModeNum(run) + 4 + ln
			+ QRinput_estimateBitsMode8(1) /* + 4 + l8 */
			- QRinput_estimateBitsMode8(run + 1) /* - 4 - l8 */;
		if(dif > 0) {
			return Split_eat8(string, input, hint);
		}
	}
	if(mode == QR_MODE_AN) {
		dif = QRinput_estimateBitsModeNum(run) + 4 + ln
			+ QRinput_estimateBitsModeAn(1) /* + 4 + la */
			- QRinput_estimateBitsModeAn(run + 1) /* - 4 - la */;
		if(dif > 0) {
			return Split_eatAn(string, input, hint);
		}
	}

	ret = QRinput_append(input, QR_MODE_NUM, run, (unsigned char *)string);
	if(ret < 0) return -1;

	return run;
}

static NSInteger Split_eatAn(const char *string, QRinput *input, QRencodeMode hint)
{
	const char *p, *q;
	NSInteger ret;
	NSInteger run;
	NSInteger dif;
	NSInteger la, ln;

	la = QRspec_lengthIndicator(QR_MODE_AN, input->version);
	ln = QRspec_lengthIndicator(QR_MODE_NUM, input->version);

	p = string;
	while(isalnum(*p)) {
		if(isdigit(*p)) {
			q = p;
			while(isdigit(*q)) {
				q++;
			}
			dif = QRinput_estimateBitsModeAn(p - string) /* + 4 + la */
				+ QRinput_estimateBitsModeNum(q - p) + 4 + ln
				- QRinput_estimateBitsModeAn(q - string) /* - 4 - la */;
			if(dif < 0) {
				break;
			} else {
				p = q;
			}
		} else {
			p++;
		}
	}

	run = p - string;

	if(*p && !isalnum(*p)) {
		dif = QRinput_estimateBitsModeAn(run) + 4 + la
			+ QRinput_estimateBitsMode8(1) /* + 4 + l8 */
			- QRinput_estimateBitsMode8(run + 1) /* - 4 - l8 */;
		if(dif > 0) {
			return Split_eat8(string, input, hint);
		}
	}

	ret = QRinput_append(input, QR_MODE_AN, run, (unsigned char *)string);
	if(ret < 0) return -1;

	return run;
}

static NSInteger Split_eatKanji(const char *string, QRinput *input, QRencodeMode hint)
{
	const char *p;
	NSInteger ret;
	NSInteger run;

	p = string;
	while(Split_identifyMode(p, hint) == QR_MODE_KANJI) {
		p += 2;
	}
	run = p - string;
	ret = QRinput_append(input, QR_MODE_KANJI, run, (unsigned char *)string);
	if(ret < 0) return -1;

	return run;
}

static NSInteger Split_eat8(const char *string, QRinput *input, QRencodeMode hint)
{
	const char *p, *q;
	QRencodeMode mode;
	NSInteger ret;
	NSInteger run;
	NSInteger dif;
	NSInteger la, ln;

	la = QRspec_lengthIndicator(QR_MODE_AN, input->version);
	ln = QRspec_lengthIndicator(QR_MODE_NUM, input->version);

	p = string + 1;
	while(*p != '\0') {
		mode = Split_identifyMode(p, hint);
		if(mode == QR_MODE_KANJI) {
			break;
		}
		if(mode == QR_MODE_NUM) {
			q = p;
			while(isdigit(*q)) {
				q++;
			}
			dif = QRinput_estimateBitsMode8(p - string) /* + 4 + l8 */
				+ QRinput_estimateBitsModeNum(q - p) + 4 + ln
				- QRinput_estimateBitsMode8(q - string) /* - 4 - l8 */;
			if(dif < 0) {
				break;
			} else {
				p = q;
			}
		} else if(mode == QR_MODE_AN) {
			q = p;
			while(isalnum(*q)) {
				q++;
			}
			dif = QRinput_estimateBitsMode8(p - string) /* + 4 + l8 */
				+ QRinput_estimateBitsModeAn(q - p) + 4 + la
				- QRinput_estimateBitsMode8(q - string) /* - 4 - l8 */;
			if(dif < 0) {
				break;
			} else {
				p = q;
			}
		} else {
			p++;
		}
	}

	run = p - string;
	ret = QRinput_append(input, QR_MODE_8, run, (unsigned char *)string);
	if(ret < 0) return -1;

	return run;
}

static NSInteger Split_splitString(const char *string, QRinput *input,
		QRencodeMode hint)
{
	NSInteger length;
	QRencodeMode mode;

	if(*string == '\0') return 0;

	mode = Split_identifyMode(string, hint);
	if(mode == QR_MODE_NUM) {
		length = Split_eatNum(string, input, hint);
	} else if(mode == QR_MODE_AN) {
		length = Split_eatAn(string, input, hint);
	} else if(mode == QR_MODE_KANJI && hint == QR_MODE_KANJI) {
		length = Split_eatKanji(string, input, hint);
	} else {
		length = Split_eat8(string, input, hint);
	}
	if(length == 0) return 0;
	if(length < 0) return -1;
	return Split_splitString(&string[length], input, hint);
}

static char *dupAndToUpper(const char *str, QRencodeMode hint)
{
	char *newstr, *p;
	QRencodeMode mode;

	newstr = strdup(str);
	if(newstr == NULL) return NULL;

	p = newstr;
	while(*p != '\0') {
		mode = Split_identifyMode(p, hint);
		if(mode == QR_MODE_KANJI) {
			p += 2;
		} else {
			if (*p >= 'a' && *p <= 'z') {
				*p = (char)((int)*p - 32);
			}
			p++;
		}
	}

	return newstr;
}

NSInteger Split_splitStringToQRinput(const char *string, QRinput *input,
		QRencodeMode hint, int casesensitive)
{
	char *newstr;
	NSInteger ret;

	if(string == NULL || *string == '\0') {
		errno = EINVAL;
		return -1;
	}
	if(!casesensitive) {
		newstr = dupAndToUpper(string, hint);
		if(newstr == NULL) return -1;
		ret = Split_splitString(newstr, input, hint);
		free(newstr);
	} else {
		ret = Split_splitString(string, input, hint);
	}

	return ret;
}