function m = Rv2Mat(rv)  
%��תʸ��ת��Ϊ�任����
    m = [1, 0, 0; 0, 1, 0; 0, 0, 1] - Asym(rv);
