function [m,s] = acfhelper(D,lag)
%ACFHELPER Summary of this function goes here
%   Finds the autocorrelation per error type (row) per node (column) and
%   stores it in 2 matrices. One matrix includes error types and nodes and
%   the autocorrelation values and the other the lag/step associated with the highest acf value
%   to capture time-of-day effect
b = size(D,2);
a = size(D,1);
s = zeros(b,a);
m = zeros(b,a);


for i=1:size(D,2)
    temp = D(:,i,:);
    temp = permute(temp,[1 3 2]);
    for j=1:size(temp,1)
       yt = temp(j,:);
       if(nnz(yt)>0)
           yt = transpose(yt);
           myacf = acf(yt,lag);
           mx = max(myacf);
           mi = find(myacf==mx);
           m(i,j) = round(mx,3);
           if isempty(mi)
               s(i,j) = 0;
           else
               if mx> 0.04
               s(i,j) = mi(1);
               else
                   s(i,j) = 0;
               end
           end
       else
           m(i,j) = 0;
           s(i,j) = 0;
       end
    end
    
    
    
end


end
