

% Author : Abolfazl Jalali Shahrood
% ------This module finds the break-up date on the given annual daily
% ------hydrographs. The range of years can be unlimited but the "leap year
% ------correction" must be applied to the dataset, so that 29 Feb of the
% ------leap years must be removed from the data.
clc;
clear all;
clearvars;

stations=["sheetname"]; % Gets the sheetname of an "xlsx" file, or a list of different sheets.

jjj=1;
kk=0;
for jj=1:size(stations,2)
    clearvars -except jj jjj stations kk
    filename = 'AddressToTheDailyDischargeFile.xlsx'; % address to the xlsx file containing the columns of date (
    % -------------------------------------------------in excel serial format, and discharge value)

    [NUM,TXT,RAW] = xlsread(filename,stations{jj});
    tot_per= size(NUM,1)/365; %total periods in one station is calculated
    intervals=[1];
    k=1;
    for jjj=1:tot_per
        clear seq L_values seq_modified2 seq_modified seq_temp seq_temp2
        A(:,1) = NUM(k:jjj*365,1);
        A(:,2) = NUM(k:jjj*365,2);
        med = median(A(:,2));

%       -------------  Based on Slope-------------------------
        for i=1:364
            sig(i,1) = (A(i+1,2)-A(i,2))/1; %this is the slope of curve 1 day interval
        end
        
        B = find(sig(:,1)<=10 & sig(:,1)>=-10); %this finds the almost zero values on a given condition 
        % ----------------------------------------- try (-2,+2) and
        %--------------------------------------------increase it if you're unhappy with results
        for i2=1:size(B,1)-1
            B(i2,2)=B(i2+1,1)-B(i2,1); % this loops through the B variable to find the continuity
        end
        % consecutive events to find those are in order
        consenums = find(B(:,2)==1); % this finds the continuity of 1 values
        
        
        consenums2=consenums; 
        % create an array to find the most continuos numbers
        consenums=consenums' ;  %  array of consecutive numbers
        consenums(end+1)=2 ;  % adds new endpoint to very end of A so code picks up end of last group of consecutive values
        I_1=find(diff(consenums)~=1);  % finds where sequences of consecutive numbers end
        [m,n]=size(I_1);   % finds dimensions of I_1 i.e. how many sequences of consecutive numbers you have
        startpoint=1;    % sets start index at the first value in your array
        seq=cell(1,n) ; % had to preallocate because without, it only saves last iteration of the for loop below
                           % used n because this array is a row vector
        for i=1:n
            End_Idx=I_1(i);   %set end index
            seq{i}=consenums(startpoint:End_Idx);  %finds sequences of consecutive numbers and assigns to cell array
            startpoint=End_Idx+1;   %update start index for the next consecutive sequence
        end
        
         [row,col]=size(seq);
         seq_modified2=seq;
     
        for i2=1:col
            L_values(1,i2) = length(seq_modified2{i2});
        end 
         duration = max(L_values);
         [max_dis_value,max_ind]=max(A(:,2));
       
        for i3=1:col
            if length(seq_modified2{i3})==duration
                ind=i3;
                Ice_begin_1 = A(B(min(seq_modified2{ind}),1),1);
                Ice_end_1 = A(B(max(seq_modified2{ind}),1),1);
                  
                Ice_begin_1_for_plot = B(min(seq_modified2{ind}),1);
                temp_var= find(A(:,1)==Ice_end_1);
                Ice_end_1_for_plot = temp_var;
            end
        end
       
        
                        

        
        %getting the starting and ending point of the IIP(Ice
        %influence period)
        IIP_stdy(jjj,1)=Ice_begin_1;
        IIP_stdy(jjj,2)=Ice_end_1;

        start_freezing=datestr(x2mdate((Ice_begin_1)));
        stop_freezing=datestr(x2mdate((Ice_end_1)));
        start_freezing=cellstr(start_freezing);
        stop_freezing=cellstr(stop_freezing);
        IIP_stdate(jjj,1)=start_freezing;
        IIP_stdate(jjj,2)=stop_freezing;
       
        
        
        

            [M,I] = max(A(Ice_end_1_for_plot+1:365,2));
             if isempty(M)==1
                M=-999;
                I=1000;
            end
            I_ind=I+Ice_end_1_for_plot;
            Max_dis(jjj,2)=M;
            Max_dis(jjj,1)=I_ind;
            Max_dis(jjj,3)=I_ind-Ice_end_1_for_plot;

        k=k+365;



        plot(A(:,1),A(:,2),'-k');
        hold 'on'
%         plot(A(B(consenums2,1),1),A(B(consenums2,1),2),'.k');
        plot(A(Ice_end_1_for_plot,1),A(Ice_end_1_for_plot,2),'r*');
%         hold 'on'
%         yline(med)
        datetick('x','mmm','keepticks')

        xlabel('Time')
        ylabel('discharge (m^3/s)')
        title(char(stations{jj}) +" "+num2str(year(datestr(x2mdate(A(1,1)))))+"-"+num2str(year(datestr(x2mdate(A(365,1))))));
        filename2=[char(stations{jj}),'_',num2str(year(datestr(x2mdate(A(1,1)))))];
        saveas(gcf,filename2,'jpg')
        close
    end
    % ---- output directory addresss goes here --------
    init_addr ='C:/dir/dir/dir/';
    subfolder = char(stations(jj));
    mkdir(['C:/dir/dir/dir/',subfolder]);
    addr= fullfile(init_addr,subfolder);
    xlswrite(fullfile(char(addr),'startstopdate.xlsx'),IIP_stdate)
    xlswrite(fullfile(char(addr),'day.xlsx'),IIP_stdy)
    xlswrite(fullfile(char(addr),'maxdis.xlsx'),Max_dis)

end