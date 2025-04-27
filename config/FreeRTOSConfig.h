#ifndef FREERTOS_CONFIG_H
#define FREERTOS_CONFIG_H

/*-----------------------------------------------------------
 * Application specific definitions.
 * Adjust these as needed for your app.
 *----------------------------------------------------------*/

#define configUSE_PREEMPTION                    1
#define configUSE_IDLE_HOOK                     0
#define configUSE_TICK_HOOK                     0
#define configCPU_CLOCK_HZ                      100000000  // 100 MHz for tile
#define configTICK_RATE_HZ                      1000
#define configMAX_PRIORITIES                    5
#define configMINIMAL_STACK_SIZE                256
#define configTOTAL_HEAP_SIZE                   (16 * 1024)
#define configMAX_TASK_NAME_LEN                 16
#define configUSE_TRACE_FACILITY                1
#define configUSE_16_BIT_TICKS                  0
#define configIDLE_SHOULD_YIELD                 1
#define configUSE_CO_ROUTINES                   0
#define configUSE_MUTEXES                       1
#define configUSE_RECURSIVE_MUTEXES             1
#define configUSE_COUNTING_SEMAPHORES           1
#define configUSE_MALLOC_FAILED_HOOK            1
#define configUSE_APPLICATION_TASK_TAG          0

/* Hook function related definitions */
#define configCHECK_FOR_STACK_OVERFLOW          2

/* Software timer related definitions. */
#define configUSE_TIMERS                        1
#define configTIMER_TASK_PRIORITY               (configMAX_PRIORITIES - 1)
#define configTIMER_QUEUE_LENGTH                10
#define configTIMER_TASK_STACK_DEPTH            512

/* Include/Exclude API functions */
#define INCLUDE_vTaskPrioritySet                1
#define INCLUDE_uxTaskPriorityGet               1
#define INCLUDE_vTaskDelete                     1
#define INCLUDE_vTaskCleanUpResources           0
#define INCLUDE_vTaskSuspend                    1
#define INCLUDE_vTaskDelayUntil                 1
#define INCLUDE_vTaskDelay                      1
#define INCLUDE_xTaskGetSchedulerState          1
#define INCLUDE_xTimerPendFunctionCall          1

/* For assert-style debugging */
void vAssertCalled(const char *file, int line);
#define configASSERT(x) if ((x) == 0) vAssertCalled(__FILE__, __LINE__)

/* Map the FreeRTOS port interrupt handlers */
#define xPortSysTickHandler     SysTick_Handler
#define vPortSVCHandler         SVC_Handler
#define xPortPendSVHandler      PendSV_Handler

/* Use XMOS architecture */
#define portOPTIMIZED_TASK_SELECTION 0

#endif /* FREERTOS_CONFIG_H */

