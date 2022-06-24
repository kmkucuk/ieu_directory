

del_ss_A_3_5=[]; del_mv_A_3_5=[];

for i=1:16;
    css_0=del_ss_A_3(:,i);
    css_1=del_ss_A_5(:,i);
    cmv_0=del_mv_A_3(:,i);
    cmv_1=del_mv_A_5(:,i);
    
    del_ss_A_3_5=[del_ss_A_3_5,css_0,css_1];
    del_mv_A_3_5=[del_mv_A_3_5,cmv_0,cmv_1];
end

clear i del_mv_A_3 del_mv_A_5 del_mv_A_3 del_mv_A_5 cmv_0 cmv_1...
      css_0  css_1 del_ss_A_3 del_ss_A_5 del_ss_A_3 del_ss_A_5