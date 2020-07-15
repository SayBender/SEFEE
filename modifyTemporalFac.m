function [ g ] = modifyTemporalFac( C,TW, e)
%computeTemporalFac recieves temporal factor C and computes modified factor g
%   
v = 0;

if nargin == 1
    TW = 3;
    e=1;
else
    if nargin == 2
        e = 1;
    end
end


sz = size(C);
if v
fprintf('Calculating the modified C, with temporal factor matrix C [Dimension: %d X %d], jumping TW= %d times with effect size e = %d \n', sz, TW, e);
end

T = sz(1);
R= sz(2);
SS=0;
S=0;

u = T+1-e*TW;
while u <= 0
    if v
    fprintf('e * TW = %d exceeds matrix C dimension, fixing number of steps TW  \n',e*TW); %check for overshoot
    end
    %fprintf('Number of steps(TW) selected exceeds Factor matrix C dimension, fixing TW to the highest possible value \n');
    TW = TW-1;
    u = T-1 - e*TW;
end

if v
fprintf('T= %d, TW = %d, effect= %d , last step is at u = %d  \n', T,TW,e,u);
end
%for t=T+1-e:-e:T+1-e*T0
for t=T+1-e:-e:u
    if v
    fprintf("Calculating g: C(%d) \n",t);
    end
    SS = C(t,:);
    S = SS + S;
end
g= 1/TW * S;

end

