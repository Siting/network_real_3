clear all
clc

condition = 'true';
vmax1Collection = [];
vmax2Collection = [];
vmax3Collection = [];
vmax4Collection = [];
while(condition)
    t1 = 0.019887;
    t2 = 0.02228;
    % draw t_1^1 & t_1^2
    t11 = 0.5.*t1.*rand(1,1);
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
        vmax2 = 1 ./ t12_new;
        vmax3 = 0.25 ./ t23_new;
        vmax4 = 0.1 ./ t24_new;
        % check with criteria of below 100
        indices = find(vmax1<170 & vmax2<170 & vmax3<170 & vmax4<170);
    end
    
    vmax1Collection = [vmax1Collection; vmax1(indices)];
    vmax2Collection = [vmax2Collection; vmax2(indices)];
    vmax3Collection = [vmax3Collection; vmax3(indices)];
    vmax4Collection = [vmax4Collection; vmax4(indices)];
    if size(vmax1Collection,1) >= 1
        keyboard
        condition = false;
    end
end