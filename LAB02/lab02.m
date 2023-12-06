Tx_Power_BS = 46; %мощность передатчика базы дБм
Feeder_Loss = 2.9; %уровень потерь сигнала при прохождение через фидер, джампер, МШУ, дБ
Ant_Gain_BS = 21; %коэффициент усиления антенны дБи
MIMO_Gain = 3; %выигрыш за счёт MIMO дБ
IM = 1; %запас мощности на интерференцию дБ
Penetration_M = 15; %запас сигнала на через стены дБ
Tx_Power_UE = 24; %мощность передатчика пользователя дБм
Freq = 1.8e9; %диапозон частот Гц
Polosa_DL = 10e6; %полоса частот Гц DL
Polosa_UL = 20e6; %полоса частот Гц UL
Noise_BS = 2.4; %коэф шума приёмника базы дБ
Noise_UE = 6; %коэф шума приёмника пользователя дБ
SINR_DL = 2; %дБ
SINR_UL = 4; %дБ
S_TER = 100e6; %Площадь территории, на которой требуется спроектировать сеть COST 231 Hata m^2
S_OFFICE = 4e6; %Площадь торговых и бизнес центров UMiNLOS m^2
Rx_Sens_BS = Noise_BS - 174 + 10*log10(Polosa_UL) + SINR_UL; %чувствит приёмника базы
Rx_Sens_UE = Noise_UE - 174 + 10*log10(Polosa_DL) + SINR_DL; %чувствит приёмника пользователя
MAPL_DL = Tx_Power_BS - Feeder_Loss + Ant_Gain_BS + MIMO_Gain - IM - Penetration_M - Rx_Sens_UE;
MAPL_UL = Tx_Power_UE - Feeder_Loss + Ant_Gain_BS + MIMO_Gain - IM - Penetration_M - Rx_Sens_BS;
disp('Потери в UL ='); fprintf('%d dB\n', MAPL_UL);
disp('Потери в DL = '); fprintf('%d dB\n', MAPL_DL);

figure;
subplot(3,1,1);
d=1:10000;
%FSPM
lambda = physconst('LightSpeed')/Freq; % wavelength
PL_FSPM(d) = 20*log10(4*pi*d/lambda); % path loss in dB
plot(d, PL_FSPM(d));
title('FSPM Model');
xlabel('Distance (m)');
ylabel('Path Loss (dB)');
line([1 10000],[MAPL_DL MAPL_DL],'Color','r','LineStyle','--'); %MAPL_DL
line([1 10000],[MAPL_UL MAPL_UL],'Color','b','LineStyle','--'); %MAPL_UL
legend('FSPM', 'MAPL-DL', 'MAPL-UL');
hold on;
subplot(3,1,2);
d = 1:5000; % distance in meters
%UMinLOS
PL_UMinLOS(d) = 26*log10(Freq/power(10, 9)) + 22.7 + 36.7*log10(d);
plot(d, PL_UMinLOS(d));
hold on;

line([1 5000],[MAPL_DL MAPL_DL],'Color','r','LineStyle','--'); %MAPL_DL
line([1 5000],[MAPL_UL MAPL_UL],'Color','b','LineStyle','--'); %MAPL_UL

%WalfishIkegami_LOS
WalfishIkegami_LOS(d)=42.6+20*log10(Freq/power(10, 6))+26*log10(d/1000);
plot(d, WalfishIkegami_LOS(d));
hold on;

%WalfishIkegami_NLOS
hBS=30; %m BS
hms=2; %m MobStation
w=30; %градус
dh=200; %высота зданий m
b=20; %m между зданиями
W=30; %m ширина улицы
if (w>=0) && (w < 35)
    dw = -10+0.354*w;
end
if (w>=35) && (w < 55)
    dw = 25+0.075*w;
end
if (w>=55) && (w < 90)
    dw = 4.0-0.114*w;
end
L0=32.44+20*log10(Freq/power(10, 6))+20*log10(d/1000);
L2=-16.9-10*log10(W)+10*log10(Freq/power(10, 6))+20*log10(dh-hms)+dw;

if hBS > dh 
    L11=-18*log10(1+hBS-dh);
    ka=54;
    kd=18;
else 
    L11=0;
    if d/1000 > 0.5 
        ka=54-0.8*(hBS-dh);
    else
        ka=54-0.8*(hBS-dh)*d/(1000*0.5);
    end
    kd=18-15*(hBS-dh)/dh;
end
kf=-4+0.7*(Freq/(925*power(10, 6))-1);

L1=L11+ka+kd*log10(d/1000)+kf*log10(Freq/power(10, 6))-9*log10(b);

if (L1+L2) > 0
    WalfishIkegami_NLOS(d)=L0+L1+L2;
else
    WalfishIkegami_NLOS(d)=L0;
end
plot(d, WalfishIkegami_NLOS(d));
hold on;

title('UMinLOS & Walfish-Ikegami Model');
xlabel('Distance (m)');
ylabel('Path Loss (dB)');
legend('UMinLOS', 'MAPL-DL', 'MAPL-UL', 'Walfish-Ikegami-LOS', 'Walfish-Ikegami-NLOS');

R_TER=994; %m
R_OFFICE=373; %m
S_SOT_TER=1.95*power(R_TER, 2);
S_SOT_OFFICE=1.95*power(R_OFFICE, 2);
N_SOT_TER=S_TER/S_SOT_TER;
N_SOT_OFFICE=S_OFFICE/S_SOT_OFFICE;
disp('Количество макросот HATA COST231='); fprintf('%d\n', N_SOT_TER);
disp('Количество микросот UMinLOS='); fprintf('%d\n', N_SOT_OFFICE);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%HATA COST 231
%1900 MHz
subplot(3,1,3);
d=1:12000;
A=46.3;
B=33.9;
hBS=100;%m BS
Lscutter=0;%city
hms=5;%m MobStation
a=3.2*power(log10(11.75*hms), 2) - 4.97;
s=(47.88+13.9*log10(Freq/power(10, 6))-13.9*log10(hBS))*1/log10(50);
PL_COST231_city(d)=A+B*log10(Freq/power(10, 6)) - 13.82*log10(hBS) - a + s*log10(d/1000)+Lscutter;
plot(d, PL_COST231_city(d));
hold on;
Lscutter=-(4.78*power(log10(Freq/power(10, 6)), 2) - 18.33*log10(Freq/power(10, 6)) + 40.94); %rural
a=(1.1*log10(Freq/power(10, 6)))*hms-(1.56*log10(Freq/power(10, 6))-0.8);
PL_COST231_rural(d)=A+B*log10(Freq/power(10, 6)) - 13.82*log10(hBS) - a + s*log10(d/1000)+Lscutter;
plot(d, PL_COST231_rural(d));
title('HATA COST231 city&rural Model');
xlabel('Distance (m)');
ylabel('Path Loss (dB)');
line([1 12000],[MAPL_DL MAPL_DL],'Color','r','LineStyle','--'); %MAPL_DL
line([1 12000],[MAPL_UL MAPL_UL],'Color','b','LineStyle','--'); %MAPL_UL
legend('COST231-city', 'COST231-rural', 'MAPL-DL', 'MAPL-UL');
R_CITY=994; %m
R_RURAL=11100; %m