function federal_rk
%�����΢�ַ�����ʱ Ft չ��
    glb;

    tt = 0.02;               %����-��������
    Gt = w/sqrt(tt/2);       %����ֵ�ⷨ��,ϵͳ������ɢ��
    fid = fopen('e:/ygm/vehicle/trace4.bin','r');   %�򿪹켣�����ļ�
    fout = fopen('e:/ygm/vehicle/federal_rk3.bin','wb');  
    Ft2 = zeros(31,31);  ww = zeros(31,2);
    for k = 2:2:400*100
        [data, n] = fread(fid, 21+21, 'real*8');  %data [att, vn, pos, wm, vm, wb, fb] 
        %          Cnb                 vn         pos        wb           fb           vnD  posD
        Ft0 = Ft2;  
        data1 = data(1:21); data2 = data(22:42);
        ww0 = ww(:,2);  ww = randn(31,2);
        Ft1 = getf(Att2Mat(data1(1:3)), data1(4:6), data1(7:9), data1(16:18), data1(19:21), data1(4:6), data1(7:9), tao);
        Ft2 = getf(Att2Mat(data2(1:3)), data2(4:6), data2(7:9), data2(16:18), data2(19:21), data2(4:6), data2(7:9), tao);
        k1 = Ft0* x0          + Gt.*ww0;
        k2 = Ft1*(x0+tt/2*k1) + Gt.*ww(:,1);
        k3 = Ft1*(x0+tt/2*k2) + Gt.*ww(:,1);
        k4 = Ft2*(x0+    k3)  + Gt.*ww(:,2);
        x0 = x0 + tt/6*(k1+2*k2+2*k3+k4);
        if mod(k,100) == 0
            Ht = geth(data1(4:6));         zk = Ht*x0 + v.*randn(12,1); 
            % kf1
            Ft=Ft2(1:25,:); Ft(:,26:31)=[]; Zk1=zk(1:6); Ht1=Ht(1:6,:); Ht1(:,26:31)=[];
            [Xk1, Pk1] = kfilter(Ft, Xk1, Qt1, Ht1, Zk1, Rk1, Pk1, TKF, 25);
            % kf2
            Ft=Ft2; Ft(22:25,:)=[]; Ft(:,22:25)=[]; Zk2=zk(7:12); Ht2=Ht(7:12,:); Ht2(:,22:25)=[];
            [Xk2, Pk2] = kfilter(Ft, Xk2, Qt2, Ht2, Zk2, Rk2, Pk2, TKF, 27);
            
            fwrite(fout, [x0;zk;Xk1;Xk2], 'real*8');

            if mod(k,10*100) == 0
              step=k/100,    %���ȡ�ʱ����ʾ
            end
        end 
    end   
fclose(fid);
fclose(fout);

