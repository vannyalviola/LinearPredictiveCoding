% Tugas Proyek #2 EL3010 Pengolahan Sinyal Digital : Linear Predictive Coding
% Nama			: Vanny Alviolani Indriyani
% NIM			: 13221020
% Kelas			: K02
% Nama file		: P2_B_EL3010_13221020.m
% Deskripsi		: Proses sintesis (penggunaan koefisien LPC untuk menghasilkan sinyal asli)
%                 Kode ini didapat dari websitr stanford.edu dengan url berikut https://ccrma.stanford.edu/~hskim08/lpc/
% 
% Encodes the input signal into lpc coefficients using 50% OLA
%
% x - single channel input signal
% p - lpc order
% nw - window length
% 
% A - the coefficients
% G - the signal power
% E - the full source (error) signal
%
function [A, G, E] = lpcEncode(x, p, w)

X = stackOLA(x, w); % stack the windowed signals
[nw, n] = size(X);

% LPC encode
A = zeros(p, n);
G = zeros(1, n);
E = zeros(nw, n);
for i = 1:n,
    [a, g, e] = myLPC(X(:,i), p);
    
    A(:, i) = a;
    G(i) = g;
    E(2:nw, i) = e;
end