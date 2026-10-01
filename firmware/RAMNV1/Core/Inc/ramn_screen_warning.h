/*
 * ramn_screen_warning.h
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

// This module implements a warning screen, displayed when a warning message
// is received over CAN.

#ifndef INC_RAMN_SCREEN_WARNING_H_
#define INC_RAMN_SCREEN_WARNING_H_

#include "main.h"

#if defined(ENABLE_SCREEN) && defined(ENABLE_WARNING_SCREEN)

#include "ramn_screen_utils.h"

extern RAMNScreen_t ScreenWarning;

void RAMN_SCREENWARNING_ProcessRxCANMessage(const FDCAN_RxHeaderTypeDef* pHeader, const uint8_t* data, uint32_t tick);

RAMN_Bool_t RAMN_SCREENWARNING_IsActive();

#endif
#endif /* INC_RAMN_SCREEN_WARNING_H_ */
