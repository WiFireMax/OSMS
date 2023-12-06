#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#define PACKET_LENGTH 250 //23
#define CRC_LENGTH 7

int main() {
    int packet[PACKET_LENGTH + CRC_LENGTH];
    int generator[] = {1, 1, 1, 0, 1, 1, 1, 1}; // порождающий полином G для делителя: 11101111
    int i, j;
	srand(time(NULL));
    // Создание рандомного пакета данных
    for (i = 0; i < PACKET_LENGTH; i++) {
        packet[i] = rand() % 2;
    }

    // Вывод рандомного пакета данных
    printf("Рандомный пакет данных: ");
    for (i = 0; i < PACKET_LENGTH; i++) {
        printf("%d", packet[i]);
    }
    printf("\n");

    // Добавление нулей для вычисления CRC
    for (i = PACKET_LENGTH; i < PACKET_LENGTH + CRC_LENGTH; i++) {
        packet[i] = 0;
    }

    // Вычисление CRC
    for (i = 0; i < PACKET_LENGTH; i++) {
        if (packet[i] == 1) {
            for (j = 0; j < CRC_LENGTH; j++) {
                packet[i+j] = packet[i+j] ^ generator[j];
            }
        }
    }

    // Вывод полученного значения CRC
    printf("Значение CRC: ");
    for (i = PACKET_LENGTH; i < PACKET_LENGTH + CRC_LENGTH; i++) {
        printf("%d", packet[i]);
    }
    printf("\n");

    // Искажение пакета данных и CRC
    int errors_detected = 0;
    int errors_undetected = 0;
    for (i = 0; i < PACKET_LENGTH + CRC_LENGTH; i++) {
        int bit = packet[i];
        packet[i] = !bit; // инвертирование бита
        int remainder = 0;
        for (j = 0; j < PACKET_LENGTH; j++) {
            if (packet[j] == 1) {
            for (int k = 0; k < CRC_LENGTH; k++) {
                packet[j+k] = packet[j+k] ^ generator[k];
            }
            }
        }
        for (int h = PACKET_LENGTH; h < PACKET_LENGTH + CRC_LENGTH; h++) {
            if (packet[h] == 1) {
                remainder += 1;
            }
        }
        if (remainder == 0) {
            errors_undetected++;
            printf("Искаженный бит: %d\n", i);
        } else {
            errors_detected++;
        }
        packet[i] = bit; // восстановление исходного бита
    }

    // Вывод отчета об ошибках
    printf("Количество обнаруженных ошибок: %d\n", errors_detected);
    printf("Количество необнаруженных ошибок: %d\n", errors_undetected);

    return 0;
}
