/*
 * Copyright 2010, Lloyd Hilaiel.
 * 
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are
 * met:
 * 
 *  1. Redistributions of source code must retain the above copyright
 *     notice, this list of conditions and the following disclaimer.
 * 
 *  2. Redistributions in binary form must reproduce the above copyright
 *     notice, this list of conditions and the following disclaimer in
 *     the documentation and/or other materials provided with the
 *     distribution.
 * 
 *  3. Neither the name of Lloyd Hilaiel nor the names of its
 *     contributors may be used to endorse or promote products derived
 *     from this software without specific prior written permission.
 * 
 * THIS SOFTWARE IS PROVIDED BY THE AUTHOR ``AS IS'' AND ANY EXPRESS OR
 * IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 * WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 * DISCLAIMED. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY DIRECT,
 * INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 * (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
 * SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
 * HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT,
 * STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING
 * IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
 * POSSIBILITY OF SUCH DAMAGE.
 */ 

#include "yajl_encode.h"

#include <assert.h>
#include <stdlib.h>
#include <string.h>
#include <stdio.h>

void
yajl_string_encode(yajl_buf buf, const unsigned char * str,
                   unsigned int len)
{
    yajl_string_encode2((const yajl_print_t) &yajl_buf_append, buf, str, len);
}

static const unsigned long utf8_limits[] = {
    0x0,			/* 1 */
    0x80,			/* 2 */
    0x800,			/* 3 */
    0x10000,			/* 4 */
    0x200000,			/* 5 */
    0x4000000,			/* 6 */
    0x80000000,			/* 7 */
};

void
yajl_string_encode2(const yajl_print_t print,
                    void * ctx,
                    const unsigned char * str,
                    unsigned int len)
{
    yajl_string_encode3(print, ctx, str, len, 0);
}

void
yajl_string_encode3(const yajl_print_t print,
                    void * ctx,
                    const unsigned char * str,
                    unsigned int len,
                    unsigned int asciiOnly)
{
    unsigned int curPos = 0;
    char curByte;

    while (curPos < len) {
        const char * escaped = NULL;
        curByte = str[curPos];
        switch (curByte) {
            case '\r': escaped = "\\r"; break;
            case '\n': escaped = "\\n"; break;
            case '\\': escaped = "\\\\"; break;
            case '"': escaped = "\\\""; break;
            case '\f': escaped = "\\f"; break;
            case '\b': escaped = "\\b"; break;
            case '\t': escaped = "\\t"; break;
            default: {
                int codePointChar = curByte & 0xff;
                unsigned long codePoint = codePointChar;
                char hexEsc[7] = "\\u0000";
                const unsigned char hexChars[17] = "0123456789abcdef";

                if (asciiOnly) {
                    unsigned int numChars;

                    if (!(codePoint & 0x80)) {
                        if (curByte < 0x20) {
                            hexEsc[5] = hexChars[codePoint & 0x0f];
                            hexEsc[4] = hexChars[(codePoint >> 4) & 0x0f];
                            escaped = hexEsc;
                        }
                        break;
                    }

                    if (!(codePoint & 0x40)) {
                        // malformed UTF-8 character
                        // return invalidUtf8;
                        return;
                    }

                    if      (!(codePoint & 0x20)) { numChars = 2; codePoint &= 0x1f; }
                    else if (!(codePoint & 0x10)) { numChars = 3; codePoint &= 0x0f; }
                    else if (!(codePoint & 0x08)) { numChars = 4; codePoint &= 0x07; }
                    else if (!(codePoint & 0x04)) { numChars = 5; codePoint &= 0x03; }
                    else if (!(codePoint & 0x02)) { numChars = 6; codePoint &= 0x01; }
                    else {
                        // malformed UTF-8 character
                        // return invalidUtf8;
                        return;
                    }
                    while(--numChars) {
                        curByte = str[++curPos];
                        codePointChar = curByte & 0xff;
                        if ((codePointChar & 0xc0) != 0x80) {
                            // malformed UTF-8 character
                            // return invalidUtf8;
                            return;
                        } else {
                            codePointChar &= 0x3f;
                            codePoint = codePoint << 6 | codePointChar;
                        }
                    }

                    if (codePoint < utf8_limits[numChars]) {
                        // redundant UTF-8 sequence
                        // return invalidUtf8;
                        return;
                    }

                    hexEsc[5] = hexChars[codePoint & 0x0f];
                    hexEsc[4] = hexChars[(codePoint >> 4) & 0x0f];
                    hexEsc[3] = hexChars[(codePoint >> 8) & 0x0f];
                    hexEsc[2] = hexChars[(codePoint >> 12) & 0x0f];
                    escaped = hexEsc;
                    break;
                } else {
                    // let everything pass through un-touched
                    // except ascii control chars
                    if (!(codePoint & 0x80)) {
                        if (curByte < 0x20) {
                            hexEsc[5] = hexChars[codePoint & 0x0f];
                            hexEsc[4] = hexChars[(codePoint >> 4) & 0x0f];
                            escaped = hexEsc;
                        }
                    }
                    break;
                }
            }
        }
        if (escaped != NULL) {
            print(ctx, escaped, strlen(escaped));
        } else {
            print(ctx, &curByte, 1);
        }
        curPos++;
    }
}

static void hexToDigit(unsigned int * val, const unsigned char * hex)
{
    unsigned int i;
    for (i=0;i<4;i++) {
        unsigned char c = hex[i];
        if (c >= 'A') c = (c & ~0x20) - 7;
        c -= '0';
        assert(!(c & 0xF0));
        *val = (*val << 4) | c;
    }
}

static void Utf32toUtf8(unsigned int codepoint, char * utf8Buf) 
{
    if (codepoint < 0x80) {
        utf8Buf[0] = (char) codepoint;
        utf8Buf[1] = 0;
    } else if (codepoint < 0x0800) {
        utf8Buf[0] = (char) ((codepoint >> 6) | 0xC0);
        utf8Buf[1] = (char) ((codepoint & 0x3F) | 0x80);
        utf8Buf[2] = 0;
    } else if (codepoint < 0x10000) {
        utf8Buf[0] = (char) ((codepoint >> 12) | 0xE0);
        utf8Buf[1] = (char) (((codepoint >> 6) & 0x3F) | 0x80);
        utf8Buf[2] = (char) ((codepoint & 0x3F) | 0x80);
        utf8Buf[3] = 0;
    } else if (codepoint < 0x200000) {
        utf8Buf[0] =(char)((codepoint >> 18) | 0xF0);
        utf8Buf[1] =(char)(((codepoint >> 12) & 0x3F) | 0x80);
        utf8Buf[2] =(char)(((codepoint >> 6) & 0x3F) | 0x80);
        utf8Buf[3] =(char)((codepoint & 0x3F) | 0x80);
        utf8Buf[4] = 0;
    } else {
        utf8Buf[0] = '?';
        utf8Buf[1] = 0;
    }
}

void yajl_string_decode(yajl_buf buf, const unsigned char * str,
                        unsigned int len)
{
    unsigned int beg = 0;
    unsigned int end = 0;    

    while (end < len) {
        if (str[end] == '\\') {
            char utf8Buf[5];
            const char * unescaped = "?";
            yajl_buf_append(buf, str + beg, end - beg);
            switch (str[++end]) {
                case 'r': unescaped = "\r"; break;
                case 'n': unescaped = "\n"; break;
                case '\\': unescaped = "\\"; break;
                case '/': unescaped = "/"; break;
                case '"': unescaped = "\""; break;
                case 'f': unescaped = "\f"; break;
                case 'b': unescaped = "\b"; break;
                case 't': unescaped = "\t"; break;
                case 'u': {
                    unsigned int codepoint = 0;
                    hexToDigit(&codepoint, str + ++end);
                    end+=3;
                    /* check if this is a surrogate */
                    if ((codepoint & 0xFC00) == 0xD800) {
                        end++;
                        if (str[end] == '\\' && str[end + 1] == 'u') {
                            unsigned int surrogate = 0;
                            hexToDigit(&surrogate, str + end + 2);
                            codepoint =
                                (((codepoint & 0x3F) << 10) | 
                                 ((((codepoint >> 6) & 0xF) + 1) << 16) | 
                                 (surrogate & 0x3FF));
                            end += 5;
                        } else {
                            unescaped = "?";
                            break;
                        }
                    }
                    
                    Utf32toUtf8(codepoint, utf8Buf);
                    unescaped = utf8Buf;
                    break;
                }
                default:
                    assert("this should never happen" == NULL);
            }
            yajl_buf_append(buf, unescaped, strlen(unescaped));
            beg = ++end;
        } else {
            end++;
        }
    }
    yajl_buf_append(buf, str + beg, end - beg);
}
