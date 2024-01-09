%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Сформируйте битовую последовательность, состоящую из L
%битов, кодирующих ваши имя и фамилию латинице ASCII-символов.
%Результат: массив нулей и единиц с данными и разработанный ASCII-кодер.
% Визуализируйте последовательность на графике.

% Задание имени и фамилии
% Ввод имени и фамилии с клавиатуры
name = input('Введите имя: ', 's');
surname = input('Введите фамилию: ', 's');
full_name = strcat(name, surname);
% Преобразование символов в числовые коды ASCII
full_name_ascii = double(full_name);

% Преобразование числовых кодов в бинарные последовательности
full_name_binary = de2bi(full_name_ascii, 8, 'left-msb'); %8 бит для каждой буквы
full_name_binary = reshape(full_name_binary.', 1, []);
figure;
subplot(4,1,1);
plot(full_name_binary);
title('Массив с информацией');
xlim([1, length(full_name_binary)]);
ylim([-0.2, 1.2]);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Вычислите CRC длиной M бит для данной последовательности,
%используя входные данные для своего варианта из работы №5 и добавьте к
%битовой последовательности. Результат: CRC-генератор и выведенный в
%терминал CRC
original_massive = full_name_binary;
CRC_LENGTH = 7;
PACKET_LENGTH = length(full_name_binary);
generator = [1, 1, 1, 0, 1, 1, 1, 1]; % порождающий полином G для делителя: 11101111
rng('shuffle');

% Добавление нулей для вычисления CRC
for i = PACKET_LENGTH+1:PACKET_LENGTH+CRC_LENGTH
    full_name_binary(i) = 0;
end

% Вычисление CRC
for i = 1:PACKET_LENGTH
    if full_name_binary(i) == 1
        for j = 1:CRC_LENGTH+1
            full_name_binary(i+j-1) = xor(full_name_binary(i+j-1), generator(j));
        end
    end
end
% Вывод полученного значения CRC
fprintf('Значение CRC: ');
for i = PACKET_LENGTH+1:PACKET_LENGTH+CRC_LENGTH
    fprintf('%d', full_name_binary(i));
    original_massive(i)=full_name_binary(i);
end
fprintf('\n');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Для этого
%перед отправкой полученной последовательности добавьте
%последовательность Голда, которую вы реализовывали в работе №4, длиной
%G-бит.

x = [0, 0, 0, 1, 1]; %3
y = [0, 1, 0, 1, 0]; %10
randmass = zeros(1, 31);
for i = 1:31 %послед Голда
    xlast = 0;
    ylast = 0;
    if x(1) ~= x(3)
        xlast = 1;
    end
    if y(2) ~= y(4)
        ylast = 1;
    end
    for j = 5:-1:2
        x(j) = x(j-1);
        y(j) = y(j-1);
    end
    x(1) = xlast;
    y(1) = ylast;
    vivod = 0;
    if x(5) ~= y(5)
        vivod = 1;
    end
    randmass(i) = vivod;
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
GOLD_LENGTH=length(randmass); %gold
final_massive=zeros(1, length(GOLD_LENGTH)+length(GOLD_LENGTH)+length(original_massive));
for i = 1:GOLD_LENGTH
    final_massive(i)=randmass(i);
end
for i = GOLD_LENGTH+1:GOLD_LENGTH+PACKET_LENGTH+CRC_LENGTH
    final_massive(i)=original_massive(i-GOLD_LENGTH);
end
for i = GOLD_LENGTH+PACKET_LENGTH+CRC_LENGTH+1:GOLD_LENGTH*2+PACKET_LENGTH+CRC_LENGTH
    final_massive(i)=randmass(i-GOLD_LENGTH-PACKET_LENGTH-CRC_LENGTH);
end
    subplot(4,1,2);
    plot(final_massive);
    title('Массив с информацией, CRC и последовательностями Голда')
    xlim([1, length(final_massive)]);
    ylim([-0.2, 1.2]);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Преобразуйте биты с данными во временные отсчеты сигналов,
%так чтобы на каждый бит приходилось N-отсчетов.

% Определение параметров
N = 10; % Количество отсчётов на бит
bits = final_massive; % биты
Tb = 1; % Продолжительность одного бита, c
fs = N/Tb; % Частота дискретизации
fc = fs/N; % Частота несущей

% Модуляция
t = 0:(Tb*N-1)/fs; % Временная шкала
st = zeros(1, length(bits)*N); % Инициализация массива временных отсчётов
for i = 1:length(bits)
    if bits(i) == 1
        st((i-1)*N+1:i*N) = cos(2*pi*fc*t);
    else
        st((i-1)*N+1:i*N) = 0;
    end
end

subplot(4, 1, 3);
% Визуализация
t_st = linspace(0, (length(bits)*N*Tb-1), length(st)); % Временная шкала для сигнала
plot(t_st, st);
ylim([-0.2, 1.2]);
xlim([1, length(bits)*N*Tb]);
xlabel('Время, c (1 c = 1000 samples)');
ylabel('Амплитуда');
title('Амплитудная модуляция');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Создайте нулевой массив длиной 2хNx(L+M+G). Введите с
%клавиатуры число от 0 до Nx(L+M+G) и в соответствие с введенным
%значением вставьте в него массив значений
SIGNAL_LENGTH=length(st)*2;
st2 = zeros(1, SIGNAL_LENGTH);
stuph = input('Введите число от 0 до length(st):');
for i = stuph:(stuph+length(st)-1)
    st2(i) = st(i-stuph+1);
end
t_st = linspace(0, (SIGNAL_LENGTH-1), length(st2));
subplot(4,1,4);
plot(t_st, st2);
ylim([-0.2, 1.2]);
xlim([1, SIGNAL_LENGTH]);
xlabel('Samples');
ylabel('Амплитуда');
title('Финальный сигнал');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%к ним добавились значения шумов,
%присутствовавших в канале, которые можно получить, используя нормальный
%закон распределения с μ=0 и σ – вводится с клавиатуры (float)

mu = input('Введите среднее значение шума (mu): '); % Среднее значение шума
sigma = input('Введите стандартное отклонение шума (sigma): '); % Стандартное отклонение шума
noise = normrnd(mu, sigma, 1, length(st2)); % Формирование массива с шумом

% Формирование зашумленного сигнала
noisy_signal = st2 + noise; % Поэлементное сложение информационного сигнала с шумом

% Визуализация
figure;
subplot(4,1,1);
plot(t_st, noisy_signal);
ylim([-1, 2]);
xlim([1, SIGNAL_LENGTH]);
title('Зашумленный принятый сигнал');
xlabel('Samples');
ylabel('Амплитуда');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Реализуйте функцию корреляционного приема и определите, начиная
%с какого отсчета (семпла) начинается синхросигнал в полученном
%массиве
randmass_gold = zeros(1, length(randmass)*N);
for i = 1:length(randmass)
    if randmass(i) == 1
        randmass_gold((i-1)*N+1:i*N) = 1;
    else
        randmass_gold((i-1)*N+1:i*N) = 0;
    end
end
autocorr_values = zeros(1, SIGNAL_LENGTH-length(randmass_gold));
vivodlast = zeros(1, length(randmass)*N);
k_gold_max_start=0;
k_gold_max_end=0;
for k = 1:((SIGNAL_LENGTH-length(randmass_gold))/2)
    for i = k:(k+length(randmass_gold)-1)
        if (noisy_signal(i) >= 0.7)
            vivodlast(i-k+1)=1;
        else
            vivodlast(i-k+1)=0;
        end
    end
    sumcorr = 0;
    sumuncorr = 0;
    for l = 1:length(randmass_gold)
        if randmass_gold(l) == vivodlast(l)
            sumcorr = sumcorr + 1;
        else
            sumuncorr = sumuncorr + 1;
        end
    end
    autocorr = (1/length(randmass_gold))*(sumcorr - sumuncorr);
    autocorr_values(k) = autocorr;
    if (autocorr >= 0.80)
        k_gold = autocorr;
        if (k_gold>k_gold_max_start)
            k_gold_max_start=k_gold;
            k_corr_start = k;
        end
    end
end
for k = ((SIGNAL_LENGTH-length(randmass_gold))/2):(SIGNAL_LENGTH-length(randmass_gold))
    for i = k:(k+length(randmass_gold)-1)
        if (noisy_signal(i) >= 0.7)
            vivodlast(i-k+1)=1;
        else
            vivodlast(i-k+1)=0;
        end
    end
    sumcorr = 0;
    sumuncorr = 0;
    for l = 1:length(randmass_gold)
        if randmass_gold(l) == vivodlast(l)
            sumcorr = sumcorr + 1;
        else
            sumuncorr = sumuncorr + 1;
        end
    end
    autocorr = (1/length(randmass_gold))*(sumcorr - sumuncorr);
    autocorr_values(k) = autocorr;
    if (autocorr >= 0.80)
        k_gold = autocorr;
        if (k_gold>k_gold_max_end)
            k_gold_max_end=k_gold;
            k_corr_end = k;
        end
    end
end
subplot(4, 1, 2);
shifts = 1:(SIGNAL_LENGTH-length(randmass_gold));
plot(shifts-1, autocorr_values, 'o-');
ylim([-1, 1.2]);
xlim([1, SIGNAL_LENGTH]);
title("Autocorr");
xlabel('Samples');
ylabel('Значение');
grid on;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%удалите лишние биты до этого массива, выведите значение
%в терминал
get_signal_massive = zeros(1, (k_corr_end-k_corr_start));
for i = k_corr_start+1:k_corr_end
    get_signal_massive(i-k_corr_start) = noisy_signal(i);
end
subplot(4, 1, 3);
t_st = linspace(0, ((k_corr_end-k_corr_start)*N-1)/fs, (k_corr_end-k_corr_start)); % Временная шкала для сигнала
plot(t_st, get_signal_massive);
ylim([-1, 2]);
xlim([1, length(get_signal_massive)*Tb]);
xlabel('Время, с (1 c = 1500 samples)');
ylabel('Амплитуда');
title('Принятый сигнал');
disp(k_corr_start);
disp(k_corr_end);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Зная длительность в отсчетах N каждого символа, разберите
%оставшиеся символы
get_signal_bits=zeros(1, (length(get_signal_massive)/N));
for i=1:N:length(get_signal_massive)
    sum_in_bit=0;
    for j=i:i+N-1
        sum_in_bit=sum_in_bit+get_signal_massive(j);
    end
    if (i>15)
        if ((sum_in_bit/N) >= 0.7)
            get_signal_bits(((i-1)/N)+2)=1;
        else
            get_signal_bits(((i-1)/N)+2)=0;
        end
    end
    if (i<16)
        if ((sum_in_bit/N) >= 0.7)
            get_signal_bits(i+2)=1;
        else
            get_signal_bits(i+2)=0;
        end
    end
end
subplot(4, 1, 4);
t_st = linspace(0, length(get_signal_bits)-1, length(get_signal_bits));
plot(t_st, get_signal_bits);
ylim([-0.2, 1.2]);
xlim([1, length(get_signal_bits)-1]);
xlabel('Время, с');
ylabel('Амплитуда');
title('Принятый сигнал через пороговые значения');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Удалите из полученного массива G-бит последовательности
%синхронизации.
%Проверьте корректность приема бит, посчитав CRC. Выведите в
%терминал информацию о факте наличия или отсутствия ошибки.
get_signal=zeros(1, PACKET_LENGTH+CRC_LENGTH);
get_crc=zeros(1, CRC_LENGTH);
for i=GOLD_LENGTH+1:PACKET_LENGTH+CRC_LENGTH+GOLD_LENGTH
    get_signal(i-GOLD_LENGTH)=get_signal_bits(i+1);
end
for i=PACKET_LENGTH+1:PACKET_LENGTH+CRC_LENGTH
    get_crc(i-PACKET_LENGTH)=get_signal(i);
end
fprintf('Значение CRC из полученного сигнала: ');
disp(get_crc);

% Добавление массива для вычисления
check_massive = get_signal;

% Вычисление правильности
for i = 1:PACKET_LENGTH+1
    if check_massive(i) == 1
        for j = 1:CRC_LENGTH+1
            check_massive(i+j-1) = xor(check_massive(i+j-1), generator(j));
        end
    end
end
check_correct=0;
for i=PACKET_LENGTH+1:PACKET_LENGTH+CRC_LENGTH
    check_correct=check_correct+check_massive(i);
end
if (check_correct > 0)
    fprintf("Последовательность была передана с ошибкой\n");
else
    fprintf("Последовательность передана без ошибок\n");
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Если ошибок в данных нет, то удалит биты CRC и оставшиеся
%данные подайте на ASCII-декодер, чтобы восстановить посимвольно
%текст. Выведите результат на экран
if (check_correct == 0)
    get_full_name_binary = zeros(1, PACKET_LENGTH);
    for i = 1:PACKET_LENGTH
        get_full_name_binary(i) = get_signal(i);
    end
    
    % Преобразование бинарной последовательности в числовые коды ASCII
    get_full_name_ascii = reshape(get_full_name_binary, 8, []).';
    get_full_name_ascii = bi2de(get_full_name_ascii, 'left-msb');

    % Преобразование числовых кодов в символьную строку
    get_full_name = char(get_full_name_ascii);
    disp(get_full_name)
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Визуализируйте спектр передаваемого и принимаемого
%(зашумленного) сигналов.
figure(3);
arr1 = repmat(noisy_signal, 1, 1);
arr_padded2 = padarray(arr1, [0, max(2000 - length(arr1), 0)], 0, 'post');
fft1_1 = abs(fftshift(fft(arr_padded2)));
% Построение графиков
subplot(3,1,1);
arr1 = repmat(st2, 1, 1);
x_axis = linspace(0, length(fft1_1), length(fft1_1));
arr_padded2 = padarray(arr1, [0, max(2000 - length(arr1), 0)], 0, 'post');
fft1_2 = abs(fftshift(fft(arr_padded2)));

plot(x_axis, fft1_1, x_axis, fft1_2);
title('N=10');
legend('Принимаемый (зашумленный) сигнал', 'Передаваемый сигнал', 'FontSize', 6);
ylim([-1000, 1000]);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Преобразование числовых кодов в бинарные последовательности
full_name_binary = de2bi(full_name_ascii, 8, 'left-msb'); %8 бит для каждой буквы
full_name_binary = reshape(full_name_binary.', 1, []);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Вычислите CRC длиной M бит для данной последовательности,
%используя входные данные для своего варианта из работы №5 и добавьте к
%битовой последовательности. Результат: CRC-генератор и выведенный в
%терминал CRC
original_massive = full_name_binary;
CRC_LENGTH = 7;
PACKET_LENGTH = length(full_name_binary);
generator = [1, 1, 1, 0, 1, 1, 1, 1]; % порождающий полином G для делителя: 11101111
rng('shuffle');

% Добавление нулей для вычисления CRC
for i = PACKET_LENGTH+1:PACKET_LENGTH+CRC_LENGTH
    full_name_binary(i) = 0;
end

% Вычисление CRC
for i = 1:PACKET_LENGTH
    if full_name_binary(i) == 1
        for j = 1:CRC_LENGTH+1
            full_name_binary(i+j-1) = xor(full_name_binary(i+j-1), generator(j));
        end
    end
end
for i = PACKET_LENGTH+1:PACKET_LENGTH+CRC_LENGTH
    original_massive(i)=full_name_binary(i);
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Для этого
%перед отправкой полученной последовательности добавьте
%последовательность Голда, которую вы реализовывали в работе №4, длиной
%G-бит.

x = [0, 0, 0, 1, 1]; %3
y = [0, 1, 0, 1, 0]; %10
randmass = zeros(1, 31);
for i = 1:31 %послед Голда
    xlast = 0;
    ylast = 0;
    if x(1) ~= x(3)
        xlast = 1;
    end
    if y(2) ~= y(4)
        ylast = 1;
    end
    for j = 5:-1:2
        x(j) = x(j-1);
        y(j) = y(j-1);
    end
    x(1) = xlast;
    y(1) = ylast;
    vivod = 0;
    if x(5) ~= y(5)
        vivod = 1;
    end
    randmass(i) = vivod;
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
GOLD_LENGTH=length(randmass); %gold
final_massive=zeros(1, length(GOLD_LENGTH)+length(GOLD_LENGTH)+length(original_massive));
for i = 1:GOLD_LENGTH
    final_massive(i)=randmass(i);
end
for i = GOLD_LENGTH+1:GOLD_LENGTH+PACKET_LENGTH+CRC_LENGTH
    final_massive(i)=original_massive(i-GOLD_LENGTH);
end
for i = GOLD_LENGTH+PACKET_LENGTH+CRC_LENGTH+1:GOLD_LENGTH*2+PACKET_LENGTH+CRC_LENGTH
    final_massive(i)=randmass(i-GOLD_LENGTH-PACKET_LENGTH-CRC_LENGTH);
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Преобразуйте биты с данными во временные отсчеты сигналов,
%так чтобы на каждый бит приходилось N-отсчетов.

% Определение параметров
% Определение параметров
N = 10; % Количество отсчётов на бит
bits = final_massive; % биты
Tb = 1; % Продолжительность одного бита, c
fs = N/Tb; % Частота дискретизации
fc = fs/N; % Частота несущей

% Модуляция
t = 0:(Tb*N-1)/fs; % Временная шкала
st = zeros(1, length(bits)*N); % Инициализация массива временных отсчётов
for i = 1:length(bits)
    if bits(i) == 1
        st((i-1)*N+1:i*N) = cos(2*pi*fc*t);
    else
        st((i-1)*N+1:i*N) = 0;
    end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Создайте нулевой массив длиной 2хNx(L+M+G). Введите с
%клавиатуры число от 0 до Nx(L+M+G) и в соответствие с введенным
%значением вставьте в него массив значений
SIGNAL_LENGTH=length(st)*2;
st2 = zeros(1, SIGNAL_LENGTH);
for i = stuph:(stuph+length(st)-1)
    st2(i) = st(i-stuph+1);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%к ним добавились значения шумов,
%присутствовавших в канале, которые можно получить, используя нормальный
%закон распределения с μ=0 и σ – вводится с клавиатуры (float)
noise = normrnd(mu, sigma, 1, length(st2)); % Формирование массива с шумом

% Формирование зашумленного сигнала
noisy_signal = st2 + noise; % Поэлементное сложение информационного сигнала с шумом
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
arr2 = repmat(noisy_signal, 1, 10);
arr_padded3 = padarray(arr2, [0, max(2000 - length(arr2), 0)], 0, 'post');
fft2_1 = abs(fftshift(fft(arr_padded3)));
% Построение графиков
subplot(3,1,2);
arr2 = repmat(st2, 1, 10);
arr_padded3 = padarray(arr2, [0, max(2000 - length(arr2), 0)], 0, 'post');
fft2_2 = abs(fftshift(fft(arr_padded3)));
x_axis = linspace(0, length(fft2_1)/4, length(fft2_1));
plot(x_axis, fft2_1, x_axis, fft2_2);
title('N=100');
legend('Принимаемый (зашумленный) сигнал', 'Передаваемый сигнал', 'FontSize', 6);
ylim([-1000, 10000]);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Преобразование числовых кодов в бинарные последовательности
full_name_binary = de2bi(full_name_ascii, 8, 'left-msb'); %8 бит для каждой буквы
full_name_binary = reshape(full_name_binary.', 1, []);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Вычислите CRC длиной M бит для данной последовательности,
%используя входные данные для своего варианта из работы №5 и добавьте к
%битовой последовательности. Результат: CRC-генератор и выведенный в
%терминал CRC
original_massive = full_name_binary;
CRC_LENGTH = 7;
PACKET_LENGTH = length(full_name_binary);
generator = [1, 1, 1, 0, 1, 1, 1, 1]; % порождающий полином G для делителя: 11101111
rng('shuffle');

% Добавление нулей для вычисления CRC
for i = PACKET_LENGTH+1:PACKET_LENGTH+CRC_LENGTH
    full_name_binary(i) = 0;
end

% Вычисление CRC
for i = 1:PACKET_LENGTH
    if full_name_binary(i) == 1
        for j = 1:CRC_LENGTH+1
            full_name_binary(i+j-1) = xor(full_name_binary(i+j-1), generator(j));
        end
    end
end
% Вывод полученного значения CRC
for i = PACKET_LENGTH+1:PACKET_LENGTH+CRC_LENGTH
    original_massive(i)=full_name_binary(i);
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Для этого
%перед отправкой полученной последовательности добавьте
%последовательность Голда, которую вы реализовывали в работе №4, длиной
%G-бит.

x = [0, 0, 0, 1, 1]; %3
y = [0, 1, 0, 1, 0]; %10
randmass = zeros(1, 31);
for i = 1:31 %послед Голда
    xlast = 0;
    ylast = 0;
    if x(1) ~= x(3)
        xlast = 1;
    end
    if y(2) ~= y(4)
        ylast = 1;
    end
    for j = 5:-1:2
        x(j) = x(j-1);
        y(j) = y(j-1);
    end
    x(1) = xlast;
    y(1) = ylast;
    vivod = 0;
    if x(5) ~= y(5)
        vivod = 1;
    end
    randmass(i) = vivod;
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
GOLD_LENGTH=length(randmass); %gold
final_massive=zeros(1, length(GOLD_LENGTH)+length(GOLD_LENGTH)+length(original_massive));
for i = 1:GOLD_LENGTH
    final_massive(i)=randmass(i);
end
for i = GOLD_LENGTH+1:GOLD_LENGTH+PACKET_LENGTH+CRC_LENGTH
    final_massive(i)=original_massive(i-GOLD_LENGTH);
end
for i = GOLD_LENGTH+PACKET_LENGTH+CRC_LENGTH+1:GOLD_LENGTH*2+PACKET_LENGTH+CRC_LENGTH
    final_massive(i)=randmass(i-GOLD_LENGTH-PACKET_LENGTH-CRC_LENGTH);
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Преобразуйте биты с данными во временные отсчеты сигналов,
%так чтобы на каждый бит приходилось N-отсчетов.

% Определение параметров
N = 10; % Количество отсчётов на бит
bits = final_massive; % биты
Tb = 1; % Продолжительность одного бита, c
fs = N/Tb; % Частота дискретизации
fc = fs/N; % Частота несущей

% Модуляция
t = 0:(Tb*N-1)/fs; % Временная шкала
st = zeros(1, length(bits)*N); % Инициализация массива временных отсчётов
for i = 1:length(bits)
    if bits(i) == 1
        st((i-1)*N+1:i*N) = cos(2*pi*fc*t);
    else
        st((i-1)*N+1:i*N) = 0;
    end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Создайте нулевой массив длиной 2хNx(L+M+G). Введите с
%клавиатуры число от 0 до Nx(L+M+G) и в соответствие с введенным
%значением вставьте в него массив значений
SIGNAL_LENGTH=length(st)*2;
st2 = zeros(1, SIGNAL_LENGTH);
for i = stuph:(stuph+length(st)-1)
    st2(i) = st(i-stuph+1);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%к ним добавились значения шумов,
%присутствовавших в канале, которые можно получить, используя нормальный
%закон распределения с μ=0 и σ – вводится с клавиатуры (float)

noise = normrnd(mu, sigma, 1, length(st2)); % Формирование массива с шумом

% Формирование зашумленного сигнала
noisy_signal = st2 + noise; % Поэлементное сложение информационного сигнала с шумом
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
arr3 = repmat(noisy_signal, 1, 20);
arr_padded4 = padarray(arr3, [0, max(2000 - length(arr3), 0)], 0, 'post');
fft3_1 = abs(fftshift(fft(arr_padded4)));
% Построение графиков
subplot(3,1,3);
arr3 = repmat(st2, 1, 20);
arr_padded4 = padarray(arr3, [0, max(2000 - length(arr3), 0)], 0, 'post');
fft3_2 = abs(fftshift(fft(arr_padded4)));
x_axis = linspace(0, length(fft3_1)/2, length(fft3_1));
plot(x_axis, fft3_1, x_axis, fft3_2);
title('N=200');
legend('Принимаемый (зашумленный) сигнал', 'Передаваемый сигнал', 'FontSize', 6);
ylim([-1000, 10000]);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%