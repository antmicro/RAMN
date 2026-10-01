/*
 * Image source: https://commons.wikimedia.org/wiki/File:ISO_7010_W001.svg
 * Scaled to 128x112 px (largest side: 128) for display.
 *
 * Regenerate the .c file with:
 *
 *   magick misc/warning_triangle.png -background '#FF0000' -alpha remove -alpha off PNG24:- \
 *     | ffmpeg -v error -y -i - -sws_flags neighbor -pix_fmt rgb565le -f rawvideo /tmp/warning_triangle.rgb565
 *   { echo '// Generated from misc/warning_triangle.png, see ramn_screen_warning_image.h. Do not edit by hand.'; \
 *     echo; echo '#include "ramn_screen_warning_image.h"'; echo; \
 *     xxd -i -n WarningTriangle /tmp/warning_triangle.rgb565 \
 *       | sed -e 's/^unsigned char/const uint8_t/' -e '/_len =/d'; } \
 *     > firmware/RAMNV1/Core/Src/ramn_screen_warning_image.c
 */

#ifndef INC_RAMN_SCREEN_WARNING_IMAGE_H_
#define INC_RAMN_SCREEN_WARNING_IMAGE_H_

#include <stdint.h>

#define RAMN_WARNING_TRIANGLE_WIDTH  128
#define RAMN_WARNING_TRIANGLE_HEIGHT 112

extern const uint8_t WarningTriangle[RAMN_WARNING_TRIANGLE_WIDTH * RAMN_WARNING_TRIANGLE_HEIGHT * 2];

#endif /* INC_RAMN_SCREEN_WARNING_IMAGE_H_ */
