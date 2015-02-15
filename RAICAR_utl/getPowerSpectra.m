function [MX, f] = getPowerSpectra (x, Fs)
                             % sampling frequency
Fn=Fs/2;                              % Nyquist frequency
t=0:1/Fs:420-1/Fs;              % time vector sampled at Fs Hz, length of 420 second
NFFT=2.^(ceil(log(length(x))/log(2)));     % Next highest power of 2 greater than length(x).
FFTX=fft(x,NFFT);               % Take FFT, padding with zeros. length(FFTX)==NFFT
NumUniquePts = ceil((NFFT+1)/2);
FFTX=FFTX(1:NumUniquePts);            % FFT is symmetric, throw away second half
MX=abs(FFTX);                   % Take magnitude of X
MX=MX*2;                            % Multiply by 2 to take into account the fact that we threw out second half of FFTX above
MX(1)=MX(1)/2;                   % Account for endpoint uniqueness
MX(length(MX))=MX(length(MX))/2;      % We know NFFT is even
MX=MX/length(x);                      % Scale the FFT so that it is not a function of the length of x.
f=(0:NumUniquePts-1)*2*Fn/NFFT;
%plot(f,MX);
