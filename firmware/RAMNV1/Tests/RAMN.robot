*** Settings ***
Documentation   Testing RAMN firmwares with Renode.
Test Setup      RAMN Test Setup
Suite Setup     RAMN Suite Setup


*** Variables ***
${LED_HOLDING_TIMEOUT}          2
${BOOT_MENU_FRAME_URL}          https://dl.antmicro.com/projects/renode/ramn-boot-menu.png-s_2047-1b05b683c24ebaf1a17d05eae4c675be82ca78ea

&{UDS_RX_ID}                    ECUA=0x7e0  ECUB=0x7e1  ECUC=0x7e2  ECUD=0x7e3
${UDS_TX_ID_OFFSET}             8
${UDS_TESTER_PRESENT}           0x3e
${POSITIVE_RESPONSE_OFFSET}     0x40


*** Test Cases ***
Should Produce CAN Traffic
    [Documentation]     Using Renode's log tester to ensure that ECUB, ECUC and ECUD are producing
    ...                 CAN messages.

    Create Log Tester   timeout=1
    Execute Command     logLevel 0 canHub

    FOR     ${ECU}  IN  ECUB    ECUC    ECUD
        Wait For Log Entry  canHub: Received from ${ECU}
    END

ECUA Should Display Boot Menu
    [Documentation]         Using Renode's frame buffer tester to ensure that boot menu is displayed

    # As RAMN firmware is randomly choosing a theme, the seed must be set to have reproducible tests
    Execute Command         emulation SetSeed 0

    Execute Command         emulation CreateFrameBufferTester "fb_tester" 10
    Execute Command         fb_tester AttachTo sysbus.spi2.screen               machine=ECUA
    Execute Command         fb_tester WaitForFrame @${BOOT_MENU_FRAME_URL}

Should Provide Started Platform
    [Documentation]     Boot the 4-ECU platforms and run the emulation to skip startup sequence

    Execute Command     emulation RunFor "5s"
    Provides            post-startup

Brake Should Affect Brake LED
    [Documentation]     Using Renode's LED tester to validate the data path ECUC's ADC --> ECUC's
    ...                 CAN --> ECUD's CAN --> ECUD's SPI.

    Requires            post-startup

    Create LED Tester   sysbus.spi2.ledController.parkingBrake  machine=ECUD
    Execute Command     adc1.brake SetPercentage 0              machine=ECUC
    Execute Command     adc1.parkingBrake CurrentState "off"    machine=ECUB

    Assert And Hold Led State   false   timeoutAssert=0     timeoutHold=${LED_HOLDING_TIMEOUT}
    Execute Command     adc1.brake SetPercentage 80              machine=ECUC
    Assert And Hold Led State   true   timeoutAssert=1     timeoutHold=${LED_HOLDING_TIMEOUT}

ECUs Should Respond To Tester Present UDS Command
    [Documentation]     Using Renode's CAN Tester to test UDS reception

    ${TESTER_PRESENT_DATA} =    Set Variable    00
    ${TESTER_PRESENT_RESP} =    Evaluate        ${UDS_TESTER_PRESENT} + ${POSITIVE_RESPONSE_OFFSET}
    ${EXPECTED_RESP} =          Convert To Hex  ${TESTER_PRESENT_RESP}

    Requires                    post-startup
    Create CAN Tester           canHub  1

    FOR     ${ECU}  IN  ECUA    ECUB    ECUC    ECUD
        ${send_id} =        Evaluate    ${UDS_RX_ID}[${ECU}]
        ${recv_id} =        Evaluate    ${send_id} + ${UDS_TX_ID_OFFSET}
        ${response} =       Send UDS Command And Wait For Positive Response     ${send_id}
        ...                 ${recv_id}  service=${UDS_TESTER_PRESENT}  data=${TESTER_PRESENT_DATA}

        Should Be Equal     ${response}     ${EXPECTED_RESP}${TESTER_PRESENT_DATA}
    END


*** Keywords ***
RAMN Suite Setup
    [Documentation]     Display warnings if default firmware are used and setup Renode.

    FOR     ${ECU}  IN  ECUA    ECUB    ECUC    ECUD
        TRY
            Log     Using ELF file ${${ECU}_ELF} for ${ECU}
        EXCEPT  Variable * not found.   type=GLOB
            Log     Using default ${ECU} from Renode script.     level=WARN
        END
    END
    Setup

RAMN Test Setup
    [Documentation]     Prepare Renode with RAMN firmwares.

    Test Setup

    # Using ramn.resc from Renode, that uses bin_ECU{A,B,C,D} variables to load ELF files.
    FOR     ${ECU}  IN  ECUA    ECUB    ECUC    ECUD
        TRY
            Execute Command     $global.bin_${ECU} = @${${ECU}_ELF}
        EXCEPT  Variable * not found.   type=GLOB
            Log     Using default ${ECU} from Renode script.     level=TRACE
        END
    END
    Execute Command     include @scripts/multi-node/ramn.resc
