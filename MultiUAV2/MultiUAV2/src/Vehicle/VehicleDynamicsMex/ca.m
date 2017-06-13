% Control Allocation Comparison
%plotting deflections and commanded deflections

load CntrlAllocCmpr.save.mat;
load CntrlAllocCmprLP.save.mat;

%time = CntrlAllocCmpr_save(:,1);
time = compare(:,1);

d1pseudo = compare(:,2);
d1pseudoCmd = compare(:,3);
d2pseudo = compare(:,4);
d2pseudoCmd = compare(:,5);
d3pseudo = compare(:,6);
d3pseudoCmd = compare(:,7);
Ppseudo = compare(:,8);
Qpseudo = compare(:,9);
Rpseudo = compare(:,10);
PpseudoCmd = compare(:,11);
QpseudoCmd = compare(:,12);
RpseudoCmd = compare(:,13);

d1LP = compareLP(:,2);
d1LPCmd = compareLP(:,3);
d2LP = compareLP(:,4);
d2LPCmd = compareLP(:,5);
d3LP = compareLP(:,6);
d3LPCmd = compareLP(:,7);
PLP = compareLP(:,8);
QLP = compareLP(:,9);
RLP = compareLP(:,10);
PLPCmd = compareLP(:,11);
QLPCmd = compareLP(:,12);
RLPCmd = compareLP(:,13);

d1low1 = min(d1pseudo);d1low2 = min(d1LP);d1low3 = min(d1LPCmd);low_all1 = [d1low1 d1low2 d1low3];
d1high1 = max(d1pseudo);d1high2 = max(d1LP);d1high3 = max(d1LPCmd);high_all1 = [d1high1 d1high2 d1high3];
lowBound1 = min(low_all1);highBound1 = max(high_all1);
d2low1 = min(d2pseudo);d2low2 = min(d2LP);d2low3 = min(d2LPCmd);low_all2 = [d2low1 d2low2 d2low3];
d2high1 = max(d2pseudo);d2high2 = max(d2LP);d2high3 = max(d2LPCmd);high_all2 = [d2high1 d2high2 d2high3];
lowBound2 = min(low_all2);highBound2 = max(high_all2);
d3low1 = min(d3pseudo);d3low2 = min(d3LP);d3low3 = min(d3LPCmd);low_all3 = [d3low1 d3low2 d3low3];
d3high1 = max(d3pseudo);d3high2 = max(d3LP);d3high3 = max(d3LPCmd);high_all3 = [d3high1 d3high2 d3high3];
lowBound3 = min(low_all3);highBound3 = max(high_all3);

figure(1)
clf;
subplot(3,1,1);
plot(time,d1pseudo,'r-',time,d1pseudoCmd,'m--',time,d1LP,'b--',time,d1LPCmd,'k-');
axis([0 max(time) lowBound1-0.5 highBound1+0.5]);
grid;
title('-> Surface 1 Comparison (in degrees)')
legend('Pseudo Deflec','Pseudo Command','LP Deflec','LP Command',-1);

subplot(3,1,2);
plot(time,d2pseudo,'r-',time,d2pseudoCmd,'m--',time,d2LP,'b--',time,d2LPCmd,'k-');
axis([0 max(time) lowBound2-0.5 highBound2+0.5]);
grid;
title('-> Surface 2 Comparison (in degrees)')
legend('Pseudo Deflec','Pseudo Command','LP Deflec','LP Command',-1);

subplot(3,1,3);
plot(time,d3pseudo,'r-',time,d3pseudoCmd,'m--',time,d3LP,'b--',time,d3LPCmd,'k-');
axis([0 max(time) lowBound3-0.5 highBound3+0.5]);
grid;
title('-> Surface 3 Comparison (in degrees)')
legend('Pseudo Deflec','Pseudo Command','LP Deflec','LP Command',-1);

figure(2)
clf;
subplot(3,1,1);
plot(time,Ppseudo,'m-',time,PpseudoCmd,'r:',time,PLP,'b-',time,PLPCmd,'k-.');
grid;
title('-> Roll Comparison (in rad/sec)')
legend('Pseudo Rate','Pseudo Command','LP Rate','LP Command',-1);

subplot(3,1,2);
plot(time,Qpseudo,'m-',time,QpseudoCmd,'r:',time,QLP,'b-',time,QLPCmd,'k-.');
grid;
title('-> Pitch Comparison (in rad/sec)')
legend('Pseudo Rate','Pseudo Command','LP Rate','LP Command',-1);

subplot(3,1,3);
plot(time,Rpseudo,'m-',time,RpseudoCmd,'r:',time,RLP,'b-',time,RLPCmd,'k-.');
grid;
title('-> Yaw Comparison (in rad/sec)')
legend('Pseudo Rate','Pseudo Command','LP Rate','LP Command',-1);

clear all;

