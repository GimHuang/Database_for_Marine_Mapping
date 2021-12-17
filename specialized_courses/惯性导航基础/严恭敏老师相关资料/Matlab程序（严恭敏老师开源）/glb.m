global Re e wie g0 ppm ug deg min sec hur dph PKG PKA  %ȫ�ֱ���
Re = 6378160;               %����뾶
e = 1/298.3;                %��Բ��
wie = 7.2921151467e-5;      %��ת������
g0 = 9.7803267714;          %�������ٶ�
ppm = 1.0e-6;               %�����֮һ
ug = 1.0e-6*g0;             %���������ٶ�
deg = pi/180;               %�Ƕ�
min = deg/60;               %�Ƿ�
sec = min/60;               %����
hur = 3600;                 %Сʱ
dph = deg/hur;              %��ÿСʱ
PKG = 0.932*sec;            %�������嵱��
PKA = 1/2500*g0;            %���ٶȼ����嵱��

%����ɷ���̲���
%����Ư�ƣ�          eb_=-1/tao(1:3)*eb+web;       
%����ǿ̶�ϵ����dKD_=-1/tao(4)+wdKD;
%GPS��         �ٶȣ�dvnS_=-1/tao(5:7)*dvnS+wdvnS;
%              λ�ã�dposS_=-1/tao(8:10)*dposS+wdposS; 
tao = [3600; 3600; 3600;   10e4;   5; 5; 5; 10; 10; 10];
Rv = [(0.03*dph)^2; (0.03*dph)^2; (0.03*dph)^2;  0.0001^2;  0.1^2; 0.1^2; 0.1^2; (20/Re)^2; (20/Re)^2; 50^2];
%�����㷨������ǡ�GPS��������
Tm = 0.02; TD = 0.1; TS = 1;
%����ɷ������ɢ����
e_tao = exp([-1./tao(1:3)*Tm; -1./tao(4)*TD; -1./tao(5:10)*TS]);
sqw = sqrt( Rv.*(ones(10,1)-exp(-2*[1./tao(1:3)*Tm; 1./tao(4)*TD; 1./tao(5:10)*TS])) );
%ϵͳ״̬��ֵ����
fi = [.3 ; .3; 3]*min;     dvn = [0.01; 0.01; 0.01];           dpos = [20/Re; 20/Re; 10];	
dKG = [50; 49; 48]*ppm;    eb = [0.01; 0.01; 0.01]*dph;  
dKA = [100; 90; 80]*ppm;	db = [100; 90; 80]*ug;
dposD = [20/Re; 20/Re; 10];	dKD = 0.001;        
dvnS = [0.01; 0.01; 0.01];     dposS = [20/Re; 20/Re; 50];	
x0 = [fi; dvn; dpos; dKG; eb; dKA; db; dposD; dKD; dvnS; dposS];
%ϵͳ���̰�����������
wfi = [.01; 0.01; 0.01]*min; wdvn = [0.001; 0.001; 0.001];    wdpos = [1/Re; 1/Re; 1];
wdKG = [0; 0; 0];            web = sqrt( 2*Rv(1:3).*(1./tao(1:3)) );
wdKA = [0; 0; 0];            wdb = [0; 0; 0];
wdposD = [1/Re; 1/Re; 1];    wdKD = sqrt(2*Rv(4)*1/tao(4));
wdvnS = sqrt( 2*Rv(5:7).*(1./tao(5:7)) );    wdposS = sqrt( 2*Rv(8:10).*(1./tao(8:10)) );
w = [wfi; wdvn; wdpos; wdKG; web; wdKA; wdb; wdposD; wdKD; wdvnS; wdposS];
%�۲ⷽ�̰�����������
v = [0.01; 0.01; 0.01; 9/Re; 9/Re; 1;     0.01; 0.01; 0.01; 9/Re; 9/Re; 1];
%�������˲�ʱ��
TKF = 1;     
% KF1:  X1_=Ft1*X1+w1        E(w1)=0, Cov(w1)=Qt1
%       Z1 =Ht1*X1+v1        E(v1)=0, Cov(v1)=Rk1
w1=w(1:25); v1=v(1:6); x10=x0(1:25);
Qt1=diag(w1.^2);     Rk1=diag(v1.^2);    Pk1=diag(x10.^2);    Xk1=zeros(25,1);
% KF2:  X2_=Ft2*X2+w2        E(w2)=0, Cov(w2)=Qt2
%       Z2 =Ht2*X2+v2        E(v2)=0, Cov(v2)=Rk2
w2=[w(1:21);w(26:31)]; v2=v(7:12); x20=[x0(1:21);x0(26:31)];
Qt2=diag(w2.^2);     Rk2=diag(v2.^2);    Pk2=diag(x20.^2);    Xk2=zeros(27,1);
%��װ���
dG = [0, 0, 0; 0, 0, 0; 0, 0, 0]*ppm;    dA = [0, 0, 0; 0, 0, 0; 0, 0, 0]*ppm;
KG = diag(ones(3,1)+dKG)+dG; KA = diag(ones(3,1)+dKA)+dA;

