Tx_Power_BS = 43; %мощность передатчика базы дБм
Feeder_Loss = 2.9; %уровень потерь сигнала при прохождение через фидер, джампер, МШУ, дБ
Ant_Gain_BS = 21; %коэффициент усиления антенны дБи
MIMO_Gain = 3; %выигрыш за счёт MIMO дБ
IM = 6; %запас мощности на интерференцию дБ
Penetration_M = 17; %запас сигнала на через стены дБ
Tx_Power_UE = 23; %мощность передатчика пользователя дБм
Freq = 1.9e9; %диапозон частот ГГц
Polosa_DL_UL = 20e6; %полоса частот МГц
Noise_BS = 2.4; %коэф шума приёмника базы дБ
Noise_UE = 7; %коэф шума приёмника пользователя дБ
SINR_DL = 11; %дБ
SINR_UL = 14; %дБ
S_TER = 100e6; %Площадь территории, на которой требуется спроектировать сеть COST 231 Hata m^2
S_OFFICE = 4e6; %Площадь торговых и бизнес центров UMiNLOS m^2
Rx_Sens_BS = Noise_BS - 174 + 10*log10(Polosa_DL_UL) + SINR_UL; %чувствит приёмника базы
Rx_Sens_UE = Noise_UE - 174 + 10*log10(Polosa_DL_UL) + SINR_DL; %чувствит приёмника пользователя
MAPL_DL = Tx_Power_BS - Feeder_Loss + Ant_Gain_BS + MIMO_Gain - IM - Penetration_M - Rx_Sens_UE;
MAPL_UL = Tx_Power_UE - Feeder_Loss + Ant_Gain_BS + MIMO_Gain - IM - Penetration_M - Rx_Sens_BS;
disp(MAPL_UL);
disp(MAPL_DL);

d = 1:1000; % distance in meters

figure;
subplot(2,1,1);
lambda = physconst('LightSpeed')/Freq; % wavelength
PL_FSPM(d) = 20*log10(4*pi*d/lambda); % path loss in dB
plot(d, PL_FSPM(d));
legend('FSPM');
hold on;
subplot(2,1,2);
PL_UMinLOS(d) = 26*log10(Freq/power(10, 9)) + 22.7 + 36.7*log10(d);
plot(d, PL_UMinLOS(d));
hold on;

line([1 1000],[MAPL_DL MAPL_DL],'Color','r','LineStyle','--');
line([1 1000],[MAPL_UL MAPL_UL],'Color','b','LineStyle','--');

A=46.3;
B=33.9;
hBS=100;%m
Lscutter=0;%city
hms=5;%m
a=3.2*power(log10(11.75*hms), 2) - 4.97;
s=(47.88+13.9*log10(Freq/power(10, 6))-13.9*log10(hBS))*1/log10(50);
PL_COST231(d)=A+B*log10(Freq/power(10, 6)) - 13.82*log10(hBS) - a + s*log10(d/1000)+Lscutter;
plot(d, PL_COST231(d));
hold on;

WalfishIkegami_LOS(d)=42.6+20*log10(Freq/power(10, 6))+26*log10(d/1000);
plot(d, WalfishIkegami_LOS(d));
hold on;

hBS=30;
hms=2;
w=30;
dh=200;
b=20;
W=30;
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

title('FSPM & UMinLOS & COST231 & Walfish-Ikegami Model');
xlabel('Distance (m)');
ylabel('Path Loss (dB)');
legend('UMinLOS', 'MAPL-DL', 'MAPL-UL', 'COST231', 'Walfish-Ikegami-LOS', 'Walfish-Ikegami-NLOS');

R_TER=321; %m
R_OFFICE=116; %m
S_SOT_TER=1.95*power(R_TER, 2);
S_SOT_OFFICE=1.95*power(R_OFFICE, 2);
N_SOT_TER=S_TER/S_SOT_TER;
N_SOT_OFFICE=S_OFFICE/S_SOT_OFFICE;
disp(N_SOT_TER);
disp(N_SOT_OFFICE);