function [T] = htodOuterProduct(Tdec,s)
%htodOuterProduct computes the outer product of factor matrices differently
%from regular outer product (outp) by using time-of-day matrix s.
A = Tdec{1}; B=Tdec{2}; C=Tdec{3}; lambda = Tdec.lambda;
sz = size(Tdec);
fprintf(">> Heterogeneous time-of-day effect is ON! \n");

for i=1:sz(1)
    for j=1:sz(2)
        if(s(i,j) == 0) %if acf had returned 0 for a particular autocorrelation value, 12 which is the default is used
                        % 12 is heuristic working very good in our context
                        % of 2 hour time-bins (12 would be 1 day), change
                        % this for your scenario.
            e = 12;
        else
            e = s(i,j); %use the non-negative tod value found by acf.
        end
        g = modifyTemporalFac(C,3,e); % we set TW= 3 by default.
        %fprintf("i= %d | j= %d \n",i,j);
        T(i,j) = outp(A(i,:),B(j,:),g,lambda);
    end
end



end

