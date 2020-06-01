function [T]=outp(M1,M2,M3,l)
% regular outerproduct
% P = cp_als(M,2);


% load kten_test2
% load spten_test3
lambda=l;

a=M1;
b=M2;
c=M3;
R=size(M1,2);


for k=1:size(M1,1)
    for j=1:size(M2,1)
        for i=1:size(M3,1)
            SS=0;
            S=0;
            for r=1:R
                SS=lambda(r)*a(k,r)*b(j,r)*c(i,r);
                S=SS+S;
            end
            T(k,j,i)=S;
        end
    end
end
end
