close all; clear all; clc;

%% Menginput audio asli
[original_signal, fs] = audioread("D:\SEMESTER 5\PSD\P2_EL3010_13221020\P2_ORI_EL3010_13221020.wav");

original_signal = mean(original_signal, 2); %% mono
original_signal = 0.9*original_signal/max(abs(original_signal)); %% normalize

original_signal = resample(original_signal, 8000, fs); %% resampling to 8kHz
fs = 8000;

w = hann(floor(0.03*fs), 'periodic'); %% using 30ms Hann window

%% Mencari koefisien LPC menggunakan fungsi lpcEncode
N = 12; %% using 12th order
[A, G] = lpcEncode(original_signal, N, w);


%% Mendeteksi pitch pada audio asli
[F, ~] = lpcFindPitch(original_signal, w, 5);

%% Menghasilkan sinyal prediksi dari koefisien LPC beserta error_signal nya
[reconstructed_signal, error_signal] = lpcDecode(A, [G; F], w, 200/fs);

%% Menuliskan kembali sinyal audio yang telah direkonstruksi beserta error_signal nya
audiowrite("D:\SEMESTER 5\PSD\P2_EL3010_13221020\P2_RECON_EL3010_13221020.wav", reconstructed_signal, fs);
audiowrite("D:\SEMESTER 5\PSD\P2_EL3010_13221020\P2_ERROR_EL3010_13221020.wav", error_signal, fs);

%% Perhitungan SNR
snr_value = 10 * log10(sum(original_signal.^2) / sum((error_signal).^2));
disp(abs(snr_value));

%% Membandingkan ukuran data sebelum dan sesudah direkonstruksi
nSig = length(original_signal);
disp(['Original signal size: ' num2str(nSig)]);
sz = size(A);
nLPC = sz(1)*sz(2) + length(G) + + length(F);
disp(['Encoded signal size: ' num2str(nLPC)]);
disp(['Data reduction: ' num2str(nSig/nLPC)]);

%% Membandingkan spektrum sinyal prediksi dengan sinyal asli
subplot(2, 2, 1);
plot(1:1000,original_signal(end-1000+1:end),1:1000,reconstructed_signal(end-1000+1:end),'--')
xlabel('Sample Number')
ylabel('Amplitude')
legend('Original signal','LPC estimate')

%% Membandingkan spektrum sinyal error dengan sinyal asli
subplot(2, 2, 2);
plot(1:1000,original_signal(end-1000+1:end),1:1000,error_signal(end-1000+1:end),'--')
xlabel('Sample Number')
ylabel('Amplitude')
legend('Original signal','LPC error')

%% Memunculkan spektrum power density sinyal prediksi
[Pxx_reconstructed, F_reconstructed] = pwelch(reconstructed_signal, w, 0, [], fs);
subplot(2, 2, 3);
plot(F_reconstructed, 10*log10(Pxx_reconstructed));
title('Power Density Waveform - Reconstructed Signal');
xlabel('Frequency (Hz)');
ylabel('Power/Frequency (dB/Hz)');

%% Memunculkan spektrum power density sinyal error
[Pxx_error, F_error] = pwelch(error_signal, w, 0, [], fs);
subplot(2, 2, 4);
plot(F_error, 10*log10(Pxx_error));
title('Power Density Waveform - Error Signal');
xlabel('Frequency (Hz)');
ylabel('Power/Frequency (dB/Hz)');