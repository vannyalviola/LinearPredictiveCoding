% Tugas Proyek #2 EL3010 Pengolahan Sinyal Digital : Linear Predictive Coding
% Nama			: Vanny Alviolani Indriyani
% NIM			: 13221020
% Kelas			: K02
% Nama file		: P2_B_EL3010_13221020.m
% Deskripsi		: Proses sintesis (penggunaan koefisien LPC untuk menghasilkan sinyal asli)
%                 Kode ini didapat dari websitr stanford.edu dengan url berikut https://ccrma.stanford.edu/~hskim08/lpc/
% 
% Decodes the LPC coefficients into
%
% A - the LPC filter coefficients
% GFE - the signal power(G) or the signal power with fundamental frequency(GF) 
%       or the full source signal(E) of each windowed segment.
% w - the window function
% lowcut - the cutoff frequency in normalized frequencies for a lowcut
%          filter.
%
function [xhat, error] = lpcDecode(A, GFE, w, lowcut)

    if nargin < 4,
        lowcut = 0;
    end
    
    [ne, n] = size(GFE);
    nw = length(w);
    
    % synthesize estimates for each chunk
    Xhat = zeros(nw, n);
    error = zeros(n,1);
    
    if ne < 2, % GFE is only the signal power
        
        for i = 1:n,
            src = randn(nw, 1); % noise
            Xhat(:,i) = w .* filter( 1, [-1; A(:,i)], sqrt(GFE(i))*src);
            error((i-1)*nw+1:(nw*i)) = src;
        end
        
        % render down to signal
        xhat = pressStack(Xhat);
        
    elseif ne < 3, % GFE is the pitch fequency and signal power
        F = GFE(2,:); % pitch frequency
        G = GFE(1,:); % power
        offset = 0;
        
        nw2 = round(nw/2);
        xhat = zeros(nw2*n, 1);
        
        for i = 1:n,
            
            % create source
            if F(i) > 0, % pitched
                src = zeros(nw2,1);
                
                step = round(1/F(i));
                pts = (offset+1):step:nw2;
                
                if ~isempty(pts),
                    offset = step + pts(end) - nw2;
                    src(pts) = sqrt(step); % impulse train, compensate power
                end
                
            else
                src = randn(nw2, 1); % noise
                offset = 0;
            end
            
            % filter
            xhat( nw2*i + (1:nw2) ) = filter( 1, [-1; A(:,i)], sqrt(G(i))*src);
            error((i-1)*nw2+1:(nw2*i)) = src;
    
        end
        
    else % GFE is the error signal
        for i = 1:n,
            Xhat(:,i) = w .* filter( 1, [-1; A(:,i)], GFE(:,i));
        end
    
        % render down to signal
        xhat = pressStack(Xhat);
    end
        
    % dc blocker hack
    if lowcut > 0,
        [b,a] = butter(10, lowcut, 'high'); 
        xhat = filter(b,a,xhat);
    end    
    
    