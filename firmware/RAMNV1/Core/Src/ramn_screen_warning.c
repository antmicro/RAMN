/*
 * ramn_screen_warning.c
 ******************************************************************************
 * @attention
 *
 * <h2><center>&copy; Copyright (c) 2026 TOYOTA MOTOR CORPORATION.
 * ALL RIGHTS RESERVED.</center></h2>
 *
 * This software component is licensed by TOYOTA MOTOR CORPORATION under BSD 3-Clause license,
 * the "License"; You may not use this file except in compliance with the
 * License. You may obtain a copy of the License at:
 *                        opensource.org/licenses/BSD-3-Clause
 *
 ******************************************************************************
 */

#include "ramn_screen_warning.h"

#if defined(ENABLE_SCREEN) && defined(ENABLE_WARNING_SCREEN)

#include "ramn_screen_warning_image.h"

#define WARNING_BACKGROUND      COLOR_RED
#define WARNING_FOREGROUND      COLOR_WHITE

#define WARNING_LINE1           "COLLISION"
#define WARNING_LINE2           "IMMINENT"

#define WARNING_BORDER_WIDTH    4
#define WARNING_TRIANGLE_X      ((LCD_WIDTH - RAMN_WARNING_TRIANGLE_WIDTH) / 2)
#define WARNING_TRIANGLE_Y      32
#define STRLEN(s)               (sizeof(s) - 1)
// Strings are centred using the font width (11 pixels per character in Font16).
#define WARNING_LINE1_X         ((LCD_WIDTH - (STRLEN(WARNING_LINE1) * 11)) / 2)
#define WARNING_LINE1_Y         (WARNING_TRIANGLE_Y + RAMN_WARNING_TRIANGLE_HEIGHT + 16)
#define WARNING_LINE2_X         ((LCD_WIDTH - (STRLEN(WARNING_LINE2) * 11)) / 2)
#define WARNING_LINE2_Y         (WARNING_LINE1_Y + 20)

static volatile RAMN_Bool_t warningActive = False;

void RAMN_SCREENWARNING_ProcessRxCANMessage(const FDCAN_RxHeaderTypeDef* pHeader, const uint8_t* data, uint32_t tick)
{
	(void)tick;

	if (pHeader->IdType != FDCAN_STANDARD_ID) return;
	if (pHeader->RxFrameType != FDCAN_DATA_FRAME) return;
	if (pHeader->Identifier != DID_WARNING) return;
	if (pHeader->DataLength < 1U) return;

	warningActive = !!data[0];
}

RAMN_Bool_t RAMN_SCREENWARNING_IsActive()
{
	return warningActive;
}

static void SCREENWARNING_Init()
{
	RAMN_SPI_DrawRectangle(0, 0, LCD_WIDTH, LCD_HEIGHT, WARNING_BACKGROUND);
	RAMN_SPI_DrawContour(0, 0, LCD_WIDTH, LCD_HEIGHT, WARNING_BORDER_WIDTH, WARNING_FOREGROUND);

	RAMN_SPI_DrawImage(WARNING_TRIANGLE_X, WARNING_TRIANGLE_Y, RAMN_WARNING_TRIANGLE_WIDTH, RAMN_WARNING_TRIANGLE_HEIGHT, WarningTriangle);
	RAMN_SPI_DrawString(WARNING_LINE1_X, WARNING_LINE1_Y, WARNING_FOREGROUND, WARNING_BACKGROUND, WARNING_LINE1);
	RAMN_SPI_DrawString(WARNING_LINE2_X, WARNING_LINE2_Y, WARNING_FOREGROUND, WARNING_BACKGROUND, WARNING_LINE2);
}

static void SCREENWARNING_Update(uint32_t tick)
{
	(void)tick;
}

RAMNScreen_t ScreenWarning = {
		.Init = SCREENWARNING_Init,
		.Update = SCREENWARNING_Update,
		.Deinit = 0U,
		.UpdateInput = 0U,
		.ProcessRxCANMessage = 0U
};

#endif
