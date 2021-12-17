function federal
    glb;
    % �����㷨����
    Tm  = 0.02;    
    fid = fopen('e:/ygm/vehicle/trace4.bin','r');   %�򿪹켣�����ļ�,�����ݽ��г�ʼ��
    [data, n] = fread(fid, 21, 'real*8');  %data [att, vn, pos, wm, vm, wb, fb] 
    qnb = Att2Quat(data(1:3));    vnm = data(4:6);    posm = data(7:9);
    qnb = QuatMul(Rv2Quat(-fi),qnb);  vnm = vnm + dvn;  posm = posm + dpos;  %��ʼ���
    % ������㷨����
    TD = 0.1;
    vnD = data(4:6); posD = data(7:9);   
    dvnD = [0; 0; 0];
    vnD = vnD + dvnD; posD = posD + dposD;    %��ʼ���
    % GPS����
    TS = 1.0;
    % ����ɷ������ɢ����
    e_tao = exp([-1./tao(1:3)*Tm; -1./tao(4)*TD; -1./tao(5:10)*TS]);
    sqw = sqrt( Rv.*(ones(10,1)-exp(-2*[1./tao(1:3)*Tm; 1./tao(4)*TD; 1./tao(5:10)*TS])) );
    
    fout = fopen('e:/ygm/vehicle/kf4.bin','wb');
    wvm2 = data(10:15);
    for k=2:2:990*100  
        %������,��ý�������������
        [data, n] = fread(fid, 21+21, 'real*8');  
        wvm0 = wvm2; wvm1 = data(10:15); wvm2 = data((21+10):(21+15));
        dwvm1 = wvm1-wvm0; dwvm2 = wvm2-wvm1;
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 1�ߵ�����
        ns = randn(3,2);
        eb = e_tao(1:3).* eb  + sqw(1:3).*ns(:,1);
        dwvm1 = [KG*dwvm1(1:3); KA*dwvm1(4:6)] + [eb; db]*Tm/2;
        eb = e_tao(1:3).* eb  + sqw(1:3).*ns(:,2);
        dwvm2 = [KG*dwvm1(1:3); KA*dwvm1(4:6)] + [eb; db]*Tm/2;        %�̶�ϵ����Ư��
        [qnb, vnm, posm] = sins(qnb, vnm, posm, dwvm1, dwvm2, Tm);
        if mod(k, 10)==0
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 2����Ǹ���       
            dKD = e_tao(4)*dKD + sqw(4)*randn(1,1);
            ddd = dKD+0.05;
            vD = (1+ddd) * sqrt(sum(data(4:6).^2));
%            dKD = e_tao(4)*dKD + sqw(4)*randn(1,1);
%            vD = (1+dKD) * sqrt(sum(data(4:6).^2));
            Cnb = Quat2Mat(qnb);
            vnD = Cnb * [0; vD; 0];
            sl = sin(posD(1)); cl = cos(posD(1)); 
            RM = Re*(1-2*e+3*e*sl^2); RN = Re*(1+e*sl^2); RMhD = RM + posD(3); RNhD = RN + posD(3);
            posD = posD + TD*[vnD(2)/RMhD; vnD(1)/(RNhD*cl); vnD(3)];
            if mod(k,100)==0      
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 3GPS����  
                dvpS = e_tao(5:10).*[dvnS;dposS] + sqw(5:10).*randn(6,1);
                vnS = data(4:6) + dvpS(1:3);      posS = data(7:9) + dvpS(4:6);
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 4�������˲�
                Ft = getf(Cnb, vnm, posm, data(16:18)+eb, data(19:21)+db, vnD, posD, tao);
                Ht = geth(vnD);
                % kf1
                Ft1=Ft(1:25,:); Ft1(:,26:31)=[]; Ht1=Ht(1:6,:); Ht1(:,26:31)=[];
                Zk1=[vnm-vnD; posm-posD];
                [Xk1, Pk1] = kfilter(Ft1, Xk1, Qt1, Ht1, Zk1, Rk1, Pk1, TKF, 25);
                % kf2
                Ft2=Ft; Ft2(22:25,:)=[]; Ft2(:,22:25)=[]; Ht2=Ht(7:12,:); Ht2(:,22:25)=[];
                Zk2=[vnm-vnS; posm-posS];
                [Xk2, Pk2] = kfilter(Ft2, Xk2, Qt2, Ht2, Zk2, Rk2, Pk2, TKF, 27);
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 5�����˲�
                %P11_1=Pk1(1:21,1:21)^-1;
                %P22_1=Pk2(1:21,1:21)^-1;
                %Pg=(P11_1+P22_1)^-1;
                %xg=Pg*(P11_1*Xk1(1:21,1)+P22_1*Xk2(1:21,1));
                %%%%%  fi    dvn   dpos   dKG   eb    dKA   db  22  dposD dKD  26  dvnS  dposS
                E = Quat2Mat(qnb)*Att2Mat(data(1:3))'; fi = -[-E(2,3);E(1,3);-E(1,2)];
                x = [fi; vnm-data(4:6); posm-data(7:9); dKG; eb; dKA; db; posD-data(7:9); dKD; dvpS];
                fwrite(fout, [x; Zk1; Zk2; Xk1; Xk2], 'real*8');
                if mod(k,1000) == 0
                    step=k/1000,    %���ȡ�ʱ����ʾ
                end
            end %end 1000
        end  %end 100
    end   %end for
fclose(fid);
fclose(fout);
