function []=CAN()
%All parameters in milli seconds
%Assumption is that all deadlines are less or equal to their period
%Jitter is excluded
%create classes
ID = [1;2;3;4];
P = [20;20;10;10];
D = [10;10;10;10];
C = [1;0.5;1;0.5;];
U = [5;2.5;10;5];
msg = table(ID,P,D,C,U);
disp(msg)
T_bit = 0.01;
%m_bitrate = 100kbit/s
msg_arr = table2array(msg);
%init parameters
util=0;
request=zeros;
accept=zeros;
iter=40;
total_num_of_acc=zeros(1,iter);
num_of_acc=zeros(1,iter);
m_max=1;
utils=zeros(1,iter);
n=1;
for m=1:m_max
    for i=1:iter
        %Generate a random number
        notAcc=0;
        rng shuffle
        random = rand;
        %random=0.3;
        %Choose wich message that will be transmitted
        if(random >= 0 && random < 0.25)
            req_msg = msg_arr(1,:);
        end
        if(random >= 0.25 && random < 0.5)
            req_msg = msg_arr(2,:);
        end
        if(random >= 0.5 && random < 0.75)
            req_msg = msg_arr(3,:);
        end
        if(random >= 0.75 && random <= 1)
            req_msg = msg_arr(4,:);
        end
        %Add all requested messages in an 2-d array
        request(1,i)=i;
        request(2,i)=req_msg(1,1);
        %disp("Request")
        %disp(request)
        %disp("accept")
        %disp(accept)
        %Check that the sum of utilities is less than 100
        %disp(util)
        utils(i)=util;
        if(util + req_msg(1,5) < 100)
            if accept ==0
                tempAcc = req_msg(1,1);
            else
                tempAcc = [accept,req_msg(1,1)];
            end
            disp("TempAccept")
            disp(tempAcc)
            %disp("temp Accept")
            %disp(tempAcc)
            %get the message with lowest priority
            last = tempAcc(end);
            %Bm = max(C)->lp
            if(size(tempAcc)==1)
                B = 0;
            else
                B = msg_arr(last,4);
            end
            disp("B")
            disp(B)
            Pm=(1:length(tempAcc));
            Cm=(1:length(tempAcc));
            for j=1:length(tempAcc)-1
                %disp(tempAcc(j));   
                %disp("Wm lenth")
                %disp(length(Wm))
                %disp("tempAcc(j)")
                %disp(tempAcc);
                Pm(j) = msg_arr(tempAcc(j),2);
                %disp("Pm")
                %disp(Pm)
                Cm(j) = msg_arr(tempAcc(j),4);
                %disp("Cm")
                %disp(Cm)
            end
            sum = zeros;
            Wm=zeros;
            %loop trough all accepted messages + requested and to the
            %realtime analyasis
            if(length(tempAcc)==1)
                s=0;
                sum=sum+s;
                %W=B+(Wm-1+T_bit/P)*C ->hp
                Wm(1)=B+sum;       
                %R=W+C
                R=Wm(1)+msg_arr(tempAcc(1),4);
                disp("R")
                disp(R)
                %Check that the responsetime is less than or equal to the requested
                %message deadline
                if(R > msg_arr(tempAcc(1),3))
                    notAcc=notAcc+1;
                    disp("not Accept")
                end 
                
            else
                for w=1:length(tempAcc)-1
                    sum=0;
                    %sum function
                    for k =1:length(Cm)-1
                        if(size(Cm)==1)
                            s=0;
                        else 
                            s=ceil(((Wm(w)+T_bit)/Pm(k)))*Cm(k);
                        end
                        sum=sum+s;
                    end
                    %W=B+(Wm-1+T_bit/P)*C ->hp
                    Wm(w+1)=B+sum;       
                    %R=W+C
                    R=Wm(w+1)+msg_arr(tempAcc(w),4);
                    disp("R")
                    disp(R)                    
                    %Check that the responsetime is less than or equal to the requested
                    %message deadline
                    disp("Deadline")
                    disp(msg_arr(tempAcc(w),3))                     
                    if(R > msg_arr(tempAcc(w),3))
                        notAcc=notAcc+1;
                        disp("not Accept")
                    end
                end
            end
            if(notAcc==0)
                util = util + req_msg(1,5);
                %disp("util")
                %disp(util)
                %Add message ID to accepted message array
                accept(n)=req_msg(1,1);
                n=n+1;
                disp("accept")
                disp(accept)
                % Increment number of accepted channels
                for k=i:iter
                    num_of_acc(k)=num_of_acc(k)+1;
                end
                % Also, increment number of accepted channels to matrix for average of several simulations
                for k=i:iter
                    total_num_of_acc(k)=total_num_of_acc(k)+1;
                end 
            end
        end
    end
end
x=zeros;
% Prepare for plotting
for i=1:iter
  x(i)=i;
  total_num_of_acc(i)=100*total_num_of_acc(i)/(i*m_max);
end

figure;
plot(x(:),total_num_of_acc(:),x(:),total_num_of_acc(:));
xlim([1 40])
xlabel('Number of requested messages');
ylabel('Acceptence ratio [%]');
grid on
title('Number of Requested vs Accepted ratio');

figure;
plot(utils);
xlim([1 40])
xlabel('Number of requested messages');
ylabel('Utilization');
grid on
title('Number of Requested vs Utilization');


