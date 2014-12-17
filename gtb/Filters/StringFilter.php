<?php

namespace Cloud\CoreBundle;

final class StringFilter
{
    private function __construct()
    {
    }

    /**
     * Filters unsafe characters from filename.
     *
     * @param string $filename
     * @return string
     */
    public static function filename($filename)
    {
        return preg_replace("([^a-zA-Z0-9 \-_\.]|[\.]{2,})", '-', $filename);
    }

    /**
     * Truncates the string to a given length, ensuring that it does not
     * split words. If $substring is provided, and truncating occurs, the
     * string is further truncated so that the substring may be appended without
     * exceeding the desired length.
     *
     * (adapted from https://github.com/danielstjules/Stringy)
     *
     * Copyright (C) 2013 Daniel St. Jules
     *
     * Permission is hereby granted, free of charge, to any person obtaining a copy
     * of this software and associated documentation files (the "Software"), to deal
     * in the Software without restriction, including without limitation the rights
     * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
     * copies of the Software, and to permit persons to whom the Software is
     * furnished to do so, subject to the following conditions:
     *
     * The above copyright notice and this permission notice shall be included in
     * all copies or substantial portions of the Software.
     *
     * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
     * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
     * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
     * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
     * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
     * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
     * THE SOFTWARE.
     *
     * @param string    $string     The string to truncate
     * @param int       $length     Desired length of the truncated string
     * @param string    $appendStr  The substring to append if it can fit
     * @param null      $encoding   The character encoding
     * @return string   The resulting string after truncating
     */
    public static function truncate($string, $length, $appendStr = '...', $encoding = null)
    {
        if ($length >= strlen($string)) {
            return $string;
        }

        $encoding = $encoding ?: mb_internal_encoding();

        // Need to further trim the string so we can append the substring
        $appendStrLength = mb_strlen($appendStr, $encoding);
        $length = $length - $appendStrLength;

        $truncated = mb_substr($string, 0, $length, $encoding);

        // If the last word was truncated
        if (mb_strpos($string, ' ', $length - 1, $encoding) != $length) {
            // Find pos of the last occurrence of a space, get up to that
            $lastPos = mb_strrpos($truncated, ' ', 0, $encoding);
            $truncated = mb_substr($truncated, 0, $lastPos, $encoding);
        }

        return $truncated . $appendStr;
    }
}
