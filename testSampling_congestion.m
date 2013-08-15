clear all
clc

means = [60 170 30; 60 170 30; 60 170 30];
vars = [25 400 25; 25 400 25; 25 400 25];

condition = 'true';
vmax5Collection = [];
vmax7Collection = [];
vmax9Collection = [];
dmax5Collection = [];
dmax7Collection = [];
dmax9Collection = [];
dc5Collection = [];
dc7Collection = [];
dc9Collection = [];

while(condition)
    t1 = 0.042748;
    t2 = 0.055794;
    % draw t_1^9
    t17 = 0.5 .* t1.*rand(1,1);
    % compute t_1^7
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
        dmax9 = normrnd(means(1,2),sqrt(vars(1,2)));
        dc9 = normrnd(means(1,3),sqrt(vars(1,3)));
        vmax9 = w9.*(dmax9-dc9)./dc9;
        
        % link 7
        dmax7 = normrnd(means(2,2),sqrt(vars(2,2)));
        dc7 = normrnd(means(2,3),sqrt(vars(2,3)));
        vmax7 = w7.*(dmax7-dc7)./dc7;
        
        % link 5
        dmax5 = normrnd(means(3,2),sqrt(vars(3,2)));
        dc5 = normrnd(means(3,3),sqrt(vars(3,3)));
        vmax5 = w9.*(dmax5-dc5)./dc5;
        
        % check with criteria of below 100
        indices = find(vmax9<170 & vmax7<170 & vmax5<170 & dmax9>dc9 & dmax7>dc7 & dmax5>dc5);
    end
    
    vmax5Collection = [vmax5Collection vmax5];
    vmax7Collection = [vmax7Collection vmax7];
    vmax9Collection = [vmax9Collection vmax9];
    dmax5Collection = [dmax5Collection dmax5];
    dmax7Collection = [dmax7Collection dmax7];
    dmax9Collection = [dmax9Collection dmax9];
    dc5Collection = [dc5Collection dc5];
    dc7Collection = [dc7Collection dc7];
    dc9Collection = [dc9Collection dc9];
    if size(vmax5Collection,1) >= 1
        keyboard
        condition = false;
    end
end