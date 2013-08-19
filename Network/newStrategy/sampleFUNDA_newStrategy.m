function[vmax1, vmax3, vmax5, vmax7, dmax5, dmax7, dmax9] = sampleFUNDA_newStrategy(LINK, means, vars)

% draw t1, t2, and associates
condition = true;
while(condition)
    t1 = normrnd(means(1),sqrt(vars(1)),1,1);
    t2 = normrnd(means(2),sqrt(vars(2)),1,1);
    % draw t_1^1 & t_1^2
    t11 = t1.*rand(1,1);
    t12 = (t1-t11).*rand(1,1);
    % compute t_1^3
    t13 = t1 - t11 - t12;
    % compute t_2^3
    t23 = t13 ./ (0.2 / 0.25);
    % compute t_2^4
    t24 = t2 - t11 - t12 - t23;
    % check with restrictions
    if isempty(find(t1<t2 & t11+t12 < t1 & t11+t12+t23<t2 &sign(t1)>0 &  sign(t2)>0 &...
            sign(t11)>0 & sign(t12)>0 & sign(t13)>0 & sign(t24)>0 & sign(t23)>0,1))
        continue
    else
        t11_new = t11(t1<t2 & t11+t12 < t1 & t11+t12+t23<t2 &sign(t1)>0 &  sign(t2)>0 & sign(t11)>0 & sign(t12)>0 & sign(t13)>0 & sign(t24)>0 & sign(t23)>0);
        t12_new = t12(t1<t2 & t11+t12 < t1 & t11+t12+t23<t2 &sign(t1)>0 &  sign(t2)>0 & sign(t11)>0 & sign(t12)>0 & sign(t13)>0 & sign(t24)>0 & sign(t23)>0);
        t23_new = t23(t1<t2 & t11+t12 < t1 & t11+t12+t23<t2 &sign(t1)>0 &  sign(t2)>0 & sign(t11)>0 & sign(t12)>0 & sign(t13)>0 & sign(t24)>0 & sign(t23)>0);
        t24_new = t24(t1<t2 & t11+t12 < t1 & t11+t12+t23<t2 &sign(t1)>0 &  sign(t2)>0 & sign(t11)>0 & sign(t12)>0 & sign(t13)>0 & sign(t24)>0 & sign(t23)>0);
        % calculate vmax
        vmax1 = 0.1 ./ t11_new;
        vmax3 = 1 ./ t12_new;
        vmax5 = 0.25 ./ t23_new;
        vmax7 = 0.1 ./ t24_new;
        % check with criteria of below 100
        indices = find(vmax1<170 & vmax3<170 & vmax5<170 & vmax7<170 &...
            vmax1>40 & vmax3>40 & vmax5>40 & vmax7>40);
    end
    if isempty(indices) == 0
        condition = false;
    end
end

% draw w1, w2, and associates
condition = true;
while(condition)
    t1 = normrnd(means(3),sqrt(vars(3)),1,1);
    t2 = normrnd(means(4),sqrt(vars(4)),1,1);
    % draw t_1^7
    t17 = t1.*rand(1,1);
    % compute t_1^9
    t19 = t1 - t17;
    % compute t_2^7
    t27 = t17 ./ (0.08 / 0.18);
    % compute t_2^5
    t25 = t2 - t19 - t27;
    if isempty(find(t1<t2 & t19+t27<t2 &sign(t1)>0 &  sign(t2)>0 &...
            sign(t19)>0 & sign(t17)>0 & sign(t25)>0,1))
        continue
    else
        t19_new = t19(t1<t2 & t19+t27<t2 &sign(t1)>0 &  sign(t2)>0 &...
            sign(t19)>0 & sign(t17)>0 & sign(t25)>0);
        t17_new = t17(t1<t2 & t19+t27<t2 &sign(t1)>0 &  sign(t2)>0 &...
            sign(t19)>0 & sign(t17)>0 & sign(t25)>0);
        t27_new = t27(t1<t2 & t19+t27<t2 &sign(t1)>0 &  sign(t2)>0 &...
            sign(t19)>0 & sign(t17)>0 & sign(t25)>0);
        t25_new = t25(t1<t2 & t19+t27<t2 &sign(t1)>0 &  sign(t2)>0 &...
            sign(t19)>0 & sign(t17)>0 & sign(t25)>0);
        % calculate parameters
        w9 = 0.5 / t19_new;
        w7 = 0.18 / t27_new;
        w5 = 0.05 / t25_new;
        
        % link 9
        vmax9 = LINK(9).vmax;
        dc9 = LINK(9).dc/LINK(9).numLanes;
        dmax9 = dc9 * vmax9 / w9 + dc9;
        
        % link 7
        dc7 = LINK(7).dc/LINK(7).numLanes;
        dmax7 = dc7 * vmax7 / w7 + dc7;
        
        % link 5
        dc5 = LINK(5).dc/LINK(5).numLanes;
        dmax5 = dc5 * vmax5 / w5 + dc5;
        
        % check with criteria of below 100
        indices = find(dmax9>dc9 & dmax7>dc7 & dmax5>dc5);
    end
    
    if isempty(indices) == 0
        condition = false;
    end
end

%     vmax1 = 38.9322;
%     vmax3 = 84.2253;
%     vmax5 = 36.7274;
%     vmax7 = 96.9350;
%     dmax5 = 88767;
%     dmax7 = 691.6180;
%     dmax9 = 307.3641;






