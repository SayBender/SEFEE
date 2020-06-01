function [params] = accuracy(Y, Yp, v )
%accuracy summarizes the prediction performance in terms of precision,
%recall and F1-measure
%   Detailed explanation goes here

if nargin < 3
    v = 1; %verbose
end

p0 = 0; p1 = 0; h=0; m=0; pex = 0; 

switch ndims (Y)
    case 3
        for i=1:size(Y,1)
            for j=1:size(Y,2)
                for k=1:size(Y,3)
                    if(Y(i,j,k)>0 && Y(i,j,k)==Yp(i,j,k))
                        pex = pex + 1;
                    end
                    if(Y(i,j,k) == 0 && Yp(i,j,k) == 0)
                        p0 = p0 +1;
                        h= h +1;
                    else
                        if(Y(i,j,k)>0 && Yp(i,j,k)>0)
                            p1 = p1 + 1;
                            h = h +1;
                        else 
                            m = m + 1;
                        end
                    end
                end
            end
        end

    case 2
        for i=1:size(Y,1)
            for j=1:size(Y,2)
                if(Y(i,j)>0 && Y(i,j)==Yp(i,j))
                        pex = pex + 1;
                end
                if(Y(i,j) == 0 && Yp(i,j) == 0)
                    p0 = p0 +1;
                    h= h + 1;
                else
                    if(Y(i,j)>0 && Yp(i,j)>0)
                        p1 = p1 + 1;
                        h = h + 1;
                    else 
                        m = m + 1;
                    end
                end
            end
        end
    case 1
        for i=1:size(Y,1)
            if(Y(i)>0 && Y(i) == Yp(i))
                pex = pex + 1;
            end
            if(Y(i) == 0 && Yp(i) == 0)
                p0 = p0 + 1;
                h = h + 1;
            else
                if(Y(i)>0 && Yp(i)>0)
                    p1 = p1 + 1;
                    h = h + 1;
                else
                    m = m +1;
                end
            end
        end
        
end % end switch case statement

zg = numel(Y) - nnz(Y);
miss = m / (numel(Y));
hitr = h / (numel(Y));
ph = p1 / nnz(Y);
pn = p0 / zg;
precision =  p1/(p1+zg-p0);
pexact = pex / nnz(Y);

params = struct('hitr',hitr,'posacc',ph,'negacc',pn,'exact',pexact,'falsa',(zg-p0)/zg,'groundz',zg,'pz',p0);

% defaults to verbose v = 1.
if v
    fprintf('%d hits out of total %d comparison: %d Missed \n',h,numel(Y),m);

    fprintf('# number of Positive ground truth values: %d\n',nnz(Y));
    fprintf('# number of true positive predictions: %d\n', p1);
    fprintf(' %d true negative values were predicted out of %d zero ground truth values\n',p0,zg);
    fprintf('# False Alarms: %d --- False Alarm Rate= %.4f\n', zg-p0, (zg-p0)/zg); 
    fprintf('True Positive Detection Accuracy = %.4f \n' ,ph);
    fprintf('True Negative Detection Accuracy = %.4f \n' ,pn);
    fprintf('Exact Match positive Accuracy = %.4f \n' ,pexact);
    fprintf('Accuracy [Hit Ratio] = %.4f \n' ,hitr);
    fprintf('Precision = %.4f \n' ,precision);
    fprintf('Recall = %.4f \n' ,ph);
    fprintf('Fmeasure = %.4f \n' ,2*(precision*ph)/(precision + ph));
end


end

