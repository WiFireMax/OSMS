#define _USE_MATH_DEFINES
#include <stdio.h>
#include <math.h>

int main() {
//Условие
int a[]={6, 2, 8, -2, -4, -4, 1, 3};
int b[]={3, 6, 7, 0, -5, -4, 2, 5};
int c[]={-1, -1, 3, -9, 2, -8, 4, -1};
//Корреляция
float rhoab = 0;
float rhoac = 0;
float rhobc = 0;

for (int i=0; i<=7; i++) {
      rhoab += a[i]*b[i];
      rhobc += c[i]*b[i];
      rhoac += c[i]*a[i];
}

//Нижняя часть дроби
float powa=0;
float powc=0;
float powb=0;

for (int j=0; j<=7; j++) {
	powa += (float)pow(a[j], 2);
	powc += (float)pow(c[j], 2);
	powb += (float)pow(b[j], 2);
}
float deoniatorab = (float)sqrt((powa)*(powb));
float deoniatorcb = (float)sqrt((powc)*(powb));
float deoniatorac = (float)sqrt((powa)*(powc));
//Нормализ корреляция
float xrhoab=rhoab/deoniatorab;
float xrhobc=rhobc/deoniatorcb;
float xrhoac=rhoac/deoniatorac;
//вывод в виде таблиц
printf("\\|    a      |     b     |  c \n");
printf("a|     -     |%.6f |%.6f\n", rhoab, rhoac);
printf("b|%.6f |     -     |%.6f\n", rhoab, rhobc);
printf("c|%.6f  | %.6f |  -\n\n", rhoac, rhobc);

printf("\\|    a    |    b    |  c \n");
printf("a|    -    |%.6f |%.6f\n", xrhoab, xrhoac);
printf("b|%.6f |    -    |%.6f\n", xrhoab, xrhobc);
printf("c|%.6f |%.6f |  -\n", xrhoac, xrhobc);
return 0;

}
